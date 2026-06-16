# wiki-creator

**Interview anyone about how they work, think, or build, then generate them a personalized
knowledge wiki — and a custom skill to run it.**

`wiki-creator` is a [Claude Code](https://claude.com/claude-code) skill that builds *other*
skills. Point it at a person (technical or not) and it:

1. **Interviews them** in plain language — starting with one question: is this for their
   **work**, a **personal second brain**, or a **single project**?
2. **Scaffolds a wiki** organized to *their* mental model: a folder of plain-markdown files
   in [Open Knowledge Format (OKF)](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md),
   following Andrej Karpathy's [LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
   pattern.
3. **Generates a bespoke operating skill** (`/<their-wiki>`) that captures their raw material —
   meetings, things they read, or project updates — distills it into their buckets, searches
   the knowledge base, and keeps it healthy.

The result is portable: the wiki is just markdown, so it opens in any editor, on GitHub, or
in Obsidian (with clickable backlinks + graph).

## Three modes

One question up front — *what is this wiki for?* — picks the shape:

- **Work** — meetings, projects, and the people you work with. A meeting fans out into
  actions · decisions · patterns · results, all cross-linked.
- **Personal second brain** — everything you read, watch, and think. Sources (kept with your
  highlights + a one-line takeaway) spark atomic idea-notes that link into topic hubs.
- **Single project** — document one effort or codebase end-to-end. An `overview.md` anchor
  plus decisions · learnings · patterns · references, happy to live inside the repo.

## Why

Most note systems force your brain into someone else's folders. `wiki-creator` flips it: the
structure is designed around how *you* actually work, and an AI does the filing — turning
each meeting or transcript into short, cross-linked pages you can actually find later.

It composes three ideas:

- **[LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (Karpathy)** —
  raw material → an LLM-maintained layer of distilled, linked pages → a schema doc; with
  Ingest / Query / Lint operations.
- **[OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
  (Google Cloud)** — a minimal, portable, tooling-agnostic markdown format: every page has a
  `type`, reserved `index.md` / `log.md`, graceful degradation.
- **[qmd](https://github.com/tobi/qmd)** — optional local semantic search (BM25 + vectors +
  rerank), so you can ask your wiki questions in plain language. Falls back to keyword search.

## What it generates

Running `/wiki-creator` produces, for the end user:

- **A wiki** at a folder they choose, shaped by the mode — e.g.:
  ```
  Work                          Second brain              Single project
  My Work Wiki/                 My Second Brain/          Payments Service/
  ├── people/<name>/…           ├── sources/<slug>.md     ├── overview.md
  ├── projects/<name>/…         ├── ideas/<slug>.md       ├── decisions/
  ├── meetings/<date>-…         ├── topics/<slug>.md      ├── learnings/
  └── decisions/ actionables/   ├── journal/<date>.md     ├── patterns/
      patterns/ results/        └── people/  areas/       └── concepts/ references/
  ```
  (Every wiki also gets the OKF spine: `SPEC.md`, `README.md`, and an `index.md` + `log.md`
  per folder.)
- **A skill** at `~/.claude/skills/<their-wiki>/`, invoked as `/<their-wiki>`, to capture raw
  material, ask questions, and lint — with operations matched to the mode (`meeting` /
  `save` + `note` / `log`).

Each mode has a signature flow. **Work**: one meeting note fans out into action / decision /
pattern / result pages, and results link back to the decision they came from, so you can
trace **decision → outcome**. **Second brain**: a saved source sparks atomic idea-notes that
link into topic hubs — capture → connect. **Single project**: every page links back to the
`overview.md` anchor and to what it came from, so the project's reasoning is never lost.

## Install

A personal-scope Claude Code skill — copy it into your skills directory:

```bash
git clone https://github.com/<you>/wiki-creator
cp -r wiki-creator/skills/wiki-creator ~/.claude/skills/
```

Then, in Claude Code:

```
/wiki-creator
```

## Requirements

- **[Claude Code](https://claude.com/claude-code)** (or a compatible agent that loads skills).
- **Python 3** (standard library only — used by the deterministic scaffolder).
- **Optional: [qmd](https://github.com/tobi/qmd)** for semantic search:
  ```bash
  bun install -g @tobilu/qmd     # or: npm install -g @tobilu/qmd  (Node >= 22)
  ```
  Without it, search falls back to keyword matching — everything else works.

## Repo layout

```
wiki-creator/
├── README.md  LICENSE  .gitignore
└── skills/wiki-creator/
    ├── SKILL.md              # the generator (interview + build pipeline)
    ├── references/           # okf · qmd · interview · archetypes
    ├── assets/               # templates for the vault + the generated operating skill
    ├── scripts/scaffold.py   # deterministic OKF scaffolder + validator (stdlib only)
    └── evals/evals.json      # trigger tests
```

## Credits

- The **LLM-Wiki** concept — Andrej Karpathy ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)).
- The **Open Knowledge Format** — Google Cloud Platform ([SPEC](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)).
- **qmd** — Tobias Lütke ([repo](https://github.com/tobi/qmd)).

`wiki-creator` is original work composing these ideas into a generator.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
