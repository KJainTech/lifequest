const BLOCKLIST = ['damn', 'hell', 'stupid', 'hate', 'kill'];

export function passesSafetyFilter(text: string): boolean {
  const lower = text.toLowerCase();
  return !BLOCKLIST.some((w) => lower.includes(w));
}

export function filterContentStrings(parts: string[]): boolean {
  return parts.every(passesSafetyFilter);
}
