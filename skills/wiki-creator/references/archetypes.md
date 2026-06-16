# Wiki structure archetypes

Six starting points the interview uses to anchor the conversation, in three families set by
Round 0's mode: **work** (1–4), **personal second brain** (5), **single project** (6). **They
are not rigid templates** — every archetype gets renamed, trimmed, and extended from the
user's own answers (their vocabulary, their buckets). Show the closest archetype as a concrete
preview, then personalize.

All archetypes share the OKF spine (`index.md` + `log.md` at each level, plus `SPEC.md`
and `README.md` at the root). The work family differs in the **primary organizing axis** —
the first thing the person thinks in; the other two families differ in what *feeds* the wiki
(sources & ideas; one project's progress).

---

## 1. People-centric Manager

**Primary axis: the people you manage / meet.** Best for managers, founders, chiefs of
staff, People/HR leads — anyone whose work is organized around *who* more than *what*.

```
<vault>/
├── SPEC.md  README.md  index.md  log.md
├── people/
│   ├── index.md
│   └── <person>/
│       ├── index.md
│       ├── profile.md              # type: person — role, reporting line, context, goals
│       └── conversations/
│           └── 2026-06-15-career-growth.md   # type: conversation — 1:1s/syncs by topic
├── meetings/                       # group meetings (type: meeting)
├── decisions/  actionables/  patterns/  results/
└── _shared/                        # team norms, glossary, processes
```

Signature move: a 1:1 becomes a `conversations/<date>-<topic>.md` under that person, and
any actions/decisions from it fan out to the buckets with a `people:` link back. You can
answer both "what have I discussed with Asha about growth?" and "what did I commit to in
last week's 1:1s?" from the same graph.

Type vocab: `person`, `conversation`, `meeting`, `decision`, `action`, `pattern`, `result`.

---

## 2. Project / Sub-project IC

**Primary axis: projects, optionally nested into sub-projects.** Best for individual
contributors, PMs, engineers, researchers, consultants — work organized around *what*
you're building.

```
<vault>/
├── SPEC.md  README.md  index.md  log.md
├── projects/
│   ├── index.md
│   └── <project>/
│       ├── index.md
│       ├── overview.md             # type: project — goal, status, stakeholders
│       ├── decisions/ patterns/ learnings/ references/
│       └── <sub-project>/          # optional nesting (same shape, own index.md)
│           ├── index.md  overview.md
│           └── decisions/ …
├── meetings/
└── _shared/
```

Signature move: per-project buckets keep knowledge local to the project; `_shared/` holds
cross-project concepts. Mirrors the LLM-Wiki "decisions / patterns / concepts / learnings"
discipline. Sub-projects nest arbitrarily — each level gets its own `index.md`.

Type vocab: `project`, `decision`, `pattern`, `learning`, `reference`, `meeting`.

---

## 3. Cross-functional Lead

**Primary axis: functions / areas you coordinate across.** Best for ops leaders, GMs,
program managers, founders wearing many hats — work organized around *which part of the
org/business*.

```
<vault>/
├── SPEC.md  README.md  index.md  log.md
├── areas/
│   ├── index.md
│   ├── engineering/   {index.md, notes…}     # type: area
│   ├── design/
│   ├── sales/
│   └── ops/
├── meetings/                       # each meeting tagged with its function
├── decisions/  actionables/  patterns/  results/
├── people/                         # optional, lighter than archetype 1
└── _shared/
```

Signature move: every concept carries an `area` tag (or lives under `areas/<fn>/`), so you
can slice the wiki by function — "all open actions in ops", "every pricing decision across
sales + finance".

Type vocab: `area`, `meeting`, `decision`, `action`, `pattern`, `result`, `person`.

---

## 4. Hybrid (people + projects + meetings)

**Primary axis: a blend** — most real work is a mix. Best when someone says "I manage
people AND run projects AND sit in a lot of founder meetings." The richest default and the
most common pick.

```
<vault>/
├── SPEC.md  README.md  index.md  log.md
├── people/<person>/{profile.md, conversations/}
├── projects/<project>/{overview.md, …, <sub-project>/}
├── meetings/<date>-<slug>.md
├── decisions/  actionables/  patterns/  results/
├── areas/            # optional cross-functional tagging
└── _shared/
```

Signature move: the buckets are the shared spine; people, projects, and meetings are three
lenses onto the same distilled knowledge. A founder sync (meeting) produces actions
(bucket) owned by people (people/) that belong to a project (projects/). Everything
cross-links.

Type vocab: `person`, `conversation`, `project`, `meeting`, `decision`, `action`,
`pattern`, `result`.

---

## 5. Personal Second Brain  *(mode: personal)*

**Primary axis: what you read and think.** Best for anyone building a personal knowledge base
— a "second brain" for articles, books, videos, and your own ideas, kept for life, not for
work. The archetype most likely to live entirely inside Obsidian.

```
<vault>/
├── SPEC.md  README.md  index.md  log.md
├── sources/        # type: source — a thing you read/watched, with highlights + a takeaway
│   └── <slug>.md
├── ideas/          # type: idea (often renamed `note`) — one thought per page, in your words
│   └── <slug>.md
├── topics/         # type: topic — hub pages that gather everything on a subject
│   └── <slug>.md
├── journal/        # optional — dated entries (YYYY-MM-DD.md)
├── areas/          # optional — areas of life (health, money, home…)
├── people/         # optional, light — friends/family, not reports
└── projects/       # optional — personal projects & goals
```

Signature move: you save a **source** (highlights + your one-line takeaway), it sparks one or
more atomic **idea-notes**, and both link into **topic** hubs — so the brain grows as a
connected graph you can think with, not a folder of clippings. "Capture → connect" replaces
the work family's "meeting → fan-out."

Type vocab: `source`, `idea` (often `note`), `topic`, `journal`, `area`, `person`, `project`.

---

## 6. Single Project  *(mode: project)*

**Primary axis: one effort, documented end-to-end.** Best for a single codebase, initiative,
event, or piece of research. The project *is* the vault — `overview.md` is the anchor and the
buckets sit at the root (no `projects/` wrapper; that's archetype 2's portfolio shape). The
track most likely to serve a **technical** user.

```
<vault>/                          # the vault IS the project
├── SPEC.md  README.md  index.md  log.md
├── overview.md                   # type: project — what it is, goal, status, scope (the anchor)
├── decisions/                    # type: decision — what was chosen and why
├── tasks/                        # type: task — next actions  (rename of actionables)
├── patterns/                     # type: pattern — playbooks / how-we-do-it
├── learnings/                    # type: learning — gotchas and lessons
├── concepts/                     # type: concept — glossary / key ideas
├── references/                   # type: reference — links, docs, source material
├── milestones/                   # optional — type: milestone — timeline
└── <workstream>/                 # optional nesting — a sub-area with its own buckets
```

Signature move: every page links back to the **overview** and to whatever it came from, so
the project's reasoning is never lost; `overview.md` stays current as the single front door.
Mirrors the LLM-Wiki "decisions / patterns / concepts / learnings" discipline for one effort.
Buckets are pre-picked by kind — technical (decisions/patterns/concepts/learnings/references),
event (decisions/tasks/milestones/people), or research (sources/notes/outline/references).

Type vocab: `project` (the overview), `decision`, `task`, `pattern`, `learning`, `concept`,
`reference`, `milestone`.

---

## Choosing & personalizing

1. **Round 0's mode picks the family first:** `work` → archetypes 1–4, `personal` →
   archetype 5, `project` → archetype 6. Within the work family, the "primary axis" answer
   maps directly: people → 1, projects → 2, functions → 3, blend → 4.
2. Show the matched tree as a **plain-text preview**, using the user's own words for folder
   and `type` names (rename `actionables/` → `actions/`, `ideas/` → `notes/`, …).
3. Toggle folders on/off from their answers (no direct reports → drop `people/`; no journal →
   drop `journal/`; flat project → no workstreams).
4. Confirm before scaffolding. The archetype is a starting point, not a cage — the operating
   skill's `init` op adds projects / people / topics / workstreams later.
