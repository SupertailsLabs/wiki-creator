# The interview — understanding how someone works, thinks, or builds

The whole value of this skill is that the wiki fits the person, not the other way around.
The interview is a **short, friendly, plain-language conversation** — never technical. Aim
for ~6–9 questions across 2–3 batches, then propose a concrete structure.

The very first thing to settle is **what the wiki is for** — that picks one of three tracks,
and everything after branches on it:

- **Work** — meetings, projects, the people you work with. *(mode: `work`)*
- **Personal second brain** — everything you read, think, and want to remember. *(mode: `personal`)*
- **Single project** — document one effort end-to-end. *(mode: `project`)*

## Principles

- **Plain language.** The user is often non-technical (a single-project wiki is the one case
  that's often technical). Never say "frontmatter", "schema", "collection", "kebab-case". Say
  "label", "folder", "the search". Translate silently.
- **Batch, don't interrogate.** Use `AskUserQuestion` with 2–4 questions per round,
  multiple-choice, sensible default first, "Other" always available. 2–3 rounds total.
- **Propose, then confirm.** After enough signal, *show them a structure* and let them react.
  People react to a concrete proposal far better than they answer abstract questions.
- **Use their words.** Capture the exact nouns they use (1:1s, syncs, initiatives, sources,
  notes, gotchas, milestones) and use those as folder/label names. Archetypes are scaffolding;
  their vocabulary is the finish.
- **Defaults are good.** If they're unsure, take the track's default shape and move on — they
  can reshape later with the operating skill's `init` op.

## Round 0 — what is this wiki for? (the router)

Ask this **first**, before anything else. It sets `mode` and decides which track below to run.

> **"What do you want this wiki to hold?"**
> - **My work** — meetings, projects, the people I work with → **Track A** (`mode: work`)
> - **My life** — a personal second brain for what I read, think, and care about → **Track B** (`mode: personal`)
> - **One specific project** — document a single effort end-to-end → **Track C** (`mode: project`)

If the opening message already makes the mode obvious ("document my codebase", "a second
brain for articles I read", "organize my 1:1s"), confirm it in one line instead of asking,
then go straight to that track.

---

## Track A — Work wiki (`mode: work`)

### Round 1 — who they are & how they think

1. **Role & unit of work.** "In a sentence, what's your role, and what's the main *thing*
   your work revolves around?" Offer: "People I manage" · "Projects I'm driving" ·
   "Functions/areas I coordinate" · "A mix of these". → picks the primary axis → archetype 1–4.
2. **People.** "Do you manage or regularly meet specific people you'd want to track
   (reports, founders, key partners)?" → "Direct reports" · "Founders/stakeholders" ·
   "Both" · "Not really". Yes → enable `people/` + conversations.
3. **Meetings.** "How much of your week is meetings you'd want to capture?" → "Lots — they
   drive my work" · "Some key ones" · "Rarely". → sizes the meeting flow.

### Round 2 — structure & distillation (branch on Round 1)

4. **Projects & nesting** *(if projects matter)*: "Do your projects break into sub-projects,
   or are they mostly flat?" → `nesting: true/false`.
5. **Distillation buckets** (multi-select): "When something comes out of a conversation or
   meeting, which of these do you want captured separately?" Let them rename each:
   - "Action items / to-dos" → `actionables` (type: actions / todos / commitments)
   - "Decisions made" → `decisions`
   - "Patterns / playbooks / how-we-do-things" → `patterns`
   - "Results / outcomes / what happened" → `results`
6. **Transcript consumption.** "When you drop in a chat or meeting transcript, what should I
   keep?" → `transcript_mode`:
   - "Short summary + the items" → `distilled-only` (leanest)
   - "Narrative summary AND the extracted items" → `narrative+distilled` (default)
   - "Keep the full raw transcript too, collapsed" → `raw+distilled` (most complete)

### Round 3 — logistics (quick)

7. **Cross-functional.** "Do you work across functions (eng, design, sales, ops) enough to
   want to slice notes by function?" Yes → enable `areas/` + `area` tag.
8. **Where it lives + app.** Default `~/<Name> Wiki`, or inside their Obsidian vault. Obsidian
   user? Still default to portable **relative** links unless they live *entirely* in Obsidian.
   `git` default: **false** (their personal work content).
9. **Vocabulary check** — confirm the exact words for buckets/folders before scaffolding.

---

## Track B — Personal second brain (`mode: personal`)

A second brain is organized around what you *consume and think*, not meetings. The engine is
the same — capture once, distill, cross-link — but the raw input is sources + your own ideas,
and the spine is **sources → idea-notes → topic hubs**.

### Round 1 — what you keep & how you reach for it

1. **What to hold onto** (multi-select → the folders): "What do you most want to keep hold of?"
   - "Things I read / watch / listen to" → `sources` (rename: library, reading, clips)
   - "My own ideas & notes" → `ideas` (rename: notes, thoughts, zettels)
   - "Subjects I'm building knowledge on" → `topics` (rename: subjects)
   - "Areas of my life (health, money, home…)" → `areas`
   - "People in my life" → `people` (light — friends/family, not reports)
   - "A daily/weekly journal" → `journal` (rename: daily, diary)
   - "Personal projects & goals" → `projects`
2. **Organizing instinct** (the primary axis): "When you go looking for something, how do you
   reach for it?" → "By topic/subject" · "By area of life (PARA-style)" · "By date (journal
   first)" · "A mix" (default).

### Round 2 — how you capture & connect

3. **What to keep from a source** (the personal `transcript_mode`): "When you save something
   you read, what should I keep?"
   - "Just my takeaway + a few highlights" → `distilled-only`
   - "A summary + the highlights" → `narrative+distilled` (default)
   - "The full original too, so I never lose it" → `raw+distilled`
4. **Journaling.** "Want a daily/weekly journal built in?" → enables `journal/` (date-named
   entries). Yes also offers a "promote a journal note into its own idea" habit.
5. **How notes relate.** "How do you like your notes to connect?"
   - "Actively link ideas together (Zettelkasten)" → the operating skill cross-links
     aggressively and seeds topic hubs / maps-of-content.
   - "Just file them so they're findable" (default) → lighter linking, lean on search.

### Round 3 — logistics (quick)

6. **Where it lives + app.** Default `~/Second Brain`, or inside their Obsidian vault.
   **This is the audience most likely to live entirely in Obsidian** — offer `[[wikilinks]]`
   here more readily than in other tracks (it's still their call; relative stays the portable
   default).
7. **Privacy.** It's personal → `git` default **false**; say so plainly ("I'll keep this on
   your machine and won't put it online").
8. **Vocabulary check** — "you call them 'notes', not 'idea-notes' — got it."

---

## Track C — Single project (`mode: project`)

One effort, documented end-to-end. The project **is** the vault: an `overview.md` anchor at
the root, with the buckets alongside it (no `projects/` wrapper — that's the portfolio shape,
archetype 2). This is the track most likely to serve a **technical** user (a codebase wiki),
so ask what kind of project up front and pre-pick buckets accordingly.

### Round 1 — what the project is

1. **What & what kind.** "What's the project, in a sentence — and what kind is it?" (free text
   → `wiki_title` + the overview). Kind picks the default bucket vocabulary:
   - "Build / technical (a codebase, a system)" → decisions, patterns, concepts, learnings, references
   - "An initiative or event (a launch, a move, a wedding)" → decisions, tasks, milestones, people, references
   - "Research / writing (a thesis, a report, a book)" → sources, notes, outline, references
2. **Stage.** "Where's it at?" → "Fresh start" · "Mid-flight" · "Wrapping up". → seeds the
   overview `status`; mid-flight → offer to import the decisions-so-far.

### Round 2 — its buckets & shape

3. **What to capture** (multi-select, pre-checked from Round 1's kind): decisions & why ·
   tasks/next actions · patterns/playbooks · learnings/gotchas · key concepts/glossary ·
   references/links/docs · milestones/timeline · people involved (stakeholders/vendors).
4. **Shape.** "Does it split into workstreams / components / chapters?" → flat (default) or
   `nesting: true` (sub-areas *within* the one project).
5. **What feeds it.** "What mostly feeds this wiki?" → "Meetings/standups" · "Reading &
   research" · "My own working log". → flavors the operating skill's `log` op.

### Round 3 — logistics (quick)

6. **Where it lives + git.** For a **technical** project, default *inside the repo*
   (`./docs/wiki` or `./wiki`) and `git` default **true** (it ships with the code). Otherwise
   `~/<Project> Wiki`, `git` false. Link style → **relative** (renders on GitHub; rarely
   wikilink for a project).
7. **Pre-fill the overview?** "Want me to fill the overview/charter from a paragraph you paste
   now?"
8. **Vocabulary check.**

---

## Mapping answers → config JSON (the contract `scripts/scaffold.py` consumes)

```json
{
  "wiki_name": "priya-work",
  "wiki_title": "Priya's Work Wiki",
  "owner": "Priya",
  "vault_root": "~/Documents/Priya Wiki",
  "mode": "work",
  "archetype": "hybrid",
  "link_style": "relative",
  "transcript_mode": "narrative+distilled",
  "folders": ["people", "projects", "meetings", "decisions", "actions", "patterns", "results", "_shared"],
  "type_vocab": {
    "people": "person", "projects": "project", "meetings": "meeting",
    "decisions": "decision", "actions": "action", "patterns": "pattern", "results": "result"
  },
  "nesting": true,
  "areas": [],
  "people_seed": ["asha", "ravi"],
  "projects_seed": ["q3-launch"],
  "qmd": true,
  "git": false
}
```

**`mode`** (`work` | `personal` | `project`, default `work`) is set by Round 0. It drives the
default description, the seeded example pages, and which operating-skill template is used. The
rest of the schema is shared; only the vocabulary and defaults change per track:

| Field | work | personal | project |
|---|---|---|---|
| `folders` (their words) | people, projects, meetings, decisions, actions, patterns, results, _shared | sources, ideas, topics, areas, people, journal, projects | decisions, tasks, patterns, learnings, concepts, references, milestones, people |
| `transcript_mode` | how transcripts are kept | how saved sources are kept | how logged updates are kept |
| default `vault_root` | `~/<Name> Wiki` | `~/Second Brain` (or Obsidian vault) | `./docs/wiki` (technical) else `~/<Project> Wiki` |
| default `link_style` | relative | relative (wikilink if Obsidian-only) | relative |
| default `git` | false | false | true if technical/in-repo, else false |
| extras | `people_seed`, `projects_seed`, `nesting`, `areas` | — | `project_status`, `nesting` (workstreams) |

- `folders` = directory names in the **user's words**; `type_vocab` maps each folder to its
  frontmatter `type` (usually the singular — e.g. `ideas` → `note` if that's what they call
  them). The scaffolder recognizes renamed buckets (a `tasks` folder → the action template, a
  `library` folder → the source template), so use their vocabulary freely.
- Omit folders they didn't want. `wiki_name` = kebab-case slug from `wiki_title`; it is also
  the operating skill's command name and the qmd collection name.
- For `mode: project` the scaffolder writes an `overview.md` anchor at the vault root
  automatically — don't add it to `folders`.
- Defaults: `link_style: relative`, `qmd` = result of `command -v qmd`, and `mode`/`git` per
  the table above.

## Proposing the structure (before any file is written)

Render the tree back in plain text using their words, list the labels, ask for a thumbs-up.
The four work archetypes plus the two new ones (second brain, single project) in
`archetypes.md` are your starting trees — match the mode + answers to one, then personalize.

```
Here's the shape I'd build for you, Gaurav:

  Gaurav's Second Brain/   (in ~/Second Brain)
  ├── sources/   → things you read/watch, with your highlights + a takeaway
  ├── ideas/     → your own notes, one thought per page
  ├── topics/    → hubs that gather everything on a subject
  ├── journal/   → a dated entry whenever you want one
  └── people/    → the people in your life

  Links: Obsidian wikilinks (you live in Obsidian)
  Search: qmd semantic search (installed) ✓
  Kept private on your machine (not in git).

Want me to build this, or tweak anything (names, folders)?
```

Only after a "yes" do you write the config, run `scaffold.py`, and generate the operating
skill. See `SKILL.md` → "Build pipeline" for what happens next (including picking the
mode-specific operating-skill template).
