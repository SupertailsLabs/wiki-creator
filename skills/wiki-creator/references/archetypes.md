# Wiki structure archetypes

Four starting points the interview uses to anchor the conversation. **They are not rigid
templates** — every archetype gets renamed, trimmed, and extended from the user's own
answers (their vocabulary, their buckets). Show the closest archetype as a concrete
preview, then personalize.

All archetypes share the OKF spine (`index.md` + `log.md` at each level, plus `SPEC.md`
and `README.md` at the root) and the four distillation buckets unless the user opts out.
They differ in the **primary organizing axis** — the first thing the person thinks in.

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

## Choosing & personalizing

1. The interview's "primary axis" answer maps directly to an archetype: people → 1,
   projects → 2, functions → 3, blend → 4.
2. Show the matched tree as a **plain-text preview**, using the user's own words for folder
   and `type` names (rename `actionables/` → `actions/`, `conversations/` → `1-1s/`, …).
3. Toggle folders on/off from their answers (no direct reports → drop `people/`; a single
   project → drop the `projects/` wrapper and put buckets at the root).
4. Confirm before scaffolding. The archetype is a starting point, not a cage — the
   operating skill's `init` op adds projects/people later.
