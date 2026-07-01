import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatCost(cost: number): string {
	return `$${cost.toFixed(3)}`;
}

function formatTokenCount(tokens: number): string {
	if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(tokens >= 10_000_000 ? 0 : 2)}M`;
	if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(tokens >= 10_000 ? 0 : 1)}k`;
	return `${tokens}`;
}

function formatContextUsage(ctx: ExtensionContext): string {
	const usage = ctx.getContextUsage();
	if (!usage) return "ctx ?";

	const tokenText =
		usage.tokens === null
			? `?/${formatTokenCount(usage.contextWindow)}`
			: `${formatTokenCount(usage.tokens)}/${formatTokenCount(usage.contextWindow)}`;
	const percentText = usage.percent === null ? "?%" : `${usage.percent.toFixed(1)}%`;
	return `ctx ${percentText} ${tokenText}`;
}

function formatModel(model: ExtensionContext["model"]): string {
	if (!model) return "model ?";
	return `model ${model.provider}/${model.id}`;
}

function formatReasoningEffort(level: ReturnType<ExtensionAPI["getThinkingLevel"]>): string {
	return `effort ${level}`;
}

function getTotalCost(ctx: ExtensionContext): number {
	let cost = 0;

	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const message = entry.message as AssistantMessage;
		cost += message.usage.cost.total;
	}

	return cost;
}

export default function (pi: ExtensionAPI) {
	let requestRender: (() => void) | undefined;
	let modelText = "model ?";
	let effortText = "effort off";

	pi.on("session_start", (_event, ctx) => {
		if (!ctx.hasUI) return;

		modelText = formatModel(ctx.model);
		effortText = formatReasoningEffort(pi.getThinkingLevel());

		ctx.ui.setFooter((tui, theme) => {
			requestRender = () => tui.requestRender();

			return {
				invalidate() {},
				render(width: number): string[] {
					const left = theme.fg("dim", [formatContextUsage(ctx), formatCost(getTotalCost(ctx))].join(" "));
					const right = theme.fg("dim", [modelText, effortText].join(" "));

					const rightWidth = visibleWidth(right);
					const availableLeftWidth = width - rightWidth - 1;
					if (availableLeftWidth <= 0) return [truncateToWidth(right, width, "")];

					const leftText = truncateToWidth(left, availableLeftWidth, "");
					const gap = " ".repeat(Math.max(1, width - visibleWidth(leftText) - rightWidth));
					return [truncateToWidth(leftText + gap + right, width, "")];
				},
			};
		});
	});

	pi.on("model_select", (event) => {
		modelText = formatModel(event.model);
		requestRender?.();
	});

	pi.on("thinking_level_select", (event) => {
		effortText = formatReasoningEffort(event.level);
		requestRender?.();
	});
}
