function truthy(key: string, ...fallbackKeys: string[]) {
  const value = process.env[key]?.toLowerCase()
  if (value === "true" || value === "1") return true
  for (const fallback of fallbackKeys) {
    const v = process.env[fallback]?.toLowerCase()
    if (v === "true" || v === "1") return true
  }
  return false
}

function env(key: string, ...fallbackKeys: string[]): string | undefined {
  return process.env[key] ?? fallbackKeys.reduce<string | undefined>((acc, k) => acc ?? process.env[k], undefined)
}

export namespace Flag {
  export const DRC_AUTO_SHARE = truthy("DRC_AUTO_SHARE", "OPENCODE_AUTO_SHARE")
  export const DRC_GIT_BASH_PATH = env("DRC_GIT_BASH_PATH", "OPENCODE_GIT_BASH_PATH")
  export const DRC_CONFIG = env("DRC_CONFIG", "OPENCODE_CONFIG")
  export declare const DRC_CONFIG_DIR: string | undefined
  export const DRC_CONFIG_CONTENT = env("DRC_CONFIG_CONTENT", "OPENCODE_CONFIG_CONTENT")
  export const DRC_DISABLE_AUTOUPDATE = truthy("DRC_DISABLE_AUTOUPDATE", "OPENCODE_DISABLE_AUTOUPDATE")
  export const DRC_DISABLE_PRUNE = truthy("DRC_DISABLE_PRUNE", "OPENCODE_DISABLE_PRUNE")
  export const DRC_DISABLE_TERMINAL_TITLE = truthy("DRC_DISABLE_TERMINAL_TITLE", "OPENCODE_DISABLE_TERMINAL_TITLE")
  export const DRC_PERMISSION = env("DRC_PERMISSION", "OPENCODE_PERMISSION")
  export const DRC_DISABLE_DEFAULT_PLUGINS = truthy("DRC_DISABLE_DEFAULT_PLUGINS", "OPENCODE_DISABLE_DEFAULT_PLUGINS")
  export const DRC_DISABLE_LSP_DOWNLOAD = truthy("DRC_DISABLE_LSP_DOWNLOAD", "OPENCODE_DISABLE_LSP_DOWNLOAD")
  export const DRC_ENABLE_EXPERIMENTAL_MODELS = truthy(
    "DRC_ENABLE_EXPERIMENTAL_MODELS",
    "OPENCODE_ENABLE_EXPERIMENTAL_MODELS",
  )
  export const DRC_DISABLE_AUTOCOMPACT = truthy("DRC_DISABLE_AUTOCOMPACT", "OPENCODE_DISABLE_AUTOCOMPACT")
  export const DRC_DISABLE_MODELS_FETCH = truthy("DRC_DISABLE_MODELS_FETCH", "OPENCODE_DISABLE_MODELS_FETCH")
  export const DRC_DISABLE_CLAUDE_CODE = truthy("DRC_DISABLE_CLAUDE_CODE", "OPENCODE_DISABLE_CLAUDE_CODE")
  export const DRC_DISABLE_CLAUDE_CODE_PROMPT =
    DRC_DISABLE_CLAUDE_CODE || truthy("DRC_DISABLE_CLAUDE_CODE_PROMPT", "OPENCODE_DISABLE_CLAUDE_CODE_PROMPT")
  export const DRC_DISABLE_CLAUDE_CODE_SKILLS =
    DRC_DISABLE_CLAUDE_CODE || truthy("DRC_DISABLE_CLAUDE_CODE_SKILLS", "OPENCODE_DISABLE_CLAUDE_CODE_SKILLS")
  export const DRC_DISABLE_EXTERNAL_SKILLS =
    DRC_DISABLE_CLAUDE_CODE_SKILLS || truthy("DRC_DISABLE_EXTERNAL_SKILLS", "OPENCODE_DISABLE_EXTERNAL_SKILLS")
  export declare const DRC_DISABLE_PROJECT_CONFIG: boolean
  export const DRC_FAKE_VCS = env("DRC_FAKE_VCS", "OPENCODE_FAKE_VCS")
  export declare const DRC_CLIENT: string
  export const DRC_SERVER_PASSWORD = env("DRC_SERVER_PASSWORD", "OPENCODE_SERVER_PASSWORD")
  export const DRC_SERVER_USERNAME = env("DRC_SERVER_USERNAME", "OPENCODE_SERVER_USERNAME")

  // Experimental
  export const DRC_EXPERIMENTAL = truthy("DRC_EXPERIMENTAL", "OPENCODE_EXPERIMENTAL")
  export const DRC_EXPERIMENTAL_FILEWATCHER = truthy(
    "DRC_EXPERIMENTAL_FILEWATCHER",
    "OPENCODE_EXPERIMENTAL_FILEWATCHER",
  )
  export const DRC_EXPERIMENTAL_DISABLE_FILEWATCHER = truthy(
    "DRC_EXPERIMENTAL_DISABLE_FILEWATCHER",
    "OPENCODE_EXPERIMENTAL_DISABLE_FILEWATCHER",
  )
  export const DRC_EXPERIMENTAL_ICON_DISCOVERY =
    DRC_EXPERIMENTAL || truthy("DRC_EXPERIMENTAL_ICON_DISCOVERY", "OPENCODE_EXPERIMENTAL_ICON_DISCOVERY")

  const copy = env("DRC_EXPERIMENTAL_DISABLE_COPY_ON_SELECT", "OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT")
  export const DRC_EXPERIMENTAL_DISABLE_COPY_ON_SELECT =
    copy === undefined
      ? process.platform === "win32"
      : truthy("DRC_EXPERIMENTAL_DISABLE_COPY_ON_SELECT", "OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT")
  export const DRC_ENABLE_EXA =
    truthy("DRC_ENABLE_EXA", "OPENCODE_ENABLE_EXA") ||
    DRC_EXPERIMENTAL ||
    truthy("DRC_EXPERIMENTAL_EXA", "OPENCODE_EXPERIMENTAL_EXA")
  export const DRC_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS = number(
    "DRC_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS",
    "OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS",
  )
  export const DRC_EXPERIMENTAL_OUTPUT_TOKEN_MAX = number(
    "DRC_EXPERIMENTAL_OUTPUT_TOKEN_MAX",
    "OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX",
  )
  export const DRC_EXPERIMENTAL_OXFMT =
    DRC_EXPERIMENTAL || truthy("DRC_EXPERIMENTAL_OXFMT", "OPENCODE_EXPERIMENTAL_OXFMT")
  export const DRC_EXPERIMENTAL_LSP_TY = truthy("DRC_EXPERIMENTAL_LSP_TY", "OPENCODE_EXPERIMENTAL_LSP_TY")
  export const DRC_EXPERIMENTAL_LSP_TOOL =
    DRC_EXPERIMENTAL || truthy("DRC_EXPERIMENTAL_LSP_TOOL", "OPENCODE_EXPERIMENTAL_LSP_TOOL")
  export const DRC_DISABLE_FILETIME_CHECK = truthy("DRC_DISABLE_FILETIME_CHECK", "OPENCODE_DISABLE_FILETIME_CHECK")
  export const DRC_EXPERIMENTAL_PLAN_MODE =
    DRC_EXPERIMENTAL || truthy("DRC_EXPERIMENTAL_PLAN_MODE", "OPENCODE_EXPERIMENTAL_PLAN_MODE")
  export const DRC_EXPERIMENTAL_MARKDOWN = truthy("DRC_EXPERIMENTAL_MARKDOWN", "OPENCODE_EXPERIMENTAL_MARKDOWN")
  export const DRC_MODELS_URL = env("DRC_MODELS_URL", "OPENCODE_MODELS_URL")
  export const DRC_MODELS_PATH = env("DRC_MODELS_PATH", "OPENCODE_MODELS_PATH")

  function number(key: string, ...fallbackKeys: string[]) {
    const value = env(key, ...fallbackKeys)
    if (!value) return undefined
    const parsed = Number(value)
    return Number.isInteger(parsed) && parsed > 0 ? parsed : undefined
  }
}

// Dynamic getter for DRC_DISABLE_PROJECT_CONFIG
Object.defineProperty(Flag, "DRC_DISABLE_PROJECT_CONFIG", {
  get() {
    return truthy("DRC_DISABLE_PROJECT_CONFIG", "OPENCODE_DISABLE_PROJECT_CONFIG")
  },
  enumerable: true,
  configurable: false,
})

// Dynamic getter for DRC_CONFIG_DIR
Object.defineProperty(Flag, "DRC_CONFIG_DIR", {
  get() {
    return env("DRC_CONFIG_DIR", "OPENCODE_CONFIG_DIR")
  },
  enumerable: true,
  configurable: false,
})

// Dynamic getter for DRC_CLIENT
Object.defineProperty(Flag, "DRC_CLIENT", {
  get() {
    return env("DRC_CLIENT", "OPENCODE_CLIENT") ?? "cli"
  },
  enumerable: true,
  configurable: false,
})
