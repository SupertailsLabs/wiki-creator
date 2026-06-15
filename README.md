# wiki-creator

**Interview anyone about how they work, then generate them a personalized knowledge wiki —
and a custom skill to run it.**

`wiki-creator` is a [Claude Code](https://claude.com/claude-code) skill that builds *other*
skills. Point it at a person (technical or not) and it:

1. **Interviews them** in plain language about how they work — projects, the people they
   manage, meetings, how they like to capture things.
2. **Scaffolds a wiki** organized to *their* mental model: a folder of plain-markdown files
   in [Open Knowledge Format (OKF)](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md),
   following Andrej Karpathy's [LLM-Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
   pattern.
3. **Generates a bespoke operating skill** (`/<their-wiki>`) that captures meetings & 1:1s,
   distills them into their buckets (actions · decisions · patterns · results), searches the
   knowledge base, and keeps it healthy.

The result is portable: the wiki is just markdown, so it opens in any editor, on GitHub, or
in Obsidian (with clickable backlinks + graph).

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

- **A wiki** at a folder they choose, e.g.:
  ```
  My Work Wiki/
  ├── SPEC.md  README.md  index.md  log.md
  ├── people/<name>/{profile.md, conversations/}
  ├── projects/<name>/{overview.md, …}
  ├── meetings/<date>-<slug>.md
  └── decisions/  actionables/  patterns/  results/
  ```
- **A skill** at `~/.claude/skills/<their-wiki>/`, invoked as `/<their-wiki>`, to capture
  meetings, log 1:1s, ask questions, and lint.

The meeting flow is the centerpiece: one meeting note fans out into action / decision /
pattern / result pages, each linking back to the meeting and its participants — and results
link back to the decision or action they came from, so you can trace **decision → outcome**.

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
