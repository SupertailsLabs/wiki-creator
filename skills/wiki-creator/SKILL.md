---
name: wiki-creator
description: |
  Create a personalized knowledge wiki for one individual by interviewing them about how they
  work, think, or build, then scaffolding an OKF-conformant wiki PLUS a bespoke operating skill
  to run it day-to-day. Works in three modes: a WORK wiki (meetings, projects, people), a
  PERSONAL SECOND BRAIN (everything you read, think, and want to remember), or a SINGLE-PROJECT
  wiki (document one effort or codebase end-to-end). Use whenever someone wants to set up a wiki,
  a "second brain", a personal knowledge base, a Zettelkasten/notes vault, or a system to
  organize meetings/decisions/people/projects, OR to document a single project — e.g. "create a
  wiki", "build me a second brain", "organize my reading and notes", "set up a Zettelkasten",
  "make a wiki for this codebase/project", "I want to track my 1:1s and decisions". Make sure to
  use this skill whenever the user wants to START or DESIGN a new knowledge system, even if they
  don't say the word "wiki". (To operate an ALREADY-generated wiki day-to-day, use that wiki's
  own skill, not this one.)
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# wiki-creator — generate a personalized knowledge wiki + its operating skill

You interview an individual about how they work, think, or build (usually **non-technical** —
the single-project mode is the one case that's often technical), then build them two things:

1. **A wiki** — a folder of plain-markdown files, organized to *their* mental model, in
   [OKF](references/okf.md) format (portable, opens in any editor or Obsidian), following
   the [LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern
   (raw material → distilled, cross-linked pages → a schema doc).
2. **A bespoke operating skill** named after their wiki (`/<wiki-name>`) that captures
   meetings and 1:1s, distills them into their buckets, searches the knowledge base, and
   keeps it healthy — wired to *their* structure and [qmd](references/qmd.md) search.

The wiki fits the person, not the other way around. Spend your effort on the interview and
on proposing a structure they recognize as *theirs*.

## Reference files (read them at the right moment — don't preload everything)

| File | Read it when |
|---|---|
| [`references/interview.md`](references/interview.md) | running the interview (questions, branching, config schema) |
| [`references/archetypes.md`](references/archetypes.md) | proposing a structure (6 ready trees: 4 work + second-brain + single-project) |
| [`references/okf.md`](references/okf.md) | you need the exact conformance rules |
| [`references/qmd.md`](references/qmd.md) | wiring up or explaining search |
| [`references/archival.md`](references/archival.md) | the never-delete archival/updation model every generated skill inlines |

## Build pipeline

### 1. Interview
Read `references/interview.md` and run it. Use `AskUserQuestion` in 2–3 batched rounds,
plain language, sensible defaults, "Other" always available. **Start with Round 0 — "what is
this wiki for?" — which picks the mode (`work` / `personal` / `project`) and the track to
run.** Then learn that track's specifics: for **work**, the organizing axis (people /
projects / functions / blend), people, meetings, buckets, and transcript handling; for a
**personal second brain**, what they keep (sources / ideas / topics / journal …) and how they
like notes to connect; for a **single project**, what kind it is and which buckets it needs.
Throughout, capture what they *call* things, where the wiki should live, and their link-style
preference.

### 2. Propose a structure — and get a yes
Match their answers to an archetype (`references/archetypes.md`), then render the tree back
**in plain text using their words** and confirm before writing anything (see the example in
`interview.md`). The archetype is a starting point; their vocabulary is the finish.

### 3. Assemble the config JSON
Build the config object (full schema in `references/interview.md`). Key fields: `mode`
(`work` | `personal` | `project` — from Round 0; drives defaults, the seeded examples, and the
operating-skill template), `wiki_name` (kebab-case slug, also the operating skill's command +
qmd collection name), `wiki_title`, `owner`, `vault_root` (absolute path — see the per-mode
defaults in `interview.md`), `link_style` (`relative` default | `wikilink`), `transcript_mode`,
`folders` (their words), `type_vocab` (folder → `type`), plus mode-specific extras
(`people_seed` / `projects_seed` / `nesting` / `areas` for work; `project_status` / `nesting`
for a project). Set `qmd` from a live check:

```bash
command -v qmd >/dev/null 2>&1 && echo true || echo false
```

Create the operating-skill home and save the config there (keeps the vault pure content):

```bash
mkdir -p ~/.claude/skills/<wiki_name>/templates
# write the config to ~/.claude/skills/<wiki_name>/config.json
```

### 4. Scaffold the wiki (deterministic)
Run the scaffolder. Preview first if you like (`--dry-run`), then build for real:

```bash
python3 skills/wiki-creator/scripts/scaffold.py build ~/.claude/skills/<wiki_name>/config.json --dry-run
python3 skills/wiki-creator/scripts/scaffold.py build ~/.claude/skills/<wiki_name>/config.json
```

(Use the path to `scaffold.py` wherever this skill is installed.) It creates the OKF tree
(reserved `index.md`/`log.md` per folder, `SPEC.md`, `README.md`), seeds a couple of
example pages that demonstrate the meeting→buckets flow, registers the qmd collection if
qmd is present, and validates OKF conformance. If validation fails, fix and re-run.

### 5. Generate the bespoke operating skill
Pick the operating-skill template that matches `mode`, fill it, and write the result to
`~/.claude/skills/<wiki_name>/SKILL.md`:

| mode | template |
|---|---|
| `work` | [`assets/operating-skill.md.tpl`](assets/operating-skill.md.tpl) |
| `personal` | [`assets/operating-skill-personal.md.tpl`](assets/operating-skill-personal.md.tpl) |
| `project` | [`assets/operating-skill-project.md.tpl`](assets/operating-skill-project.md.tpl) |

- Substitute every `{{TOKEN}}` (vault root, owner, buckets, type vocabulary, link rule,
  transcript mode, qmd collection name; plus `wiki_title` for the project template).
- Set `{{LINK_RULE}}` to the concrete rule for their `link_style` (relative vs wikilink —
  see `references/okf.md`).
- Resolve the `[IF …]` / `[ONLY IF …]` blocks: keep a block only if the wiki has that feature
  (drop Person if no `people/`, Journal if no `journal/`, Milestone if no `milestones/`, …),
  and delete the marker comments and the leading GENERATOR NOTES comment.
- **Keep the `Archival` section and the new/update/archive classification** in the capture
  op — they apply to every wiki (knowledge is never deleted; see `references/archival.md`).
- If folder names in the template prose don't match the user's words, swap them.
- Copy the note templates the wiki uses so the skill's `templates/<type>.md` references
  resolve (copy each and drop the `.tpl`). By mode, typically:
  - **work**: meeting, decision, actionable, result, pattern, person, conversation, project-overview
  - **personal**: source, idea, topic, journal (+ person / project-overview if those folders exist)
  - **project**: decision, actionable, pattern, milestone, project-overview (learnings / concepts / references use the generic typed page — no template needed)

```bash
# example (personal): copy each template the wiki uses, dropping the .tpl extension
cp skills/wiki-creator/assets/note-templates/source.md.tpl  ~/.claude/skills/<wiki_name>/templates/source.md
cp skills/wiki-creator/assets/note-templates/idea.md.tpl    ~/.claude/skills/<wiki_name>/templates/idea.md
cp skills/wiki-creator/assets/note-templates/topic.md.tpl   ~/.claude/skills/<wiki_name>/templates/topic.md
# …journal.md, and meeting/decision/etc. for other modes, as applicable
```

Confirm the generated `SKILL.md` has valid frontmatter (`name` == `<wiki_name>`, a non-empty
`description`).

### 6. Hand off
Show the user the generated `README.md` from their vault (the plain-language cheat-sheet) and
tell them, in one line, how to start — matched to their mode:
- **work**: *"Type `/<wiki-name> meeting` and paste any notes — I'll file everything for you."*
- **personal**: *"Type `/<wiki-name> save` and paste a link or a quote — I'll keep it with your highlights and link it up."*
- **project**: *"Type `/<wiki-name> log` and tell me what happened — I'll file the decisions, tasks, and learnings."*

If qmd wasn't available, mention they can enable semantic search later (point to
`references/qmd.md`). Do **not** offer to commit their wiki to git unless they ask — it's
their personal content (the one exception: a single-project wiki living *inside* a repo is
usually meant to be committed with the code).

## Other invocations

- `wiki-creator validate <vault>` → `python3 scripts/scaffold.py validate <vault>` (OKF check).
- `wiki-creator demo` → build a throwaway example into `/tmp` with `--dry-run` off so the
  user can see what they'll get before committing to the interview.

## Principles

- **Plain language always.** Never expose "frontmatter", "schema", "collection". Translate.
- **Propose, don't interrogate.** People react to a concrete structure far better than they
  answer abstract questions. Get to a preview fast.
- **Their words win.** Folders and type labels use the nouns they actually use.
- **Portable by default.** Relative links + OKF mean the wiki outlives any single app. Only
  choose Obsidian wikilinks for someone who lives entirely in Obsidian.
- **Knowledge is never deleted.** Generated skills *update* pages in place and *archive*
  superseded ones (retire-in-place, reversible) rather than deleting — the model is built into
  all three operating-skill templates; see `references/archival.md`.
- **The generated skill is self-contained.** After generation, the user's wiki is operated
  entirely by `/<wiki-name>` — this generator's job is done.
