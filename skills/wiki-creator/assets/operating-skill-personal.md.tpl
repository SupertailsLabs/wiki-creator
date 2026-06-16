<!-- GENERATOR NOTES (delete this whole comment when writing the final SKILL.md):
  • This is the PERSONAL SECOND-BRAIN operating skill (mode: personal).
  • Fill every {{TOKEN}}. • Resolve [IF …] / [ONLY IF …] blocks: keep the block if the
    wiki has that feature, delete it (and the markers) otherwise.
  • Copy the chosen note-templates into  ~/.claude/skills/{{WIKI_NAME}}/templates/  (drop
    the .tpl extension): source, idea, topic, and journal (if used), plus person/project
    if those folders exist.
  • Folder names in the prose (sources/ ideas/ topics/ journal/) are the defaults — if the
    user named them differently (library/, notes/, subjects/, daily/), swap to their names.
  • Keep the final file focused on what THIS wiki has. -->
---
name: {{WIKI_NAME}}
description: |
  {{WIKI_DESCRIPTION}} Operate {{OWNER}}'s second brain — save things they read, watch, or
  listen to (with highlights + a takeaway), capture ideas in their own words, [IF journal/]keep a
  journal, [/IF]and link it all into topics they can find later. Use whenever {{OWNER}} says
  "/{{WIKI_NAME}}", "save this", "add this to my notes", "remember this", "what do I know
  about X", shares an article / video / quote, or jots down an idea — even if they don't say
  the word "wiki".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /{{WIKI_NAME}} — {{OWNER}}'s Second Brain

You maintain {{OWNER}}'s personal knowledge wiki — a "second brain" stored in
[OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) format,
following the [LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
pattern. Things {{OWNER}} reads, watches, and thinks are captured once; you distill them into
short, cross-linked pages — **sources** (with highlights + a takeaway), **idea-notes** (one
thought each), and **topic** hubs — and keep everything searchable. The links between notes
are the whole point: they turn a pile of saved things into a brain {{OWNER}} can think with.

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
(`templates/source.md`, `templates/idea.md`, `templates/topic.md`[IF journal/], `templates/journal.md`[/IF])
and fill its `{{TOKEN}}` slots. **Every page must have a `type`** in its frontmatter — that
is what makes the wiki valid. Reserved files (`index.md`, `log.md`) and the two meta docs
(`README.md`, `SPEC.md`) have no `type`.

Page types in this wiki:

{{TYPE_VOCAB_TABLE}}

## Search — qmd, with grep fallback

Detect once per session: `command -v qmd`. If present, prefer it; if not, use `Grep`/`Glob`
over `"$VAULT_ROOT"` and mention semantic search can be enabled later.

```bash
# best-quality hybrid search (answering "what do I know about X?")
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
| `/{{WIKI_NAME}} save [link/quote/notes]` | **Save** — capture a source you read/watched |
| `/{{WIKI_NAME}} note [thought]` | **Note** — capture one idea in your own words |
| `/{{WIKI_NAME}} journal [entry]` | **Journal** — today's entry [ONLY IF journal/] |
| `/{{WIKI_NAME}} query <question>` | **Query** — search + answer |
| `/{{WIKI_NAME}} topic <name>` | **Topic** — create/grow a subject hub |
| `/{{WIKI_NAME}} lint` | **Lint** — health check |
| `/{{WIKI_NAME}} status` / `reindex` | stats / refresh search index |

---

## Operation: Save (the centerpiece)

Capture something {{OWNER}} read, watched, or listened to as a **source** page.

1. **Get the material.** From the args (a link, a quote, pasted notes) or — if none — ask:
   "Paste the link, a few quotes, or just tell me what it was about."
2. **Identify** a short title, a kebab-case slug, the author and `kind` (article / book /
   video / podcast / paper / thread), and the URL if there is one.
3. **Dedup first** (qmd `search`/`vsearch`, or grep). If a page on the same source exists,
   UPDATE it instead of creating a duplicate.
4. **Write the source page** at `"$VAULT_ROOT/sources/<slug>.md"` from
   `templates/source.md`. How much of the original to keep is **{{TRANSCRIPT_MODE}}**:
   - `distilled-only` → just the **takeaway** (one or two lines, in {{OWNER}}'s words) + a
     few **highlights**; do not keep the full text.
   - `narrative+distilled` → a short summary in the takeaway + the highlights.
   - `raw+distilled` → also keep the full text/clip in a collapsed block at the bottom.
5. **Spin off ideas (optional).** If the source sparked a distinct, reusable thought, create
   an **idea-note** for it (see Note) and link the two. Don't force it — not every source
   needs one.
6. **Link to topics.** Connect the source (and any idea) to the relevant **topic** hub[IF topics/];
   create the topic if it doesn't exist yet (see Topic)[/IF].
7. **Update indexes & logs**; **refresh search** (`qmd update && qmd embed`).
8. **Report** plainly: "Saved *<title>* with 3 highlights, linked to *<topic>*. Want me to
   pull out any of it as its own idea?"

## Operation: Note — capture one idea

1. Get the thought (args or ask). Keep it **atomic**: one idea per page, in {{OWNER}}'s own
   words.
2. **Dedup** — if a near-identical note exists, append/refine it rather than duplicating.
3. Write `"$VAULT_ROOT/ideas/<slug>.md"` from `templates/idea.md`. Set `source:` if
   it came from something saved.
4. **Connect it.** Under `## Connects to`, link related ideas, topics, and sources — be
   generous; a link to a page that doesn't exist yet is a fine TODO marker.
5. Update indexes/logs; refresh search.

## Operation: Journal [ONLY IF journal/]

1. Resolve today's date. Open or create `"$VAULT_ROOT/journal/<YYYY-MM-DD>.md"` from
   `templates/journal.md`.
2. Append what {{OWNER}} tells you. If something in the entry is worth keeping long-term,
   offer to promote it into its own idea-note and link it under `## Worth keeping`.
3. Update the journal `index.md`/`log.md`; refresh search.

## Operation: Ingest (default)

The source is the **current conversation**. Decide what's worth keeping: a thing discussed
that {{OWNER}} read → a source; a conclusion or insight → an idea-note; a day's reflection →
a journal entry [ONLY IF journal/]. Reuse the steps above, then refresh search.

## Operation: Topic — create or grow a hub [ONLY IF topics/]

A topic page gathers everything on one subject. Create
`"$VAULT_ROOT/topics/<slug>.md"` from `templates/topic.md` with a short overview,
then keep its `## Notes` and `## Sources` lists current as you file related pages. Add the
topic to its `index.md`/`log.md`; refresh search.

## Operation: Query

1. Search: `qmd query "<question>" -c "$QMD_COLLECTION" --format json -n 8 --full-path`
   (or grep fallback). Read the top pages in full via their `--full-path`.
2. Answer in plain language, grounded in those pages, citing each with a link in this wiki's
   link style. If results are thin, broaden the search or rephrase.
3. If the answer is a keeper, offer to save it as an idea-note, then refresh search.

## Operation: Lint

Glob all `.md` under `"$VAULT_ROOT"` and check:
- **OKF conformance**: every non-reserved page has parseable frontmatter with a non-empty
  `type`; `index.md`/`log.md` have no frontmatter.
- **Orphans**: idea-notes with no inbound or outbound links (the links are the value — flag
  notes that aren't connected to anything yet).
- **Broken links**, **index drift** (pages not listed in their folder's `index.md`), and
  **search drift** (`qmd status` shows pending docs).

Present a short health report and offer to fix (connect orphans, add to index, refresh qmd).

## Operation: Status / Reindex

- **status**: count pages per top-level folder; show last-updated; show `qmd status`.
- **reindex**: `qmd update && qmd embed` (use after editing the vault outside this skill,
  e.g. directly in Obsidian).

---

## Working principles

- **Do the filing; don't make {{OWNER}} think about structure.** They hand you a link or a
  thought; you decide where it goes and what it connects to.
- **Capture in their words.** A takeaway or idea-note is worthless as a copy-paste — the
  value is {{OWNER}}'s own phrasing of why it matters.
- **Link generously.** More links, better recall. The graph between notes IS the second
  brain. A link to a page that doesn't exist yet is a useful TODO marker — create it later.
- **Dedup before you create.** Search first; grow an existing page rather than duplicating.
- **Keep `index.md` and `log.md` current**, and **refresh qmd after every change.**
