# Changelog

## 0.3.1 - 2026-10-09

- Add `supportURL` and `composerIcon`, and shorten `shortDescription` to 30 characters, to meet OpenAI plugin directory requirements.
## 0.3.0 - 2026-10-08

- Sync all 21 bundled skills from `render-oss/skills` release `skills-v1.0.0`: shared, single-sourced reference content across skills, doc retrieval that does not require `curl`, and the Render Workflows skill updated for SDK 1.x.
- Remove reference files replaced by shared references (`blueprint-spec.md`, `sizing-and-snapshots.md`, `render-networking` `troubleshooting.md`, `instance-types.md`, `deploy-lifecycle.md`).

## 0.2.0 - 2026-07-10

- Add Codex plugin MCP configuration for the hosted Render MCP server.
- Configure Codex OAuth to use the pre-registered `codex` client ID.
- Add the required Render ChatGPT app mapping for connector distribution.
- Document the Codex MCP and ChatGPT app packaging behavior.
