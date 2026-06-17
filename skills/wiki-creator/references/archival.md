# Archival & updation — keeping a generated wiki current without losing history

A generated wiki accumulates knowledge over time, and some of it goes stale or gets
superseded. The rule, borrowed from a battle-tested R&D wiki skill, is simple:

> **Knowledge is never deleted. It is *updated* in place, or *archived* (retired in place).**

This model is **inlined into all three operating-skill templates** (`operating-skill.md.tpl`,
`operating-skill-personal.md.tpl`, `operating-skill-project.md.tpl`) because a generated skill
is self-contained — it can't read this file. This reference is the canonical description; keep
the three templates in sync with it. The generated `SPEC.md` also explains archiving to the
end user (see `assets/spec.md.tpl`), and `okf.md` lists the two frontmatter keys.

## The three-way classification (during capture)

Every capture operation (Meeting / Save / Log / Ingest) already de-dups before writing. That
dedup step classifies each item three ways instead of two:

- **NEW** — no existing page on this topic → create one.
- **UPDATE** — a page exists and the new material *adds* to it → append an `## Update — <date>`
  section and bump `timestamp`. (This is also how a **stale** page gets refreshed: a stale hit
  with newer info is just an UPDATE, not a new page.)
- **ARCHIVE** — an existing page is *superseded or contradicted* (the old approach is dead, a
  decision was reversed) → archive the old page and create the replacement as a NEW page.

Never duplicate; never silently delete — retirement is always ARCHIVE. The plan preview shown
to the user before writing lists **new / updated / archived** so nothing is retired silently.

## The archival convention (retire in place)

Archiving a page must not move or delete the file — that would break inbound links. Instead:

1. **Frontmatter** — add `archived: <YYYY-MM-DD>` and
   `archived_reason: "<one line — e.g. superseded by <link>>"`. Leave `type` and the body
   intact. If the page has a lifecycle `status` (e.g. a decision), also flip it to `superseded`.
2. **Index** — in the folder's `index.md`, move the page's bullet out of the active list into
   an `## Archived` section (create it if missing): `<link> — <reason> (archived <date>)`.
3. **Supersession trail** — in the *superseding* page's `## Related` (or `## Connects to`),
   link the archived page, so the history is navigable both ways.

The page keeps its path: existing links still resolve, and it stays searchable. It just carries
the `archived` marker. **Fully reversible** — drop the two keys and move the index bullet back.
All links use the wiki's chosen link style (relative or wikilink).

## How the other operations treat archived pages

- **Query** — skip or de-prioritize pages whose frontmatter has `archived:`; they're historical.
  Cite one only if specifically relevant, and mark it `(archived)`.
- **Lint** — *report* archived/stale/superseded pages (and check that each archived page sits
  under an `## Archived` section with both keys), but **never** archive, delete, or rewrite
  content. Archival only ever happens through a capture op's confirmation-gated plan.
- **log.md** — record archival alongside new/updated entries:
  `Archived: <slug> — superseded by <slug>`.

## Why retire-in-place instead of a separate `archive/` folder

Moving a superseded page into an `archive/` directory would break every `[[wikilink]]` or
relative link pointing at it, and scatter a topic's history across two locations. Retiring in
place keeps the knowledge graph intact and the supersession trail one hop away, while the
`archived` frontmatter + the index `## Archived` section keep active and historical knowledge
clearly separated. It is also trivially reversible.
