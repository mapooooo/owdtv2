const DEFAULT_AFTER_AUTH = "/forloeb";
const PASSWORD_PATH = "/saet-kodeord";

export function safeInternalPath(
  value: string | null,
  fallback = DEFAULT_AFTER_AUTH,
) {
  if (!value) {
    return fallback;
  }

  if (!value.startsWith("/") || value.startsWith("//") || value.includes("://")) {
    return fallback;
  }

  return value;
}

export function pathAfterAuthCallback(
  type: string | null,
  next: string | null,
) {
  const fallback =
    type === "invite" || type === "recovery" ? PASSWORD_PATH : DEFAULT_AFTER_AUTH;

  return safeInternalPath(next, fallback);
}
