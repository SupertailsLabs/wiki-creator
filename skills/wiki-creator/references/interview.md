# The interview — understanding how someone works

The whole value of this skill is that the wiki fits the person, not the other way around.
The interview is a **short, friendly, plain-language conversation** — never technical. Aim
for ~6–9 questions across 2–3 batches, then propose a concrete structure.

## Principles

- **Plain language.** The user is often non-technical. Never say "frontmatter", "schema",
  "collection", "kebab-case". Say "label", "folder", "the search". Translate silently.
- **Batch, don't interrogate.** Use `AskUserQuestion` with 2–4 questions per round,
  multiple-choice, sensible default first, "Other" always available. 2–3 rounds total.
- **Propose, then confirm.** After enough signal, *show them a structure* and let them
  react. People react to a concrete proposal far better than they answer abstract questions.
- **Use their words.** Capture the exact nouns they use (1:1s, syncs, initiatives, pods,
  OKRs, clients) and use those as folder/label names. Archetypes are scaffolding; their
  vocabulary is the finish.
- **Defaults are good.** If they're unsure, take the Hybrid archetype and move on — they
  can reshape later with the operating skill's `init` op.

## Round 1 — who they are & how they think

1. **Role & unit of work.** "In a sentence, what's your role, and what's the main *thing*
   your work revolves around?" Offer: "People I manage" · "Projects I'm driving" ·
   "Functions/areas I coordinate" · "A mix of these". → picks the primary axis → archetype.
2. **People.** "Do you manage or regularly meet specific people you'd want to track
   (reports, founders, key partners)?" → "Direct reports" · "Founders/stakeholders" ·
   "Both" · "Not really". Yes → enable `people/` + conversations.
3. **Meetings.** "How much of your week is meetings you'd want to capture?" → "Lots — they
   drive my work" · "Some key ones" · "Rarely". → sizes the meeting flow.

## Round 2 — structure & distillation (branch on Round 1)

4. **Projects & nesting** *(if projects matter)*: "Do your projects break into
   sub-projects, or are they mostly flat?" → `nesting: true/false`.
5. **Distillation buckets** (multi-select): "When something comes out of a conversation or
   meeting, which of these do you want captured separately?" Defines the buckets and their
   `type` names — let them rename each in their words:
   - "Action items / to-dos" → `actionables` (type: actions / todos / commitments)
   - "Decisions made" → `decisions`
   - "Patterns / playbooks / how-we-do-things" → `patterns`
   - "Results / outcomes / what happened" → `results`
6. **Transcript consumption.** "When you drop in a chat or meeting transcript, what should
   I keep?" → `transcript_mode`:
   - "Short summary + the items" → `distilled-only` (leanest)
   - "Narrative summary AND the extracted items" → `narrative+distilled` (default)
   - "Keep the full raw transcript too, collapsed" → `raw+distilled` (most complete)

## Round 3 — logistics (quick)

7. **Cross-functional.** "Do you work across functions (eng, design, sales, ops) enough to
   want to slice notes by function?" Yes → enable `areas/` + `area` tag.
8. **Where it lives + app.** "Where should the wiki live, and do you use Obsidian?"
   - Capture an absolute folder path → `vault_root`. Default suggestion: `~/<Name> Wiki`,
     or inside their Obsidian vault if they use one.
   - Obsidian user? Still default to portable **relative** links (they work great in
     Obsidian — clickable + backlinks + graph). Only switch to `[[wikilinks]]` if they say
     they live *entirely* in Obsidian and want the native graph. → `link_style`.
9. **Vocabulary check** (conversational): confirm the exact words for buckets/folders
   before scaffolding ("you call them 'initiatives', not 'projects' — got it").

## Mapping answers → config JSON (the contract `scripts/scaffold.py` consumes)

```json
{
  "wiki_name": "priya-work",
  "wiki_title": "Priya's Work Wiki",
  "owner": "Priya",
  "vault_root": "~/Documents/Priya Wiki",
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

- `folders` = directory names in the **user's words**; `type_vocab` maps each folder to its
  frontmatter `type` (usually the singular). Both come straight from Round 2/3.
- Omit folders they didn't want (no people → drop `people`; flat → `nesting: false`).
- `wiki_name` = kebab-case slug from `wiki_title`; it is also the operating skill's command
  name and the qmd collection name.
- Defaults: `link_style: relative`, `transcript_mode: narrative+distilled`,
  `qmd` = result of `command -v qmd`, `git: false`.

## Proposing the structure (before any file is written)

Render the tree back in plain text using their words, list the labels, ask for a thumbs-up:

```
Here's the shape I'd build for you, Priya:

  Priya's Work Wiki/   (in ~/Documents/Priya Wiki)
  ├── people/    → one folder per person, with your 1:1s by topic
  │                Asha, Ravi
  ├── projects/  → Q3 Launch  (sub-projects allowed)
  ├── meetings/  → one note per meeting, summarized
  └── from every meeting I'll pull out:
        Actions · Decisions · Patterns · Results

  Links: portable (open in any app — works in Obsidian too)
  Search: qmd semantic search (installed) ✓

Want me to build this, or tweak anything (names, folders)?
```

Only after a "yes" do you write the config, run `scaffold.py`, and generate the operating
skill. See `SKILL.md` → "Build pipeline" for what happens next.
