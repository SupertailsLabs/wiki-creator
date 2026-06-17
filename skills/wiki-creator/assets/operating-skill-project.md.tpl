<!-- GENERATOR NOTES (delete this whole comment when writing the final SKILL.md):
  • This is the SINGLE-PROJECT operating skill (mode: project). The vault IS the project:
    buckets live at the root and `overview.md` is the anchor page.
  • Fill every {{TOKEN}}. • Resolve [IF …] / [ONLY IF …] blocks: keep the block if the
    wiki has that feature, delete it (and the markers) otherwise.
  • Copy the chosen note-templates into  ~/.claude/skills/{{WIKI_NAME}}/templates/  (drop
    the .tpl extension): the buckets this project uses — decision, actionable (tasks),
    pattern, milestone, plus the generic page for learnings/concepts/references.
  • Folder names in the prose (decisions/ tasks/ learnings/ …) are the defaults — swap to
    the user's actual names. Keep the final file focused on what THIS wiki has. -->
---
name: {{WIKI_NAME}}
description: |
  {{WIKI_DESCRIPTION}} Operate the working wiki for this project — log progress and the
  decisions behind it, capture learnings, gotchas, and references, [IF milestones/]track milestones,
  [/IF]and answer questions about the project later. Use whenever {{OWNER}} says
  "/{{WIKI_NAME}}", "log this", "record this decision", "note this learning", "what did we
  decide about X", or is working on this project and wants to capture or recall something —
  even if they don't say the word "wiki".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /{{WIKI_NAME}} — the wiki for {{WIKI_TITLE}}

You maintain the working wiki for one project, stored in
[OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) format,
following the [LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
pattern. The vault **is** the project: `overview.md` at the root is the anchor (what it is,
its goal, where it stands), and the buckets — {{BUCKETS}} — sit alongside it. Raw material
(a working session, a meeting about the project, something read) is captured once; you
distill the useful parts into short, cross-linked pages, each pointing back to where it came
from so the reasoning is never lost.

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
(`templates/decision.md`, `templates/actionable.md`, `templates/pattern.md`[IF milestones/],
`templates/milestone.md`[/IF]) and fill its `{{TOKEN}}` slots. Learnings, concepts, and
references use the generic typed page (a `type`, a title, a body, and `## Related` links).
**Every page must have a `type`** in its frontmatter — that is what makes the wiki valid.
Reserved files (`index.md`, `log.md`) and the meta docs (`README.md`, `SPEC.md`, `overview.md`
carries `type: project`) follow their own rules.

Page types in this wiki:

{{TYPE_VOCAB_TABLE}}

## Search — qmd, with grep fallback

Detect once per session: `command -v qmd`. If present, prefer it; if not, use `Grep`/`Glob`
over `"$VAULT_ROOT"` and mention semantic search can be enabled later.

```bash
# best-quality hybrid search (answering "why did we decide X?")
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
| `/{{WIKI_NAME}}` or `/{{WIKI_NAME}} ingest` | **Ingest** — distill the conversation (and archive/refresh superseded pages) |
| `/{{WIKI_NAME}} log [paste]` | **Log** — distill a session / meeting / update |
| `/{{WIKI_NAME}} query <question>` | **Query** — search + answer |
| `/{{WIKI_NAME}} milestone <name>` | **Milestone** — add/update a milestone [ONLY IF milestones/] |
| `/{{WIKI_NAME}} init <workstream>` | **Init** — add a workstream subtree [ONLY IF nesting] |
| `/{{WIKI_NAME}} lint` | **Lint** — health check |
| `/{{WIKI_NAME}} status` / `reindex` | stats / refresh search index |

---

## Operation: Log (the centerpiece)

Distill a working session, a meeting about the project, or something read into the project's
buckets.

1. **Get the material.** From the args, the pasted notes/transcript, or — if neither — ask:
   "What happened? Paste notes, or just tell me." [IF milestones/]Note which milestone it relates to,
   if any.[/IF]
2. **Fan out** the useful parts into the buckets — {{BUCKETS}}. For EACH item:
   - **Dedup, then classify** (qmd `search`/`vsearch`, or grep): **NEW** (no match → create),
     **UPDATE** (same topic, this *adds* to it → append an `## Update — <date>` section and
     bump `timestamp`), or **ARCHIVE** (this *supersedes* the old page — e.g. a reversed
     decision or dead approach → archive it per **Archival** below and create the replacement
     as NEW). Never duplicate; never silently delete.
   - For a NEW page, create it from the matching template (`decisions/`, `tasks/`,
     `patterns/`, `learnings/`, `concepts/`, `references/`[IF milestones/], `milestones/`[/IF]).
   - Set `source:` to where it came from (the session/meeting, or a link to the overview).
   - **Decisions** capture what was chosen **and why** — a decision without its reasoning is
     half a page.
3. **Keep the overview current.** Update `overview.md`: add notable decisions under
   `## Key decisions`, open work under `## Open actionables`, and refresh `## Status` if the
   project moved.
4. **Update indexes & logs**: add each new page to its folder's `index.md` (move any archived
   page's bullet to that index's `## Archived` section); append a dated line to each touched
   `log.md` and the root `log.md`, recording UPDATEs and ARCHIVEs (e.g. `Archived: <slug> —
   superseded by <slug>`).
5. **Refresh search**: `qmd update && qmd embed` (if qmd present).
6. **Report** plainly: "Logged it — 1 decision, 2 tasks, 1 learning, and bumped the overview
   status. Anything else?"

Keep friction low: show a 2–4 line preview of what you'll file — **new / updated / archived**
— then proceed. Only stop to ask if something is genuinely ambiguous (including whether an old
page is truly superseded).

## Operation: Ingest (default)

Same as Log, but the source is the **current conversation** rather than a pasted update.
Reuse steps 2–6 above.

## Archival — retire superseded knowledge, never delete

**Nothing is ever deleted.** When new material supersedes or contradicts an existing page
(a reversed decision, a dead approach), *archive* the old page — retire it in place so the
project's history and the links into it survive.

To archive a page (never move or delete the file — that breaks inbound links):
1. Add two keys to its frontmatter: `archived: <YYYY-MM-DD>` and
   `archived_reason: "<one line — e.g. superseded by <link to the new page>>"`. Leave `type`
   and the body intact. (For a decision, also set `status: superseded`.)
2. In the folder's `index.md`, move its bullet out of the active list into an `## Archived`
   section (create it if missing): `<link to page> — <reason> (archived <date>)`.
3. In the superseding page's `## Related`, link the archived page, so the supersession trail
   is preserved.

The page keeps its path — existing links still resolve and it stays searchable — but now
carries the `archived` marker. **Fully reversible:** drop the two keys and move the index
bullet back. Use this wiki's link style (relative or wikilink) for every link above.

## Operation: Query

1. Search: `qmd query "<question>" -c "$QMD_COLLECTION" --format json -n 8 --full-path`
   (or grep fallback). Read the top pages in full via their `--full-path`. The overview is a
   good first stop for "where does the project stand?" questions.
2. **Skip or de-prioritize pages whose frontmatter has `archived:`** — they're historical;
   cite one only if specifically relevant, and mark it `(archived)`.
3. Answer in plain language, grounded in those pages, citing each with a link in this wiki's
   link style. If results are thin, broaden the search or rephrase.
4. If the answer is substantial and new, offer to save it (usually a learning or a decision),
   then refresh search.

## Operation: Milestone [ONLY IF milestones/]

Create or update `"$VAULT_ROOT/milestones/<slug>.md"` from `templates/milestone.md` (status:
planned / in-progress / hit / missed / slipped, with a target `due:` date). Link the
decisions and tasks tied to it. Update the milestones `index.md`/`log.md`; refresh search.

## Operation: Init — add a workstream [ONLY IF nesting]

Create a sub-area under the project (e.g. `<workstream>/` with its own `index.md` and the
buckets it needs). Add it to the root `index.md` and `log.md`; refresh search.

## Operation: Lint

Glob all `.md` under `"$VAULT_ROOT"` and check:
- **OKF conformance**: every non-reserved page has parseable frontmatter with a non-empty
  `type`; `index.md`/`log.md` have no frontmatter.
- **Overview drift**: decisions/tasks on disk that the overview doesn't reference yet.
- **Broken links**, **index drift** (pages not listed in their folder's `index.md`),
  **stale** open tasks (`timestamp` > 30 days), and **search drift** (`qmd status`).
- **Archived pages**: each should sit under an `## Archived` section in its `index.md` and
  carry both `archived` and `archived_reason` keys.

Present a short health report and offer to fix the *structural* issues (update the overview,
add to index, move archived bullets, refresh qmd). **Lint never archives, deletes, or rewrites
content** — it reports stale/superseded pages and points to `/{{WIKI_NAME}}` (Log/Ingest),
which handles archival under its confirmation-gated plan.

## Operation: Status / Reindex

- **status**: count pages per top-level folder; show the overview's `status`; show `qmd status`.
- **reindex**: `qmd update && qmd embed` (use after editing the vault outside this skill).

---

## Working principles

- **The overview is the front door.** Keep it honest and current — goal, status, key
  decisions, open work. Anyone (including future-you) should grasp the project from it alone.
- **Capture the why.** Decisions and learnings are the project's memory; record the reasoning,
  not just the outcome.
- **Dedup before you create.** Search first; update an existing page rather than duplicating.
- **Never delete — archive.** A reversed decision or dead approach is retired in place (see
  Archival), not removed — the project's history is part of its value.
- **Link generously** — every page should point back to where it came from. A link to a page
  that doesn't exist yet is a fine TODO marker.
- **Keep `index.md` and `log.md` current**, and **refresh qmd after every change.**
