# qmd — semantic search backend (optional)

Generated wikis use **qmd** (Quick Markdown Search) for semantic search when it's
available, and fall back to plain `grep`/`Glob` when it isn't. **qmd is never required** —
a wiki is fully usable without it; you only lose meaning-based recall.

Repo: <https://github.com/tobi/qmd>

> This skill ships **no hardcoded paths**. Every vault path below is supplied by the user
> at interview time (shown here as `<VAULT_ROOT>` / `<wiki-name>`). Always double-quote
> the vault path in commands in case it contains spaces.

## Why qmd over grep

`grep` matches literal strings; qmd understands *meaning*. "What did we decide about
real-time pricing?" surfaces the right decision page even when those exact words never
co-occur. qmd is a local, on-device hybrid engine — **BM25 keyword + vector embeddings +
LLM reranking** — storing its index in a local SQLite file. Nothing leaves the machine.

## Detect first (always)

```bash
command -v qmd >/dev/null 2>&1 && echo "qmd available" || echo "qmd absent — grep fallback"
```

If absent: use `Grep`/`Glob` over the vault for this run and tell the user how to enable
qmd later (setup below). **Never block on qmd.**

## Setup (cross-platform; one-time)

```bash
bun install -g @tobilu/qmd      # preferred
# or:
npm install -g @tobilu/qmd      # npm needs Node >= 22
bun pm -g trust --all           # bun only: build native deps (better-sqlite3, node-llama-cpp)
```

The first `qmd embed` downloads local GGUF models (embedding, reranker, query-expansion),
then vectorizes the vault. Subsequent runs are incremental and fast.

## Collection model

Register the vault so it's searchable. Two strategies — the generator picks based on size:

- **Whole-vault** (default for small/medium wikis): one collection for the entire wiki.
- **Per-area** (large wikis): one collection per top-level folder (`people`, `projects`,
  `meetings`, `_shared`, …) so searches can scope with `-c <area>`.

```bash
qmd collection add "<VAULT_ROOT>" --name <wiki-name>
qmd context add qmd://<wiki-name> "<one-line description of this wiki>"
qmd embed -c <wiki-name>
```

## Commands the operating skill uses

```bash
# Hybrid search (BM25 + vector + LLM rerank) — best quality, used by Query
qmd query "<natural-language question>" --format json -n 8 --full-path
qmd query "<question>" -c <area> --format json -n 8 --full-path        # scoped

# Fast BM25 keyword search — used by ingest dedup (no model load, instant)
qmd search "<key terms>" -c <area> --format json -n 5 --full-path

# Semantic-only vector search — concept-level dedup / recall (catches synonyms BM25 misses)
qmd vsearch "<concept phrase>" -c <area> --format json -n 5 --full-path

# Refresh the index after writing/updating/deleting pages (ALWAYS do this)
qmd update && qmd embed

# Index + collection health
qmd status
qmd collection list
```

**Flag notes:**

- `--format json` → ranked results carrying `score`, `snippet`, `file`. `--full-path`
  makes `file` an absolute on-disk path you can hand straight to **Read**.
- `-n` caps results; `--min-score <0-1>` drops weak matches; `--no-rerank` skips the LLM
  rerank (RRF only) for speed.
- The first `qmd query` of a session loads the models and takes a few seconds; later
  queries in the same process are fast. `qmd search`/`vsearch` are lighter.

## Index freshness rule (critical)

The qmd index is a snapshot. **Any time the wiki is written, edited, or deleted, refresh
before the next search, or results go stale:**

```bash
qmd update && qmd embed
```

`qmd update` re-scans collections for new/changed/removed files; `qmd embed` vectorizes
pending docs (incremental — only new/changed). Cheap. This also catches pages edited
directly in Obsidian outside the skill.

## Grep fallback (when qmd is absent)

```bash
# keyword search across the vault
grep -rni "<terms>" "<VAULT_ROOT>" --include="*.md"
```

Or use the `Grep`/`Glob` tools scoped to `<VAULT_ROOT>`. The fallback loses semantic
recall (synonyms, paraphrases) but keeps the wiki fully usable. Offer to set up qmd when
the user wants better recall.

## Optional: keep models resident for heavy sessions

```bash
qmd mcp --http --daemon     # keeps embedding/rerank models loaded across calls
qmd mcp stop                # end the daemon
```
