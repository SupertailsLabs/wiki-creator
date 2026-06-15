<!-- GENERATOR NOTES (delete this whole comment when writing the final SKILL.md):
  • Fill every {{TOKEN}}. • Resolve [IF …] / [ONLY IF …] blocks: keep the block if the
    wiki has that feature, delete it (and the markers) otherwise.
  • Copy the chosen note-templates into  ~/.claude/skills/{{WIKI_NAME}}/templates/  (drop
    the .tpl extension) so the references below resolve.
  • Keep the final file focused on what THIS wiki has. -->
---
name: {{WIKI_NAME}}
description: |
  {{WIKI_DESCRIPTION}} Operate {{OWNER}}'s personal work wiki — capture meetings and
  1:1s, distill them into {{BUCKETS}}, search the knowledge base, and keep it healthy.
  Use whenever {{OWNER}} says "/{{WIKI_NAME}}", "add this to my wiki", "log this meeting",
  "what did we decide about X", or "what do I know about X", or at the end of a meeting or
  working session. Make sure to use this skill whenever {{OWNER}} mentions a meeting, a
  1:1, an action item, a decision, an outcome, or wants to recall anything from past
  work — even if they don't say the word "wiki".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /{{WIKI_NAME}} — {{OWNER}}'s Work Wiki

You maintain {{OWNER}}'s personal work wiki: an
[LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) stored in
[OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
format. Raw material (meetings, 1:1s, pasted transcripts) is captured once; you distill it
into short, cross-linked pages and keep everything searchable. The owner is usually
**non-technical** — keep your messages plain, do the filing for them, and never make them
think about folders or frontmatter.

Full conventions live in `"$VAULT_ROOT/SPEC.md"`. The essentials are below.

## Constants

```
VAULT_ROOT="{{VAULT_ROOT}}"
QMD_COLLECTION="{{QMD_COLLECTION}}"
```

> Always double-quote `$VAULT_ROOT` in every Bash, Read, Write, Edit, Glob, and Grep call —
> the path may contain spaces.

## Links — {{LINK_STYLE}}

{{LINK_RULE}}

## Page format

Before writing a page, read the matching template in `templates/` next to this skill file
(`templates/meeting.md`, `templates/decision.md`, …) and fill its `{{TOKEN}}` slots. **Every
page must have a `type`** in its frontmatter — that is what makes the wiki valid. Reserved
files (`index.md`, `log.md`) and the two meta docs (`README.md`, `SPEC.md`) have no `type`.

Page types in this wiki:

{{TYPE_VOCAB_TABLE}}

## Search — qmd, with grep fallback

Detect once per session: `command -v qmd`. If present, prefer it; if not, use `Grep`/`Glob`
over `"$VAULT_ROOT"` and mention semantic search can be enabled later.

```bash
# best-quality hybrid search (answering questions)
qmd query "<question>" -c "$QMD_COLLECTION" --format json -n 8 --full-path
# fast keyword search (dedup before writing)
qmd search "<key terms>" -c "$QMD_COLLECTION" --format json -n 5 --full-path
# semantic-only (concept dedup, catches synonyms)
qmd vsearch "<concept>" -c "$QMD_COLLECTION" --format json -n 5 --full-path
# ALWAYS refresh after writing/editing/deleting pages
qmd update && qmd embed
```

Grep fallback: `grep -rni "<terms>" "$VAULT_ROOT" --include="*.md"`.

**Freshness rule:** after any write/edit/delete, run `qmd update && qmd embed` (if qmd is
present) so the next search is current.

## Command routing

| Invocation | Operation |
|---|---|
| `/{{WIKI_NAME}}` or `/{{WIKI_NAME}} ingest` | **Ingest** — distill the current conversation |
| `/{{WIKI_NAME}} meeting [paste]` | **Meeting** — distill a meeting/transcript |
| `/{{WIKI_NAME}} query <question>` | **Query** — search + answer |
| `/{{WIKI_NAME}} person <name>` | **Person** — log a 1:1/conversation [ONLY IF people/] |
| `/{{WIKI_NAME}} init project\|person <name>` | **Init** — add a new subtree |
| `/{{WIKI_NAME}} lint` | **Lint** — health check |
| `/{{WIKI_NAME}} status` / `reindex` | stats / refresh search index |

---

## Operation: Meeting (the centerpiece)

Distill a meeting or pasted transcript into a meeting note **plus** fanned-out bucket pages.

1. **Get the material.** From the args, the pasted transcript, or — if neither — ask:
   "Paste the notes/transcript, or just tell me what happened."
2. **Identify** the date (default today), a short title, a kebab-case slug, and the
   participants. [IF people/] Match participants to `people/<slug>/`; offer to add anyone new
   (see Init). [/IF]
3. **Write the meeting note** at `"$VAULT_ROOT/meetings/<date>-<slug>.md"` from
   `templates/meeting.md`. Transcript handling for this wiki is **{{TRANSCRIPT_MODE}}**:
   - `distilled-only` → write the Summary only; do not keep the raw text.
   - `narrative+distilled` → write a fuller narrative Summary; do not keep the raw text.
   - `raw+distilled` → also append the full transcript inside the collapsible Raw transcript
     block at the bottom.
4. **Fan out** the useful parts into the buckets — {{BUCKETS}}. For EACH item:
   - **Dedup first** (qmd `search`/`vsearch`, or grep). If a page on the same thing exists,
     UPDATE it (append a dated note) instead of creating a duplicate.
   - Otherwise create the page from the matching template in `templates/`.
   - Set `source:` to a link back to this meeting, and `people:` to the participants involved.
   - **Results** must set `follows_up:` to the decision/actionable they are the outcome of —
     this closes the loop so you can trace decision → result.
5. **Link the meeting note's sections** (`## Actionables`, `## Decisions`, `## Patterns`,
   `## Results`) to the pages you just wrote.
6. **Update indexes & logs**: add each new page to its folder's `index.md`; append a dated
   line to each touched `log.md` and to the root `log.md`.
7. **Refresh search**: `qmd update && qmd embed` (if qmd present).
8. **Report** plainly: "Filed the founder sync — 2 actions, 1 decision, 1 pattern. Want me
   to do anything with them?"

Keep friction low: show a 2–4 line preview of what you'll file, then proceed. Only stop to
ask if something is genuinely ambiguous (e.g. who owns an action).

## Operation: Ingest (default)

Same as Meeting, but the source is the **current conversation** rather than a pasted
transcript. Decide whether it was effectively a meeting (then also write a meeting note) or
just working notes (then fan out to buckets directly). Reuse steps 4–8 above.

## Operation: Person — log a 1:1 [ONLY IF people/]

1. Resolve `<name>` to `people/<slug>/`. If they don't exist yet, run **Init person** first.
2. Get what was discussed (args or ask).
3. Write `"$VAULT_ROOT/people/<slug>/conversations/<date>-<topic>.md"` from
   `templates/conversation.md`, with `person:` linking to `../profile.md`.
4. Fan out actionables/decisions to the buckets (as in Meeting), each with
   `people: ["<link to this person>"]`.
5. Update the person's `profile.md`: add the conversation under `## Conversations` and any
   new open items under `## Open with them`.
6. Update indexes/logs; refresh search.

## Operation: Query

1. Search: `qmd query "<question>" -c "$QMD_COLLECTION" --format json -n 8 --full-path`
   (or grep fallback). Read the top pages in full via their `--full-path`.
2. Answer in plain language, grounded in those pages, citing each with a link in this
   wiki's link style. If results are thin, broaden the search or rephrase.
3. If the answer is substantial and new, offer to save it as a page, then refresh search.

## Operation: Init

- **init project `<name>`** [ONLY IF projects/]: create
  `projects/<slug>/{index.md, overview.md}` from templates; [IF nesting] sub-projects nest
  the same way under `projects/<parent>/<slug>/`. [/IF]
- **init person `<name>`** [ONLY IF people/]: create
  `people/<slug>/{index.md, profile.md, conversations/}` from `templates/person.md`.

Add the new subtree to the parent `index.md` and `log.md`. Register/refresh search
(`qmd update && qmd embed`, or `qmd collection add` if using per-area collections).

## Operation: Lint

Glob all `.md` under `"$VAULT_ROOT"` and check:
- **OKF conformance**: every non-reserved page has parseable frontmatter with a non-empty
  `type`; `index.md`/`log.md` have no frontmatter.
- **Broken links**: links pointing to missing files.
- **Index drift**: pages on disk not listed in their folder's `index.md`.
- **Orphans**: pages with no inbound links.
- **Stale**: pages whose `timestamp` is > 60 days old.
- **Search drift**: `qmd status` shows pending docs.

Present a short health report and offer to fix (add to index, remove dead links,
`qmd update && qmd embed`).

## Operation: Status / Reindex

- **status**: count pages per top-level folder; show last-updated; show `qmd status`.
- **reindex**: `qmd update && qmd embed` (use after editing the vault outside this skill,
  e.g. directly in Obsidian).

---

## Working principles

- **Do the filing; don't make the owner think about structure.** They describe what
  happened; you decide where it goes.
- **Dedup before you create.** Search first; update an existing page rather than duplicating.
- **Capture the why.** A decision page without its reasoning is half a page.
- **Link generously** — more links, better recall. A link to a page that doesn't exist yet
  is fine (it's a TODO marker); create it when the topic comes up.
- **Keep `index.md` and `log.md` current**, and **refresh qmd after every change.**
