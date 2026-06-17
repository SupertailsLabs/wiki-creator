# OKF — Open Knowledge Format (conformance rules for generated wikis)

Every wiki this skill generates conforms to **OKF v0.1** (Open Knowledge Format) — a
minimal, tooling-agnostic markdown format. We choose OKF because the people using these
wikis are often non-technical and may open their notes in Obsidian, VS Code, GitHub, or
plain Finder. OKF guarantees the wiki stays readable and navigable *everywhere*, with no
required app, server, or database.

Source spec: <https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>

## The three file kinds

1. **Concept documents** — any `<name>.md` that is not reserved. **One concept per file.**
2. **`index.md`** (reserved) — a directory's table of contents. **No frontmatter.**
3. **`log.md`** (reserved) — a directory's change history. **No frontmatter.**

`index.md` and `log.md` are RESERVED filenames — never use them for a concept page.

## Concept document = frontmatter + body

### Frontmatter (YAML, between `---` fences)

**Required by OKF (the one hard rule):**

- `type` — a short, self-explanatory string naming the kind of thing this is
  (`decision`, `meeting`, `person`, `action`, `pattern`, `result`, `project`,
  `concept`, …). A wiki is OKF-conformant **only if every non-reserved `.md` has a
  non-empty `type`.** Producers should pick descriptive values; the interview lets each
  user name these in their own words.

**Recommended (OKF baseline + our extensions):**

- `title` — human-readable display name
- `description` — one-sentence summary (shown in `index.md` listings)
- `tags` — YAML list for cross-cutting categories
- `timestamp` — ISO 8601 datetime of last change
- `source` — link back to the raw material this was distilled from (e.g. a meeting)
- `people` — list of links to participants/owners
- `status` — lifecycle (`proposed`/`accepted`/`superseded`, `open`/`done`, …)
- `archived` / `archived_reason` — when a page is superseded it is *retired in place* (not
  deleted): an archive date plus a one-line reason. The page keeps its path so links still
  resolve; it stays searchable but is treated as historical. See `references/archival.md`.

Producers MAY add any other keys; consumers MUST preserve unknown keys. So our richer
fields never break OKF compatibility, and a future tool that only understands `type`
still works.

### Body (markdown)

Free-form. Conventional headings (all optional):

- `# Related` — links to neighboring concepts (we use this heavily for the knowledge graph)
- `# Schema` — structured field/column description (for data-asset concepts)
- `# Examples` — usage examples in fenced code blocks
- `# Citations` — external sources, numbered `[1] [Title](https://…)`

## Links — relative form is the default

OKF supports two link forms. We default to the **relative** form because it is the only
one that works in BOTH plain editors AND Obsidian:

| Form | Example | Plain editors | Obsidian |
|---|---|---|---|
| ✅ **Relative** (default) | `[Q3 pricing](./decisions/q3-pricing.md)` | clickable | clickable **+ backlinks + graph** |
| ⚠️ **Absolute (bundle-relative)** | `[x](/decisions/x.md)` | clickable | leading `/` often won't resolve |

Rules for portable links:

- Always include the `.md` extension (plain editors need it to navigate).
- Use **kebab-case** slugs (no spaces → no `%20` encoding, and Obsidian resolves them cleanly).
- "Consumers MUST tolerate broken links." A link to a not-yet-written page is allowed and
  is a useful TODO marker — do not delete it, create the page later.

**Obsidian-wikilink mode (opt-in).** If a user chooses `[[wikilinks]]` in the interview,
the generated wiki uses `[[category/slug]]` (no `.md`). More powerful inside Obsidian
(instant backlinks, graph, autocomplete) but locks the wiki to that one app. Only choose
it for someone who lives entirely in Obsidian. The operating skill records the chosen
style in `SPEC.md` and applies it consistently.

## `index.md` structure (reserved, no frontmatter)

Grouped sections; each entry = link + one-line description pulled from the linked
concept's `description`/`title`:

```markdown
# <Directory Name>

<Optional one-line description of this directory.>

## <Group / Category>

* [Title](./slug.md) — one-line description
* [Subdirectory](./subdir/) — what it holds
```

`index.md` supports progressive disclosure: a reader (human or agent) scans it before
opening any concept page. It may be regenerated from the directory's frontmatter at any time.

## `log.md` structure (reserved, no frontmatter)

Chronological change history, ISO date headings, **newest first**:

```markdown
# <Directory Name> — Log

## 2026-06-15
* **Creation**: [Founder sync](./meetings/2026-06-15-founder-sync.md).
* **Update**: [Q3 pricing decision](./decisions/q3-pricing.md) — marked accepted.
```

Parseable prefixes (`Creation`, `Update`, `Ingest`, …) let simple tools track the wiki's
evolution.

## OKF conformance checklist

A generated wiki conforms to **OKF v0.1** if:

1. Every non-reserved `.md` has parseable YAML frontmatter.
2. Every such frontmatter has a **non-empty `type`**.
3. `index.md` / `log.md` follow the reserved structures above and carry **no frontmatter**.

`scripts/scaffold.py --validate` and the operating skill's `lint` operation both check
these three. **Everything else in this document is soft guidance** — degrade gracefully,
never hard-fail on a missing optional field or an unknown `type` value.

## How we extend OKF (without breaking it)

- We add the rich frontmatter (`source`, `people`, `status`, …) as optional keys — legal
  under OKF's "preserve unknown keys."
- We organize concepts into folders whose names come from the user's own vocabulary
  (e.g. `decisions/`, `actions/`, `1-1s/`). OKF prescribes no taxonomy, so any folder
  layout is conformant as long as each concept carries a `type`.
- The distillation buckets (`decisions`, `actionables`, `patterns`, `results`) and the
  meeting → bucket fan-out are *our* convention layered on top of OKF, recorded in the
  wiki's `SPEC.md`.
