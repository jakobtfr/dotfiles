-- tmux prefix and repeatable pane navigation.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>r", "client.config.reload")
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("repeat/k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("repeat/j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("repeat/h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })
rex.bind("repeat/l", "pane.focus", { direction = "right" })

-- Herdr resize mode, sessions, tabs, and panes.
rex.mode("resize", { exclusive = true })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("ctrl+a>shift+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("ctrl+a>shift+n", "session.new")
rex.bind("ctrl+a>shift+4", "session.rename")
rex.bind("ctrl+a>b", "client.sidebar.toggle")
rex.bind("ctrl+a>,", "client.tab.rename")
rex.bind("ctrl+a>shift+t", "client.tab.rename")
rex.bind("ctrl+a>shift+7", "client.tab.close")
rex.bind("ctrl+a>shift+x", "client.tab.close")
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>shift+,", "pane.move", { direction = "left" })
rex.bind("ctrl+a>shift+h", "pane.move", { direction = "left" })
rex.bind("ctrl+a>shift+.", "pane.move", { direction = "right" })
rex.bind("ctrl+a>shift+l", "pane.move", { direction = "right" })

-- Ghostty: LF is the single control key ctrl+j.
rex.bind("ctrl+j", "pane.send_key", { key = "ctrl+j" })

-- iTerm2 global tab-move shortcuts. cmd+n already matches Rex.
-- Profile escape-sequence bindings have no Rex counterpart.
rex.bind("shift+cmd+left", "client.tab.move", { direction = "backward" })
rex.bind("shift+cmd+right", "client.tab.move", { direction = "forward" })

-- Supported tmux defaults, using ctrl+a and preserving custom bindings above.
-- Tabs start at 1, matching the original tmux base-index setting.
rex.bind("ctrl+a>shift+1", "pane.move_to_new_tab")
rex.bind("ctrl+a>shift+9", "session.previous")
rex.bind("ctrl+a>shift+0", "session.next")
rex.bind("ctrl+a>shift+8", "pane.new_floating")
rex.action {
  name = "goto_session_tab",
  title = "Go to Tab in Current Session",
  args = { index = "integer" },
  run = function(ctx, args)
    if not ctx.session_id then error("Tab switching requires a session ID") end
    if args.index < 1 then error("Tab positions start at 1") end

    local view, view_err = rex.session.view { session_id = ctx.session_id }
    if not view then error(view_err) end
    if type(view.windows) ~= "table" then error("Rex returned no window list") end
    local window = view.windows[args.index]
    if not window then
      return {
        status = "missing_tab",
        session_id = ctx.session_id,
        index = args.index,
        tab_count = #view.windows,
      }
    end
    local window_id = window.window_id or window.id
    if type(window_id) ~= "string" then error("Rex returned no window ID") end

    rex.client.queue("session.select", {
      session_id = ctx.session_id,
      window_id = window_id,
    })
    return {
      status = "queued",
      session_id = ctx.session_id,
      index = args.index,
      tab_count = #view.windows,
      window_id = window_id,
    }
  end,
}
rex.bind("ctrl+a>1", "goto_session_tab", { index = 1 })
rex.bind("ctrl+a>2", "goto_session_tab", { index = 2 })
rex.bind("ctrl+a>3", "goto_session_tab", { index = 3 })
rex.bind("ctrl+a>4", "goto_session_tab", { index = 4 })
rex.bind("ctrl+a>5", "goto_session_tab", { index = 5 })
rex.bind("ctrl+a>6", "goto_session_tab", { index = 6 })
rex.bind("ctrl+a>7", "goto_session_tab", { index = 7 })
rex.bind("ctrl+a>8", "goto_session_tab", { index = 8 })
rex.bind("ctrl+a>9", "goto_session_tab", { index = 9 })
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>o", "pane.focus_next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+a>w", "pane.go_to")
rex.action {
  name = "close_pane_or_empty_session",
  title = "Close Pane or Empty Session",
  run = function(ctx)
    if not ctx.session_id then
      error("Closing a pane requires its session ID")
    end

    if ctx.block_id then
      local closed, close_err = rex.call("block.close", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
      })
      if not closed then error(close_err) end
    end

    local view, view_err = rex.session.view { session_id = ctx.session_id }
    if not view then error(view_err) end
    if type(view.windows) ~= "table" then
      error("Rex returned no window list; leaving the session intact")
    end
    if next(view.windows) == nil then
      local destroyed, destroy_err = rex.call("session.destroy", {
        session_id = ctx.session_id,
      })
      if not destroyed then error(destroy_err) end
    end
  end,
}
rex.bind("ctrl+a>x", "close_pane_or_empty_session")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>tab", "pane.go_to")

-- Arrow bindings also work repeatedly inside the existing repeat mode.
rex.bind("ctrl+a>up", "pane.focus", { direction = "up" })
rex.bind("repeat/up", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>down", "pane.focus", { direction = "down" })
rex.bind("repeat/down", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>left", "pane.focus", { direction = "left" })
rex.bind("repeat/left", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>right", "pane.focus", { direction = "right" })
rex.bind("repeat/right", "pane.focus", { direction = "right" })
rex.bind("ctrl+a>ctrl+up", "pane.resize", { direction = "up", amount = 1 })
rex.bind("repeat/ctrl+up", "pane.resize", { direction = "up", amount = 1 })
rex.bind("ctrl+a>ctrl+down", "pane.resize", { direction = "down", amount = 1 })
rex.bind("repeat/ctrl+down", "pane.resize", { direction = "down", amount = 1 })
rex.bind("ctrl+a>ctrl+left", "pane.resize", { direction = "left", amount = 1 })
rex.bind("repeat/ctrl+left", "pane.resize", { direction = "left", amount = 1 })
rex.bind("ctrl+a>ctrl+right", "pane.resize", { direction = "right", amount = 1 })
rex.bind("repeat/ctrl+right", "pane.resize", { direction = "right", amount = 1 })
rex.bind("ctrl+a>alt+up", "pane.resize", { direction = "up", amount = 5 })
rex.bind("repeat/alt+up", "pane.resize", { direction = "up", amount = 5 })
rex.bind("ctrl+a>alt+down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("repeat/alt+down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("ctrl+a>alt+left", "pane.resize", { direction = "left", amount = 5 })
rex.bind("repeat/alt+left", "pane.resize", { direction = "left", amount = 5 })
rex.bind("ctrl+a>alt+right", "pane.resize", { direction = "right", amount = 5 })
rex.bind("repeat/alt+right", "pane.resize", { direction = "right", amount = 5 })
