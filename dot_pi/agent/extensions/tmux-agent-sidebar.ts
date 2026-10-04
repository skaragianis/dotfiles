// Reports pi activity to tmux-agent-sidebar (https://github.com/hiroppy/tmux-agent-sidebar).
//
// The sidebar has no pi adapter, so this speaks its OpenCode hook protocol:
// `hook.sh opencode <event>` with a JSON payload on stdin. pi panes therefore
// show up labelled "opencode". The sidebar drops the pane once its process
// tree no longer contains an `opencode` process, i.e. on its first poll after
// pi exits, which is also how it tears down real OpenCode panes.
//
// No-ops outside tmux or when the sidebar plugin isn't installed.

import { spawn } from "node:child_process"
import { existsSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"

const HOOK_SCRIPT = join(homedir(), ".tmux/plugins/tmux-agent-sidebar/hook.sh")

// Fire-and-forget: never let the sidebar slow down or break pi.
function hook(event: string, payload: Record<string, unknown>): void {
  try {
    const child = spawn("bash", [HOOK_SCRIPT, "opencode", event], {
      stdio: ["pipe", "ignore", "ignore"],
    })
    child.on("error", () => {})
    child.stdin.on("error", () => {})
    child.stdin.end(JSON.stringify(payload))
  } catch {
    // ignore
  }
}

function lastAssistantText(messages: unknown): string {
  if (!Array.isArray(messages)) return ""
  for (let i = messages.length - 1; i >= 0; i--) {
    const m = messages[i]
    if (m?.role !== "assistant" || !Array.isArray(m.content)) continue
    const text = m.content
      .filter((p: any) => p?.type === "text" && typeof p.text === "string")
      .map((p: any) => p.text)
      .join("\n")
    if (text) return text
  }
  return ""
}

export default function (pi: ExtensionAPI) {
  if (!process.env.TMUX_PANE || !existsSync(HOOK_SCRIPT)) return

  let cwd = process.cwd()
  let sessionId = ""
  let lastMessage = ""
  const toolArgs = new Map<string, unknown>()

  const base = () => ({ cwd, session_id: sessionId })

  pi.on("session_start", async (event, ctx) => {
    cwd = ctx.cwd
    sessionId = ctx.sessionManager.getSessionId() ?? ""
    hook("session-start", { ...base(), source: event.reason })
  })

  pi.on("before_agent_start", async (event) => {
    lastMessage = ""
    hook("user-prompt-submit", { ...base(), prompt: event.prompt ?? "" })
  })

  pi.on("agent_end", async (event) => {
    lastMessage = lastAssistantText(event.messages) || lastMessage
  })

  // agent_settled rather than agent_end: pi may still retry, compact or run
  // queued follow-ups after agent_end.
  pi.on("agent_settled", async () => {
    hook("stop", { ...base(), last_message: lastMessage })
  })

  pi.on("ui_prompt_start", async () => {
    hook("notification", { ...base(), wait_reason: "permission" })
  })

  pi.on("ui_prompt_end", async () => {
    hook("user-prompt-submit", { ...base(), prompt: "" })
  })

  pi.on("tool_execution_start", async (event) => {
    toolArgs.set(event.toolCallId, event.args)
  })

  pi.on("tool_execution_end", async (event) => {
    const args = toolArgs.get(event.toolCallId)
    toolArgs.delete(event.toolCallId)
    // pi's file tools take `path`; the sidebar's labels look for `file_path`.
    const input =
      args && typeof args === "object" && "path" in args
        ? { file_path: (args as { path: unknown }).path, ...args }
        : (args ?? {})
    hook("activity-log", {
      ...base(),
      tool_name: event.toolName,
      tool_input: input,
      tool_response: { output: event.isError ? "error" : "", metadata: null },
    })
  })
}
