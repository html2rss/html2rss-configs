# Mode: repair

Fix one existing config. Runtime debugging: [AGENTS.md](../../../../AGENTS.md) § Runtime Debugging.

## Diagnose

1. Read YAML: `channel.url`, selectors, `strategy`.
2. `scripts/check_config <path>` (or `html2rss validate` + `apply`).
3. Zero items on default strategy → Botasaurus (`check_config … --botasaurus`); if works → `strategy: botasaurus` + `register_botasaurus`.
4. Still wrong → Chrome MCP snapshot; confirm item boundary and post-redirect URL.
5. CLI `apply` OK but fetch spec fails → request-strategy mismatch; prefer Botasaurus or drop.
6. Botasaurus 422/504 → [pitfalls.md](pitfalls.md).

## Fix order

1. Canonical URL / locale redirect → fix `channel.url`.
2. Chrome leakage → `enhance: false`.
3. Over-broad `items` → tighten to article card / content link.
4. Drop weak optionals before adding selector complexity.
5. Narrower path if flagship page is unsalvageable.

## Stop

After one tight loop (~3–4 min) with evidence: defer or drop unless user says continue. Gate: AGENTS.md Quality Gate.
