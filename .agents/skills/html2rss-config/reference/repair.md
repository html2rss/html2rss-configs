# Mode: repair

Fix one existing config. SSOT: [AGENTS.md](../../../../AGENTS.md). Runtime Debugging section there is authoritative.

## Diagnose (cheapest first)

1. Read the YAML; note `channel.url`, selectors, `strategy`.
2. `scripts/check_config <path>` (or `html2rss validate` then `html2rss feed`).
3. If zero items with Faraday:
   - Retry with Botasaurus (`BOTASAURUS_SCRAPER_URL=http://localhost:4010` or `check_config … --botasaurus`).
   - If Botasaurus works → keep config narrow; set `strategy: botasaurus`; run `scripts/register_botasaurus`.
4. If both request strategies fail or items are wrong → Chrome MCP snapshot; confirm item boundary / final URL after redirects.
5. Compare core `feed` vs configs-repo focused fetch when they disagree (request-strategy mismatch, not “selectors OK”). Agency/CDN sites often treat the gem UA differently than a browser — expect intermittent 403/504 in the fetch lane even when CLI `feed` looked fine; prefer Botasaurus or drop.

## Fix order

1. Wrong/canonical URL or locale redirect → fix `channel.url`.
2. Noisy enhancement → `enhance: false` on items (or channel).
3. Over-broad `items` → tighten to repeated article card / content link.
4. Drop weak optional fields (`description`, `published_at`, `categories`) before adding selector complexity.
5. Narrower path if the flagship page is unsalvageable.

## Stop / drop

After one tight loop (~3–4 minutes) with evidence: report **deferred** or recommend **drop** if still noisy, blocked (401/403/timeout), or first-party RSS makes the curated config low value — unless the user says keep going.

## Done

Same Quality Gate as [SKILL.md](../SKILL.md). Focused fetch must match the strategy you ship. Handoff: root cause, what changed, residual drift risk.
