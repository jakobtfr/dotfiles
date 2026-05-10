import { Agent, Cursor, type ModelListItem, type ModelParameterValue, type SDKAgent } from "@cursor/sdk";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import {
	calculateCost,
	createAssistantMessageEventStream,
	type Api,
	type AssistantMessage,
	type AssistantMessageEventStream,
	type Context,
	type Model,
	type SimpleStreamOptions,
} from "@earendil-works/pi-ai";
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const PROVIDER = "cursor";
const API = "cursor-sdk" as Api;
const API_KEY_ENV = "CURSOR_API_KEY";
const LOCAL_AUTH_SENTINEL = "cursor-sdk-local-auth";
const DEFAULT_MODEL = "composer-2";
const FALLBACK_MODELS: ModelListItem[] = [
	{ id: "composer-2", displayName: "Composer 2" },
	{ id: "auto", displayName: "Auto" },
];

const THINKING_LEVELS = ["minimal", "low", "medium", "high", "xhigh"] as const;

type ThinkingLevel = (typeof THINKING_LEVELS)[number] | "off";

type CursorRunCallbacks = {
	onTextDelta?: (text: string) => void;
	onThinkingDelta?: (text: string) => void;
	onStatus?: (text: string) => void;
	onTool?: (text: string) => void;
};

const cursorModels = new Map<string, ModelListItem>();

// Cursor SDK (and its connect-rpc transport) emits unhandledRejection events
// for backgrounded RPC abort/auth flows. Without a guard, those rejections
// crash the entire Pi process. We install scoped process listeners while a
// Cursor agent is active and swallow rejections that come from Cursor SDK
// internals so the failure surfaces through our own try/catch instead.
let activeCursorRuns = 0;
let originalRejectionListeners: NodeJS.UnhandledRejectionListener[] | undefined;
let originalExceptionListeners: NodeJS.UncaughtExceptionListener[] | undefined;
let originalStdoutWrite: typeof process.stdout.write | undefined;
let originalStderrWrite: typeof process.stderr.write | undefined;

const NOISY_LOG_PATTERNS: RegExp[] = [
	/^\s*\d{1,2}:\d{2}:\d{2}\.\d{1,3}\s+(?:INFO|DEBUG|TRACE|WARN)\b/,
	/^\s+INFO\s+\[Statsig\]/,
	/^\s+DEBUG\s+\[Statsig\]/,
	/^\[Statsig\]/,
];

function isNoisyCursorLog(chunk: unknown): boolean {
	if (typeof chunk !== "string" && !(chunk instanceof Uint8Array)) return false;
	const text = typeof chunk === "string" ? chunk : Buffer.from(chunk as Uint8Array).toString("utf8");
	return NOISY_LOG_PATTERNS.some((pattern) => pattern.test(text));
}

function looksLikeCursorSdkError(reason: unknown): boolean {
	if (!reason) return false;
	const stack = (reason as { stack?: unknown })?.stack;
	if (typeof stack === "string" && (stack.includes("@cursor/sdk") || stack.includes("@connectrpc/"))) return true;
	const code = (reason as { code?: unknown })?.code;
	if (typeof code === "string" && ["unauthenticated", "permission_denied", "unavailable", "deadline_exceeded"].includes(code)) {
		return true;
	}
	const name = (reason as { constructor?: { name?: string }; name?: string })?.constructor?.name ?? (reason as { name?: string })?.name;
	if (typeof name === "string" && (name.includes("ConnectError") || name.includes("CursorAgent"))) return true;
	return false;
}

function lastExtensionLog(error: unknown): void {
	try {
		const message = error instanceof Error ? error.message : String(error);
		if (process.env.PI_CURSOR_DEBUG) {
			process.stderr.write(`[cursor-provider] swallowed rejection: ${message}\n`);
		}
	} catch {
		// ignore logging errors
	}
}

function beginCursorGuard(): void {
	activeCursorRuns += 1;
	if (activeCursorRuns !== 1) return;
	originalRejectionListeners = process.listeners("unhandledRejection").slice();
	originalExceptionListeners = process.listeners("uncaughtException").slice();
	process.removeAllListeners("unhandledRejection");
	process.removeAllListeners("uncaughtException");
	process.on("unhandledRejection", cursorRejectionGuard);
	process.on("uncaughtException", cursorExceptionGuard);
	originalStdoutWrite = process.stdout.write.bind(process.stdout);
	originalStderrWrite = process.stderr.write.bind(process.stderr);
	const makeFilter = (sink: typeof process.stdout.write) =>
		function filtered(chunk: any, encoding?: any, cb?: any): boolean {
			if (isNoisyCursorLog(chunk)) {
				if (typeof encoding === "function") encoding();
				else if (typeof cb === "function") cb();
				return true;
			}
			return (sink as any)(chunk, encoding, cb);
		} as typeof process.stdout.write;
	process.stdout.write = makeFilter(originalStdoutWrite);
	process.stderr.write = makeFilter(originalStderrWrite);
}

function endCursorGuard(): void {
	activeCursorRuns = Math.max(0, activeCursorRuns - 1);
	if (activeCursorRuns !== 0) return;
	process.removeListener("unhandledRejection", cursorRejectionGuard);
	process.removeListener("uncaughtException", cursorExceptionGuard);
	for (const listener of originalRejectionListeners ?? []) process.on("unhandledRejection", listener);
	for (const listener of originalExceptionListeners ?? []) process.on("uncaughtException", listener);
	originalRejectionListeners = undefined;
	originalExceptionListeners = undefined;
	if (originalStdoutWrite) process.stdout.write = originalStdoutWrite;
	if (originalStderrWrite) process.stderr.write = originalStderrWrite;
	originalStdoutWrite = undefined;
	originalStderrWrite = undefined;
}

function cursorRejectionGuard(reason: unknown, promise: Promise<unknown>): void {
	if (looksLikeCursorSdkError(reason)) {
		lastExtensionLog(reason);
		return;
	}
	for (const listener of originalRejectionListeners ?? []) {
		try {
			listener(reason, promise);
		} catch {
			// ignore
		}
	}
}

function cursorExceptionGuard(error: Error, origin: NodeJS.UncaughtExceptionOrigin): void {
	if (looksLikeCursorSdkError(error)) {
		lastExtensionLog(error);
		return;
	}
	for (const listener of originalExceptionListeners ?? []) {
		try {
			listener(error, origin);
		} catch {
			// ignore
		}
	}
}

let cachedApiKey: { value: string | undefined; resolvedAt: number } | undefined;
const API_KEY_TTL_MS = 5 * 60 * 1000;

function tryRead(path: string): string | undefined {
	try {
		if (!existsSync(path)) return undefined;
		const content = readFileSync(path, "utf8").trim();
		return content || undefined;
	} catch {
		return undefined;
	}
}

function tryKeychain(): string | undefined {
	if (process.platform !== "darwin") return undefined;
	try {
		const out = execFileSync("security", ["find-generic-password", "-s", "cursor-api-key", "-w"], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
			timeout: 1000,
		});
		const trimmed = out.trim();
		return trimmed || undefined;
	} catch {
		return undefined;
	}
}

function tryCommand(cmd: string): string | undefined {
	try {
		const out = execFileSync("sh", ["-c", cmd], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
			timeout: 5000,
		});
		const trimmed = out.trim();
		return trimmed || undefined;
	} catch {
		return undefined;
	}
}

function resolveCursorApiKey(): string | undefined {
	if (cachedApiKey && Date.now() - cachedApiKey.resolvedAt < API_KEY_TTL_MS) {
		return cachedApiKey.value;
	}

	const envValue = process.env[API_KEY_ENV]?.trim();
	if (envValue) {
		cachedApiKey = { value: envValue, resolvedAt: Date.now() };
		return envValue;
	}

	const envCmd = process.env.CURSOR_API_KEY_CMD?.trim();
	if (envCmd) {
		const value = tryCommand(envCmd);
		if (value) {
			cachedApiKey = { value, resolvedAt: Date.now() };
			return value;
		}
	}

	const paths = [
		join(homedir(), ".config", "cursor", "api-key"),
		join(homedir(), ".pi", "cursor-api-key"),
	];
	for (const path of paths) {
		const value = tryRead(path);
		if (value) {
			cachedApiKey = { value, resolvedAt: Date.now() };
			return value;
		}
	}

	const keychain = tryKeychain();
	if (keychain) {
		cachedApiKey = { value: keychain, resolvedAt: Date.now() };
		return keychain;
	}

	cachedApiKey = { value: undefined, resolvedAt: Date.now() };
	return undefined;
}

function invalidateCursorApiKeyCache(): void {
	cachedApiKey = undefined;
}

function getApiKey(explicit?: string): string | undefined {
	if (explicit && explicit !== LOCAL_AUTH_SENTINEL && explicit !== API_KEY_ENV) {
		const trimmed = explicit.trim();
		if (trimmed) return trimmed;
	}
	return resolveCursorApiKey();
}

function getModelParameter(modelId: string, parameterId: string) {
	return cursorModels.get(modelId)?.parameters?.find((parameter) => parameter.id === parameterId);
}

function modelSupportsThinking(modelId: string): boolean {
	const model = cursorModels.get(modelId);
	return model?.parameters?.some((parameter) => ["thinking", "reasoning", "effort"].includes(parameter.id)) ?? false;
}

function pickSupportedValue(modelId: string, parameterId: string, preferred: string[]): string | undefined {
	const parameter = getModelParameter(modelId, parameterId);
	const supported = new Set(parameter?.values.map((item) => item.value) ?? []);
	for (const value of preferred) {
		if (supported.has(value)) return value;
	}
	return parameter?.values[0]?.value;
}

function mapThinkingParams(level: string | undefined, modelId: string): ModelParameterValue[] | undefined {
	const params: ModelParameterValue[] = [];
	const isOff = !level || level === "off" || level === "none" || level === "false";

	if (getModelParameter(modelId, "reasoning")) {
		const value = isOff
			? pickSupportedValue(modelId, "reasoning", ["none", "low"])
			: pickSupportedValue(
				modelId,
				"reasoning",
				level === "minimal" || level === "low"
					? ["low", "medium", "high"]
					: level === "medium"
						? ["medium", "high", "low"]
						: level === "xhigh" || level === "extra-high" || level === "max"
							? ["extra-high", "xhigh", "max", "high"]
							: ["high", "medium", "low"],
			);
		if (value) params.push({ id: "reasoning", value });
	}

	if (getModelParameter(modelId, "thinking")) {
		const value = isOff ? pickSupportedValue(modelId, "thinking", ["false"]) : pickSupportedValue(modelId, "thinking", ["true"]);
		if (value) params.push({ id: "thinking", value });
	}

	if (!isOff && getModelParameter(modelId, "effort")) {
		const value = pickSupportedValue(
			modelId,
			"effort",
			level === "minimal" || level === "low"
				? ["low", "medium", "high"]
				: level === "medium"
					? ["medium", "high", "low"]
					: level === "xhigh" || level === "extra-high" || level === "max"
						? ["max", "xhigh", "extra-high", "high"]
						: ["high", "medium", "low"],
		);
		if (value) params.push({ id: "effort", value });
	}

	return params.length > 0 ? params : undefined;
}

function buildPiProviderPrompt(context: Context): string {
	const parts: string[] = [
		"You are running as the Cursor SDK-backed provider inside Pi.",
		"Answer the latest user request using the conversation transcript below.",
		"If you use Cursor's local coding tools, keep changes focused and mention changed files in the final answer.",
	];

	if (context.systemPrompt?.trim()) {
		parts.push("\n<persistent_system_prompt>", context.systemPrompt.trim(), "</persistent_system_prompt>");
	}

	parts.push("\n<conversation>");
	for (const message of context.messages) {
		if (message.role === "user") {
			const text = typeof message.content === "string"
				? message.content
				: message.content
					.map((item) => item.type === "text" ? item.text : `[image: ${item.mimeType}]`)
					.join("\n");
			parts.push(`\n[User]\n${text}`);
		} else if (message.role === "assistant") {
			const text = message.content
				.map((item) => {
					if (item.type === "text") return item.text;
					if (item.type === "thinking") return `[thinking omitted]`;
					if (item.type === "toolCall") return `[tool call: ${item.name} ${JSON.stringify(item.arguments)}]`;
					return `[${item.type}]`;
				})
				.join("\n");
			parts.push(`\n[Assistant]\n${text}`);
		} else if (message.role === "toolResult") {
			const text = message.content.map((item) => item.type === "text" ? item.text : `[image: ${item.mimeType}]`).join("\n");
			parts.push(`\n[Tool result: ${message.toolName ?? message.toolCallId}]\n${text}`);
		}
	}
	parts.push("\n</conversation>");
	parts.push("\nRespond now to the latest user request.");
	return parts.join("\n");
}

async function closeAgent(agent: SDKAgent | undefined): Promise<void> {
	if (!agent) return;
	try {
		await agent[Symbol.asyncDispose]?.();
	} catch {
		try {
			agent.close();
		} catch {
			// ignore cleanup failures
		}
	}
}

async function runCursorAgent(options: {
	prompt: string;
	cwd: string;
	modelId: string;
	apiKey?: string;
	params?: ModelParameterValue[];
	signal?: AbortSignal;
	callbacks?: CursorRunCallbacks;
}): Promise<{ text: string; thinking: string; modelId?: string }> {
	if (!options.apiKey) {
		throw new Error(
			`Missing ${API_KEY_ENV}. Create a Cursor API key at https://cursor.com/dashboard/integrations and export it (e.g. add to ~/.zshrc), then restart the shell that runs Pi.`,
		);
	}

	let agent: SDKAgent | undefined;
	let run: Awaited<ReturnType<SDKAgent["send"]>> | undefined;
	let text = "";
	let thinking = "";
	let abortListener: (() => void) | undefined;

	beginCursorGuard();
	try {
		agent = await Agent.create({
			apiKey: options.apiKey,
			model: {
				id: options.modelId,
				params: options.params,
			},
			local: {
				cwd: options.cwd,
				settingSources: ["project", "user"],
			},
		});

		if (options.signal) {
			abortListener = () => void run?.cancel().catch(() => undefined);
			options.signal.addEventListener("abort", abortListener, { once: true });
		}

		run = await agent.send(options.prompt, {
			onDelta: ({ update }) => {
				if (update.type === "text-delta") {
					text += update.text;
					options.callbacks?.onTextDelta?.(update.text);
					return;
				}
				if (update.type === "thinking-delta") {
					thinking += update.text;
					options.callbacks?.onThinkingDelta?.(update.text);
					return;
				}
				if (update.type === "tool-call-started") {
					options.callbacks?.onTool?.(`tool started: ${update.toolCall.type}`);
					return;
				}
				if (update.type === "tool-call-completed") {
					options.callbacks?.onTool?.(`tool completed: ${update.toolCall.type}`);
				}
			},
		});

		if (run.supports("stream")) {
			for await (const event of run.stream()) {
				if (options.signal?.aborted) {
					await run.cancel().catch(() => undefined);
					break;
				}
				if (event.type === "status" && event.message) {
					options.callbacks?.onStatus?.(event.message);
				}
			}
		}

		const result = await run.wait();
		if (result.result && !text.trim()) {
			text = result.result;
		}
		if (result.status === "error") {
			throw new Error(result.result || "Cursor agent run failed");
		}
		if (result.status === "cancelled" || options.signal?.aborted) {
			throw new Error("Cursor agent run cancelled");
		}
		return { text, thinking, modelId: result.model?.id };
	} finally {
		if (abortListener && options.signal) options.signal.removeEventListener("abort", abortListener);
		await closeAgent(agent);
		endCursorGuard();
	}
}

function streamCursorProvider(
	model: Model<Api>,
	context: Context,
	options?: SimpleStreamOptions,
): AssistantMessageEventStream {
	const stream = createAssistantMessageEventStream();

	void (async () => {
		const output: AssistantMessage = {
			role: "assistant",
			content: [],
			api: model.api,
			provider: model.provider,
			model: model.id,
			usage: {
				input: 0,
				output: 0,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 0,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			},
			stopReason: "stop",
			timestamp: Date.now(),
		};

		let textIndex: number | undefined;
		let thinkingIndex: number | undefined;

		try {
			const apiKey = getApiKey(options?.apiKey);

			stream.push({ type: "start", partial: output });
			const prompt = buildPiProviderPrompt(context);
			const params = mapThinkingParams(options?.reasoning, model.id);

			await runCursorAgent({
				prompt,
				cwd: process.cwd(),
				modelId: model.id,
				apiKey,
				params,
				signal: options?.signal,
				callbacks: {
					onTextDelta: (delta) => {
						if (textIndex === undefined) {
							output.content.push({ type: "text", text: "" });
							textIndex = output.content.length - 1;
							stream.push({ type: "text_start", contentIndex: textIndex, partial: output });
						}
						const block = output.content[textIndex];
						if (block?.type === "text") block.text += delta;
						stream.push({ type: "text_delta", contentIndex: textIndex, delta, partial: output });
					},
					onThinkingDelta: (delta) => {
						if (thinkingIndex === undefined) {
							output.content.push({ type: "thinking", thinking: "" });
							thinkingIndex = output.content.length - 1;
							stream.push({ type: "thinking_start", contentIndex: thinkingIndex, partial: output });
						}
						const block = output.content[thinkingIndex];
						if (block?.type === "thinking") block.thinking += delta;
						stream.push({ type: "thinking_delta", contentIndex: thinkingIndex, delta, partial: output });
					},
				},
			});

			if (thinkingIndex !== undefined) {
				const block = output.content[thinkingIndex];
				if (block?.type === "thinking") {
					stream.push({ type: "thinking_end", contentIndex: thinkingIndex, content: block.thinking, partial: output });
				}
			}
			if (textIndex === undefined) {
				output.content.push({ type: "text", text: "" });
				textIndex = output.content.length - 1;
				stream.push({ type: "text_start", contentIndex: textIndex, partial: output });
			}
			const block = output.content[textIndex];
			if (block?.type === "text") {
				stream.push({ type: "text_end", contentIndex: textIndex, content: block.text, partial: output });
			}
			calculateCost(model, output.usage);
			stream.push({ type: "done", reason: "stop", message: output });
			stream.end();
		} catch (error) {
			output.stopReason = options?.signal?.aborted ? "aborted" : "error";
			output.errorMessage = error instanceof Error ? error.message : String(error);
			stream.push({ type: "error", reason: output.stopReason, error: output });
			stream.end();
		}
	})();

	return stream;
}

function commandUsage(): string {
	return [
		"Usage:",
		"  /cursor <prompt>",
		"  /cursor --model <model-id> <prompt>",
		"  /cursor --thinking low|high <prompt>",
		"  /cursor models",
		"  /cursor whoami",
		"",
		`Requires a Cursor API key. Pi looks in (in order):`,
		`  1. ${API_KEY_ENV} env var`,
		`  2. CURSOR_API_KEY_CMD env var (sh -c <cmd>)`,
		`  3. ~/.config/cursor/api-key`,
		`  4. ~/.pi/cursor-api-key`,
		`  5. macOS keychain: security add-generic-password -U -a "$USER" -s cursor-api-key -w "<key>"`,
	].join("\n");
}

function parseCursorArgs(args: string): { action: "models" } | { action: "whoami" } | { action: "run"; modelId: string; thinking?: string; prompt: string } | { action: "help"; error?: string } {
	const tokens = args.match(/(?:[^\s"]+|"[^"]*")+/g)?.map((token) => token.replace(/^"|"$/g, "")) ?? [];
	if (tokens.length === 0 || tokens[0] === "help" || tokens[0] === "--help") return { action: "help" };
	if (tokens[0] === "models") return { action: "models" };
	if (tokens[0] === "whoami" || tokens[0] === "diag") return { action: "whoami" };

	let modelId = process.env.CURSOR_MODEL?.trim() || DEFAULT_MODEL;
	let thinking: string | undefined;
	const promptParts: string[] = [];
	for (let i = 0; i < tokens.length; i++) {
		const token = tokens[i];
		if (token === "--model" || token === "-m") {
			const value = tokens[++i];
			if (!value) return { action: "help", error: "Missing value for --model" };
			modelId = value;
			continue;
		}
		if (token === "--thinking" || token === "-t") {
			const value = tokens[++i] as ThinkingLevel | undefined;
			if (!value) return { action: "help", error: "Missing value for --thinking" };
			if (!["off", ...THINKING_LEVELS].includes(value)) {
				return { action: "help", error: `Invalid thinking level: ${value}` };
			}
			thinking = value === "off" ? undefined : value;
			continue;
		}
		promptParts.push(token);
	}

	const prompt = promptParts.join(" ").trim();
	if (!prompt) return { action: "help", error: "Missing prompt" };
	return { action: "run", modelId, thinking, prompt };
}

async function handleCursorCommand(pi: ExtensionAPI, args: string, ctx: ExtensionCommandContext): Promise<void> {
	const parsed = parseCursorArgs(args);
	invalidateCursorApiKeyCache();
	const apiKey = getApiKey();

	if (parsed.action === "help") {
		const text = parsed.error ? `${parsed.error}\n\n${commandUsage()}` : commandUsage();
		if (ctx.hasUI) ctx.ui.notify(text, parsed.error ? "error" : "info");
		else console.log(text);
		return;
	}

	if (parsed.action === "whoami") {
		const lines: string[] = [];
		lines.push(`API key sources tried:`);
		lines.push(`  ${API_KEY_ENV}: ${process.env[API_KEY_ENV] ? "set (" + process.env[API_KEY_ENV]!.length + " chars)" : "unset"}`);
		lines.push(`  CURSOR_API_KEY_CMD: ${process.env.CURSOR_API_KEY_CMD ? "set" : "unset"}`);
		for (const path of [join(homedir(), ".config", "cursor", "api-key"), join(homedir(), ".pi", "cursor-api-key")]) {
			lines.push(`  ${path}: ${existsSync(path) ? "present" : "absent"}`);
		}
		if (process.platform === "darwin") {
			lines.push(`  macOS keychain (cursor-api-key): ${tryKeychain() ? "present" : "absent"}`);
		}
		lines.push(`Resolved key: ${apiKey ? "yes (" + apiKey.length + " chars)" : "no"}`);
		if (apiKey) {
			try {
				const me = await Cursor.me({ apiKey });
				lines.push(`Cursor account: ${me.userEmail ?? me.apiKeyName}`);
			} catch (error) {
				lines.push(`Cursor account check failed: ${error instanceof Error ? error.message : String(error)}`);
			}
		}
		const text = lines.join("\n");
		if (ctx.hasUI) ctx.ui.notify(text, "info");
		else console.log(text);
		return;
	}

	if (!apiKey) {
		const message = [
			`Missing Cursor API key. Pi looked in:`,
			`  - $${API_KEY_ENV} (env var)`,
			`  - $CURSOR_API_KEY_CMD`,
			`  - ~/.config/cursor/api-key`,
			`  - ~/.pi/cursor-api-key`,
			process.platform === "darwin" ? `  - macOS keychain (service 'cursor-api-key')` : null,
			``,
			`Get a key at https://cursor.com/dashboard/integrations, then either:`,
			`  echo '<key>' > ~/.config/cursor/api-key && chmod 600 ~/.config/cursor/api-key`,
			process.platform === "darwin"
				? `  security add-generic-password -U -a "$USER" -s cursor-api-key -w '<key>'`
				: null,
			`  or export ${API_KEY_ENV} in the shell that launches Pi (then restart Pi).`,
		]
			.filter((line): line is string => line !== null)
			.join("\n");
		if (ctx.hasUI) ctx.ui.notify(message, "error");
		else console.error(message);
		return;
	}

	if (parsed.action === "models") {
		try {
			const models = await Cursor.models.list({ apiKey });
			const lines = models.map((model) => {
				const params = model.parameters?.length ? ` params: ${model.parameters.map((p) => p.id).join(",")}` : "";
				return `- ${model.id} — ${model.displayName}${params}`;
			});
			const text = lines.join("\n") || "No Cursor models returned.";
			if (ctx.hasUI) ctx.ui.notify(text, "info");
			else console.log(text);
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			if (ctx.hasUI) ctx.ui.notify(`Cursor model list failed: ${message}`, "error");
			else console.error(message);
		}
		return;
	}

	await ctx.waitForIdle();
	const modelId = parsed.modelId;
	const params = mapThinkingParams(parsed.thinking, modelId);
	let statusLines: string[] = [];

	try {
		if (ctx.hasUI) {
			ctx.ui.setStatus("cursor", ctx.ui.theme.fg("accent", `cursor ${modelId}`));
			ctx.ui.setWidget("cursor", [`Running Cursor SDK agent (${modelId})…`]);
		}

		const result = await runCursorAgent({
			prompt: parsed.prompt,
			cwd: ctx.cwd,
			modelId,
			apiKey,
			params,
			callbacks: {
				onStatus: (line) => {
					statusLines = [...statusLines.slice(-4), line];
					if (ctx.hasUI) ctx.ui.setWidget("cursor", [`Cursor SDK agent (${modelId})`, ...statusLines]);
				},
				onTool: (line) => {
					statusLines = [...statusLines.slice(-4), line];
					if (ctx.hasUI) ctx.ui.setWidget("cursor", [`Cursor SDK agent (${modelId})`, ...statusLines]);
				},
			},
		});

		const content = result.text.trim() || "(Cursor agent finished without text output.)";
		pi.sendMessage({
			customType: "cursor",
			content: `Cursor (${result.modelId ?? modelId})\n\n${content}`,
			display: true,
			details: { modelId: result.modelId ?? modelId },
		});
		if (!ctx.hasUI) console.log(content);
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		if (ctx.hasUI) ctx.ui.notify(`Cursor failed: ${message}`, "error");
		else console.error(message);
	} finally {
		if (ctx.hasUI) {
			ctx.ui.setWidget("cursor", undefined);
			ctx.ui.setStatus("cursor", undefined);
		}
	}
}

async function discoverCursorModels(): Promise<ModelListItem[]> {
	const apiKey = getApiKey();
	if (!apiKey) return FALLBACK_MODELS;
	try {
		const models = await Cursor.models.list({ apiKey });
		return models.length > 0 ? models : FALLBACK_MODELS;
	} catch {
		return FALLBACK_MODELS;
	}
}

export default async function (pi: ExtensionAPI) {
	const models = await discoverCursorModels();
	cursorModels.clear();
	for (const model of models) cursorModels.set(model.id, model);

	pi.registerProvider(PROVIDER, {
		name: "Cursor SDK",
		baseUrl: "cursor-sdk://local-agent",
		apiKey: LOCAL_AUTH_SENTINEL,
		api: API,
		models: models.map((model) => ({
			id: model.id,
			name: model.displayName || model.id,
			reasoning: modelSupportsThinking(model.id),
			input: ["text"],
			cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
			contextWindow: 200000,
			maxTokens: 32000,
			thinkingLevelMap: modelSupportsThinking(model.id)
				? { off: "off", minimal: "low", low: "low", medium: "medium", high: "high", xhigh: "xhigh" }
				: undefined,
		})),
		streamSimple: streamCursorProvider,
	} as never);

	pi.registerCommand("cursor", {
		description: "Run Cursor's official SDK agent in this working tree, or list Cursor SDK models",
		handler: async (args, ctx) => handleCursorCommand(pi, args, ctx),
		getArgumentCompletions: (prefix) => {
			const items = [
				{ value: "models", label: "models", description: "List Cursor models available to CURSOR_API_KEY" },
				{ value: "--model ", label: "--model", description: "Run with a specific Cursor model id" },
				{ value: "--thinking high ", label: "--thinking", description: "Set Cursor thinking parameter when supported" },
			];
			return items.filter((item) => item.value.startsWith(prefix));
		},
	});
}
