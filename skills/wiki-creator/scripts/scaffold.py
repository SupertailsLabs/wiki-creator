#!/usr/bin/env python3
"""
scaffold.py — deterministic OKF wiki scaffolder for the wiki-creator skill.

Builds a personalized, OKF-conformant knowledge wiki from a config JSON produced by the
interview, and validates conformance. Stdlib only; no network. Templates are read from
../assets relative to this file, so the script is portable wherever the skill folder lives.

Usage:
  python3 scaffold.py build <config.json> [--dry-run] [--today YYYY-MM-DD]
  python3 scaffold.py validate <vault_root>

Config schema: see ../references/interview.md ("Mapping answers -> config JSON").
Exit codes: 0 ok; 1 validation failure or error; 2 bad usage.
"""
from __future__ import annotations

import datetime as _dt
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ASSETS = HERE.parent / "assets"
NOTE_TPL = ASSETS / "note-templates"

RESERVED = {"index.md", "log.md"}   # OKF reserved files: no frontmatter
META = {"README.md", "SPEC.md"}     # meta docs: exempt from the type requirement

# Map a folder/type word (lowercased) to a canonical category so we know which note
# template fits, even when the user renamed the bucket (e.g. "todos" -> action).
CANON = {
    "decision": "decision", "decisions": "decision",
    "action": "action", "actions": "action", "actionable": "action",
    "actionables": "action", "todo": "action", "todos": "action",
    "task": "action", "tasks": "action", "commitment": "action", "commitments": "action",
    "pattern": "pattern", "patterns": "pattern", "playbook": "pattern", "playbooks": "pattern",
    "result": "result", "results": "result", "outcome": "result", "outcomes": "result",
    "meeting": "meeting", "meetings": "meeting", "sync": "meeting", "syncs": "meeting",
    "call": "meeting", "calls": "meeting",
    "person": "person", "people": "person",
    "project": "project", "projects": "project",
    "initiative": "project", "initiatives": "project",
    "area": "topic", "areas": "topic", "moc": "topic",
    "concept": "note", "concepts": "note", "learning": "note", "learnings": "note",
    "reference": "note", "references": "note", "_shared": "note", "shared": "note",
    # personal second-brain & single-project vocab
    "source": "source", "sources": "source", "clip": "source", "clips": "source",
    "highlight": "source", "highlights": "source", "library": "source",
    "article": "source", "articles": "source", "reading": "source", "read": "source",
    "book": "source", "books": "source", "bookmark": "source", "bookmarks": "source",
    "idea": "idea", "ideas": "idea", "note": "idea", "notes": "idea",
    "thought": "idea", "thoughts": "idea", "zettel": "idea",
    "topic": "topic", "topics": "topic", "subject": "topic", "subjects": "topic",
    "journal": "journal", "journals": "journal", "daily": "journal", "diary": "journal",
    "entry": "journal", "entries": "journal", "log-entry": "journal",
    "milestone": "milestone", "milestones": "milestone",
}

TEMPLATE_FILE = {
    "person": "person.md.tpl",
    "conversation": "conversation.md.tpl",
    "meeting": "meeting.md.tpl",
    "decision": "decision.md.tpl",
    "action": "actionable.md.tpl",
    "pattern": "pattern.md.tpl",
    "result": "result.md.tpl",
    "project": "project-overview.md.tpl",
    "source": "source.md.tpl",
    "idea": "idea.md.tpl",
    "topic": "topic.md.tpl",
    "journal": "journal.md.tpl",
    "milestone": "milestone.md.tpl",
}

FOLDER_DESC = {
    "people": "the people you work with",
    "projects": "what you're driving",
    "meetings": "one note per meeting, distilled",
    "decisions": "decisions made, with the reasoning",
    "actionables": "action items and to-dos",
    "actions": "action items and to-dos",
    "patterns": "playbooks and ways-of-working you've noticed",
    "results": "outcomes — what actually happened",
    "areas": "functions you coordinate across",
    "_shared": "cross-cutting concepts and glossary",
    # personal second-brain
    "sources": "things you read, watched, or listened to — with your highlights",
    "library": "things you read, watched, or listened to — with your highlights",
    "ideas": "your own notes and ideas, one thought per page",
    "notes": "your own notes and ideas, one thought per page",
    "topics": "subjects you’re building knowledge on — hubs that link related notes",
    "journal": "your daily/weekly journal, newest first",
    # single-project
    "tasks": "tasks and next actions",
    "learnings": "things you’ve learned — gotchas and lessons",
    "concepts": "key concepts and glossary",
    "references": "links, docs, and source material",
    "milestones": "milestones and timeline",
}

# Per-mode overrides for shared folders — people/projects/areas read differently in a
# life wiki than in a work wiki. Falls back to FOLDER_DESC when no override exists.
MODE_FOLDER_DESC = {
    ("personal", "people"): "the people in your life",
    ("personal", "projects"): "your personal projects and goals",
    ("personal", "areas"): "areas of your life you’re keeping on top of",
    ("project", "people"): "stakeholders, collaborators, and vendors",
}


def folder_desc(folder: str, mode: str = "work") -> str:
    return MODE_FOLDER_DESC.get((mode, folder)) or FOLDER_DESC.get(folder, "")


# --------------------------------------------------------------------------- helpers

def slugify(text: str) -> str:
    text = (text or "").strip().lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"(^-+)|(-+$)", "", text)
    return text or "untitled"


def canon_of(folder: str, type_vocab: dict) -> str:
    word = (type_vocab.get(folder, folder) or folder).lower()
    return CANON.get(word) or CANON.get(folder.lower()) or "note"


def type_word(folder: str, type_vocab: dict) -> str:
    """The frontmatter `type` value for a folder, in the user's own words."""
    if folder in type_vocab and type_vocab[folder]:
        return type_vocab[folder]
    singular = folder[:-1] if folder.endswith("s") and len(folder) > 1 else folder
    return singular.lstrip("_")


def mklink(text: str, target_rel: str, from_rel: str, link_style: str) -> str:
    """A link from `from_rel` to `target_rel` (both vault-relative .md paths)."""
    if link_style == "wikilink":
        return f"[[{target_rel[:-3] if target_rel.endswith('.md') else target_rel}]]"
    from_dir = os.path.dirname(from_rel)
    rel = os.path.relpath(target_rel, from_dir or ".")
    if not rel.startswith("."):
        rel = "./" + rel
    return f"[{text}]({rel})"


def fill(text: str, tokens: dict) -> str:
    for key, val in tokens.items():
        text = text.replace("{{" + key + "}}", "" if val is None else str(val))
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)      # strip template guidance
    text = re.sub(r"\{\{[A-Z0-9_]+\}\}", "", text)           # strip unfilled tokens
    text = re.sub(r"[ \t]+\n", "\n", text)                    # trailing whitespace
    text = re.sub(r"\n{3,}", "\n\n", text)                    # collapse blank runs
    return text.strip() + "\n"


def note_template(canon: str) -> str:
    fname = TEMPLATE_FILE.get(canon)
    if fname:
        return (NOTE_TPL / fname).read_text()
    # generic typed page fallback
    return (
        "---\ntype: {{TYPE}}\ntitle: \"{{TITLE}}\"\ndescription: \"{{DESCRIPTION}}\"\n"
        "date: {{DATE}}\ntimestamp: {{TIMESTAMP}}\ntags: [{{TAGS}}]\n---\n\n"
        "# {{TITLE}}\n\n{{BODY}}\n\n## Related\n\n{{RELATED}}\n"
    )


# --------------------------------------------------------------------------- mode copy

def default_description(owner: str, wiki_title: str, mode: str) -> str:
    return {
        "personal": f"{owner}'s personal knowledge wiki — a second brain for what they read, think, and learn.",
        "project": f"A working wiki for {wiki_title} — its decisions, learnings, and references in one place.",
    }.get(mode, f"{owner}'s personal work wiki.")


def buckets_phrase(folders: list, mode: str) -> str:
    if mode == "personal":
        return "ideas and topics"
    if mode == "project":
        present = [b for b in ("decisions", "tasks", "actions", "patterns",
                               "learnings", "concepts", "references", "milestones") if b in folders]
        return ", ".join(present) or "its pages"
    present = [b for b in ("decisions", "actionables", "actions", "patterns", "results") if b in folders]
    return ", ".join(present) or "your buckets"


def spec_flow(name: str, mode: str, buckets: str, transcript_mode: str) -> str:
    """The 'how this wiki is fed' section of SPEC.md, in the user's mode."""
    if mode == "personal":
        return (
            "Anything you consume or think — an article, a video, a passing idea — is captured "
            "once, then distilled into short, linked pages:\n\n"
            "- **Sources** — what you read/watched/listened to, kept with your *highlights* and a "
            f"one-line *takeaway* (how much of the original is kept is set by **{transcript_mode}**).\n"
            "- **Idea-notes** — one thought per page, in your own words, each linking out to the "
            "ideas, topics, and sources it connects to.\n"
            "- **Topics** — hub pages that gather everything on one subject as it grows.\n\n"
            "The links between notes are the point — they turn a pile of saved things into a brain "
            f"you can think with. The `{name}` skill does the filing and linking for you."
        )
    if mode == "project":
        return (
            "Everything about this project lives in one place. Raw material — a working session, a "
            "meeting about it, something you read — is captured once, then the useful parts are "
            f"pulled out into short, linked pages: {buckets}.\n\n"
            "- The root **Overview** is the anchor: what the project is, its goal, and where it stands.\n"
            "- Each page links back to what it came from, so the reasoning is never lost.\n\n"
            f"The `{name}` skill does the fan-out — you just tell it what happened."
        )
    return (
        "Raw material — a meeting, a 1:1, a pasted chat transcript — is captured once, then the "
        "useful parts are pulled out into short, linkable pages:\n\n"
        "- **Meeting / conversation** → kept in `meetings/` (or under a person in "
        f"`people/<name>/conversations/`). Transcript handling here is **{transcript_mode}**.\n"
        f"- From each, fan out to the buckets — {buckets} — one page per item, each linking back "
        "to its source via `source:` and to the people involved via `people:`.\n"
        "- **Results** close the loop: a result links back to the decision or actionable it came "
        "from (`follows_up:`), so you can trace decision → outcome.\n\n"
        "One meeting typically creates or updates several cross-linked pages. You never file things "
        f"by hand — the `{name}` skill does the fan-out."
    )


def readme_copy(name: str, folders: list, mode: str, buckets: str) -> tuple:
    """Returns (kind_sentence, what_you_can_say) for README.md, in the user's mode."""
    if mode == "personal":
        kind = "This is your second brain — everything you read, think, and want to remember."
        lines = [
            "- **Save something you read or watched**:\n"
            f"  > `/{name} save` … then paste a link, a quote, or your notes\n\n"
            "  It writes a page with your highlights and takeaway, and links it to the right topics.",
            f"- **Jot an idea**:\n  > `/{name} note` … then write the thought",
        ]
        if "journal" in folders:
            lines.append(f"- **Journal today**:\n  > `/{name} journal` … then write your entry")
        lines += [
            f"- **Ask your brain anything**:\n  > `/{name} query what do I know about X?`",
            f"- **Tidy up**:\n  > `/{name} lint`",
        ]
        return kind, "\n\n".join(lines)
    if mode == "project":
        kind = "This is the working wiki for the project — its decisions, tasks, and learnings in one place."
        lines = [
            "- **Log progress** — paste notes from a session, a meeting, or your own update:\n"
            f"  > `/{name} log` … then say what happened\n\n"
            f"  It pulls out {buckets} and links each back to where it came from.",
            f"- **Ask the project anything**:\n  > `/{name} query why did we choose X?`",
        ]
        if "milestones" in folders:
            lines.append(f"- **Add a milestone**:\n  > `/{name} milestone Beta launch`")
        lines.append(f"- **Tidy up**:\n  > `/{name} lint`")
        return kind, "\n\n".join(lines)
    # work (default)
    kind = "This is your personal work wiki."
    lines = [
        "- **Capture a meeting** — paste or describe it:\n"
        f"  > `/{name} meeting` … then paste the notes or transcript\n\n"
        f"  It writes a meeting note and pulls out {buckets} automatically.",
        f"- **Log a 1:1** with someone:\n  > `/{name} person Asha` … then describe what you discussed",
        f"- **Ask your wiki anything**:\n  > `/{name} query what did we decide about pricing?`",
        f"- **Add a project or person**:\n  > `/{name} init project Q3 Launch`",
        f"- **Tidy up**:\n  > `/{name} lint`",
    ]
    return kind, "\n\n".join(lines)


# --------------------------------------------------------------------------- build

def build(config: dict, dry_run: bool = False, today: str | None = None) -> int:
    vault = Path(os.path.expanduser(config["vault_root"])).resolve()
    today = today or _dt.date.today().isoformat()
    now_iso = _dt.datetime.now().replace(microsecond=0).isoformat()
    link_style = config.get("link_style", "relative")
    folders = list(config.get("folders", []))
    type_vocab = config.get("type_vocab", {})
    owner = config.get("owner", "you")
    wiki_name = config["wiki_name"]
    wiki_title = config.get("wiki_title", wiki_name)
    mode = config.get("mode", "work")
    desc = config.get("wiki_description") or default_description(owner, wiki_title, mode)

    writes: list[tuple[Path, str]] = []
    # folder -> list of (target_rel, title, desc) for building that folder's index
    entries: dict[str, list[tuple[str, str, str]]] = {f: [] for f in folders}

    def add_note(folder: str, slug: str, canon: str, tok: dict, subdir: str = "") -> str:
        rel = "/".join(p for p in [folder, subdir, slug + ".md"] if p)
        base = {"DATE": today, "TIMESTAMP": now_iso, "TYPE": tok.get("TYPE", type_word(folder, type_vocab))}
        base.update(tok)
        writes.append((vault / rel, fill(note_template(canon), base)))
        entries.setdefault(folder, []).append((rel, base.get("TITLE", slug), base.get("DESCRIPTION", "")))
        return rel

    # ---- root meta docs --------------------------------------------------------
    writes.append((vault / "SPEC.md", render_spec(config, now_iso)))
    writes.append((vault / "README.md", render_readme(config)))

    # ---- seed people -----------------------------------------------------------
    if "people" in folders:
        for person in config.get("people_seed", []):
            slug = slugify(person)
            prel = f"people/{slug}/profile.md"
            writes.append((vault / prel, fill(note_template("person"), {
                "TYPE": type_word("people", type_vocab), "TITLE": person,
                "DESCRIPTION": f"Profile for {person}.", "RELATION": "report",
                "ROLE": "", "TIMESTAMP": now_iso, "TAGS": "person",
                "BODY": f"_Add context about {person} here._",
            })))
            writes.append((vault / f"people/{slug}/index.md",
                           fill(read_asset("index.md.tpl"), {
                               "TITLE": person,
                               "DESCRIPTION": f"Everything about {person}.",
                               "INDEX_BODY": "## Conversations\n\n_1:1s and syncs will appear here._",
                           })))
            writes.append((vault / f"people/{slug}/conversations/index.md",
                           fill(read_asset("index.md.tpl"), {
                               "TITLE": f"{person} — Conversations",
                               "DESCRIPTION": "1:1s and syncs, newest first.",
                               "INDEX_BODY": "_No conversations logged yet._",
                           })))
            entries["people"].append((prel, person, f"Profile for {person}."))

    # ---- seed projects ---------------------------------------------------------
    if "projects" in folders:
        for proj in config.get("projects_seed", []):
            slug = slugify(proj)
            orel = f"projects/{slug}/overview.md"
            writes.append((vault / orel, fill(note_template("project"), {
                "TYPE": type_word("projects", type_vocab), "TITLE": proj,
                "DESCRIPTION": f"Overview of {proj}.", "STATUS": "active",
                "DATE": today, "TIMESTAMP": now_iso, "TAGS": "project",
                "BODY": f"_What is {proj} about?_", "GOAL": "_Define the goal._",
            })))
            writes.append((vault / f"projects/{slug}/index.md",
                           fill(read_asset("index.md.tpl"), {
                               "TITLE": proj, "DESCRIPTION": f"{proj} project.",
                               "INDEX_BODY": mklink_bullet("Overview", orel, f"projects/{slug}/index.md", link_style,
                                                           "goal, status, decisions, actions"),
                           })))
            entries["projects"].append((orel, proj, f"Overview of {proj}."))

    # ---- example distillation flow (meeting -> decision -> action) -------------
    canon_to_folder = {}
    for f in folders:
        canon_to_folder.setdefault(canon_of(f, type_vocab), f)

    def people_links(from_rel: str) -> str:
        """Quoted links to the (up to 2) seed people, computed relative to `from_rel`."""
        out = []
        if "people" in folders:
            for person in config.get("people_seed", [])[:2]:
                slug = slugify(person)
                out.append('"' + mklink(person, f"people/{slug}/profile.md", from_rel, link_style) + '"')
        return ", ".join(out)

    # The vault root anchor page for a single-project wiki (filled in the project branch).
    project_overview_rel = "overview.md" if mode == "project" else None

    if mode == "work":
        # ---- work: meeting -> decision -> action -> result / pattern ----------
        mfolder = canon_to_folder.get("meeting")
        dfolder = canon_to_folder.get("decision")
        afolder = canon_to_folder.get("action")
        rfolder = canon_to_folder.get("result")
        pfolder = canon_to_folder.get("pattern")

        mrel = f"{mfolder}/{today}-example-kickoff.md" if mfolder else None
        drel = f"{dfolder}/example-use-this-wiki.md" if dfolder else None
        arel = f"{afolder}/example-file-first-meeting.md" if afolder else None

        if dfolder:
            related = mklink_bullet("Example — File your first real meeting", arel, drel, link_style) if arel else ""
            add_note(dfolder, "example-use-this-wiki", "decision", {
                "TYPE": type_word(dfolder, type_vocab),
                "TITLE": "Example — Use this wiki for meetings",
                "DESCRIPTION": "A sample decision. Delete it once you've filed a real one.",
                "STATUS": "accepted",
                "SOURCE": mklink("Example — Kickoff sync", mrel, drel, link_style) if mrel else "",
                "PEOPLE": people_links(drel), "TAGS": "example",
                "BODY": "This is an example page showing the format of a decision. "
                        "A real decision records what was chosen and—most importantly—why.",
                "OPTIONS": "_What else was considered?_",
                "RATIONALE": "_Why this choice over the alternatives?_",
                "RELATED": related,
            })
        if afolder:
            add_note(afolder, "example-file-first-meeting", "action", {
                "TYPE": type_word(afolder, type_vocab),
                "TITLE": "Example — File your first real meeting",
                "DESCRIPTION": "A sample action item. Delete it once you've filed a real one.",
                "STATUS": "open", "OWNER": owner, "DUE": "",
                "SOURCE": mklink("Example — Kickoff sync", mrel, arel, link_style) if mrel else "",
                "PEOPLE": people_links(arel), "TAGS": "example",
                "BODY": "Try it: run `/" + wiki_name + " meeting` and paste any notes.",
                "RELATED": mklink_bullet("Example — Use this wiki for meetings", drel, arel, link_style) if drel else "",
            })
        if rfolder and drel:
            add_note(rfolder, "example-outcome", "result", {
                "TYPE": type_word(rfolder, type_vocab),
                "TITLE": "Example — An outcome that closes the loop",
                "DESCRIPTION": "A sample result, linked back to the decision it followed.",
                "STATUS": "in-progress",
                "FOLLOWS_UP": mklink("Example — Use this wiki for meetings", drel,
                                     f"{rfolder}/example-outcome.md", link_style),
                "SOURCE": "", "TAGS": "example",
                "BODY": "A result records what actually happened after a decision or action, "
                        "so you can look back and learn.",
            })
        if pfolder:
            add_note(pfolder, "example-pattern", "pattern", {
                "TYPE": type_word(pfolder, type_vocab),
                "TITLE": "Example — A way-of-working worth keeping",
                "DESCRIPTION": "A sample pattern/playbook.",
                "TAGS": "example",
                "BODY": "A pattern captures a repeatable approach you want to reuse.",
                "WHEN": "_When does this apply?_",
            })
        if mfolder:
            def sec(label, rel):
                return mklink_bullet(label, rel, mrel, link_style) if rel else "_None yet._"
            add_note(mfolder, f"{today}-example-kickoff", "meeting", {
                "TYPE": type_word(mfolder, type_vocab),
                "TITLE": "Example — Kickoff sync",
                "DESCRIPTION": "A sample meeting note. Delete it once you've filed a real one.",
                "PARTICIPANTS": people_links(mrel), "TAGS": "example",
                "SUMMARY": "This example shows how one meeting fans out into the buckets below. "
                           f"Run `/{wiki_name} meeting` to file a real one — I'll do the rest.",
                "ACTIONABLES": sec("Example — File your first real meeting", arel),
                "DECISIONS": sec("Example — Use this wiki for meetings", drel),
                "PATTERNS": "_None yet._", "RESULTS": "_None yet._", "RELATED": "", "RAW_BLOCK": "",
            })

    elif mode == "personal":
        # ---- second brain: a source -> an idea-note -> a topic hub ------------
        sfolder = canon_to_folder.get("source")
        ifolder = canon_to_folder.get("idea")
        tfolder = canon_to_folder.get("topic")
        srel = f"{sfolder}/example-a-good-read.md" if sfolder else None
        irel = f"{ifolder}/example-first-idea.md" if ifolder else None
        trel = f"{tfolder}/example-a-growing-topic.md" if tfolder else None

        if sfolder:
            add_note(sfolder, "example-a-good-read", "source", {
                "TYPE": type_word(sfolder, type_vocab),
                "TITLE": "Example — An article worth keeping",
                "DESCRIPTION": "A sample saved source. Delete it once you've saved a real one.",
                "AUTHOR": "", "KIND": "article", "URL": "", "STATUS": "read", "TAGS": "example",
                "TAKEAWAY": "In your own words: the one idea from this piece you want to keep. "
                            f"Try it — run `/{wiki_name} save` and paste a link or some notes.",
                "HIGHLIGHTS": "> A passage worth remembering.",
                "RELATED": mklink_bullet("Example — Your first idea-note", irel, srel, link_style) if irel else "",
            })
        if ifolder:
            add_note(ifolder, "example-first-idea", "idea", {
                "TYPE": type_word(ifolder, type_vocab),
                "TITLE": "Example — Your first idea-note",
                "DESCRIPTION": "A sample idea-note — one thought per page, in your words.",
                "STATUS": "seed",
                "SOURCE": mklink("Example — An article worth keeping", srel, irel, link_style) if srel else "",
                "TAGS": "example",
                "BODY": "An idea-note holds a single thought in your own words. The links at the "
                        "bottom are what turn a pile of notes into a second brain.",
                "RELATED": "\n".join(x for x in [
                    mklink_bullet("Example — An article worth keeping", srel, irel, link_style) if srel else "",
                    mklink_bullet("Example — A growing topic", trel, irel, link_style) if trel else "",
                ] if x),
            })
        if tfolder:
            add_note(tfolder, "example-a-growing-topic", "topic", {
                "TYPE": type_word(tfolder, type_vocab),
                "TITLE": "Example — A growing topic",
                "DESCRIPTION": "A sample topic hub. It links the notes and sources on one subject.",
                "TAGS": "example",
                "BODY": "A topic page is a hub: a short overview plus links to everything you've "
                        "captured on it. It grows as you add notes.",
                "NOTES": mklink_bullet("Example — Your first idea-note", irel, trel, link_style) if irel else "",
                "SOURCES": mklink_bullet("Example — An article worth keeping", srel, trel, link_style) if srel else "",
                "RELATED": "",
            })

    elif mode == "project":
        # ---- single project: an overview anchor -> a decision -> a next step --
        dfolder = canon_to_folder.get("decision")
        afolder = canon_to_folder.get("action")
        drel = f"{dfolder}/example-first-decision.md" if dfolder else None
        arel = f"{afolder}/example-next-step.md" if afolder else None

        writes.append((vault / project_overview_rel, fill(note_template("project"), {
            "TYPE": "project", "TITLE": wiki_title, "DESCRIPTION": desc,
            "STATUS": config.get("project_status", "active"),
            "DATE": today, "TIMESTAMP": now_iso, "PEOPLE": "", "TAGS": "overview",
            "BODY": "_What is this project, in a sentence or two?_",
            "GOAL": "_What does done look like?_",
            "STATUS_NOTES": "_Where things stand right now._",
            "DECISIONS": mklink_bullet("Example — Your first decision", drel, project_overview_rel, link_style) if drel else "_None yet._",
            "ACTIONABLES": mklink_bullet("Example — A next step", arel, project_overview_rel, link_style) if arel else "_None yet._",
            "SUBPROJECTS": "", "RELATED": "",
        })))
        if dfolder:
            add_note(dfolder, "example-first-decision", "decision", {
                "TYPE": type_word(dfolder, type_vocab),
                "TITLE": "Example — Your first decision",
                "DESCRIPTION": "A sample decision. Delete it once you've recorded a real one.",
                "STATUS": "accepted",
                "SOURCE": mklink("Overview", project_overview_rel, drel, link_style),
                "PEOPLE": "", "TAGS": "example",
                "BODY": "Record what was chosen and—most importantly—why. "
                        f"Run `/{wiki_name} log` to capture a real one.",
                "OPTIONS": "_What else was considered?_",
                "RATIONALE": "_Why this choice over the alternatives?_",
                "RELATED": mklink_bullet("Overview", project_overview_rel, drel, link_style),
            })
        if afolder:
            add_note(afolder, "example-next-step", "action", {
                "TYPE": type_word(afolder, type_vocab),
                "TITLE": "Example — A next step",
                "DESCRIPTION": "A sample task. Delete it once you've added a real one.",
                "STATUS": "open", "OWNER": owner, "DUE": "",
                "SOURCE": mklink("Overview", project_overview_rel, arel, link_style),
                "PEOPLE": "", "TAGS": "example",
                "BODY": "A concrete next action that moves the project forward.",
                "RELATED": mklink_bullet("Overview", project_overview_rel, arel, link_style),
            })

    # ---- reserved index.md + log.md for each top-level folder -------------------
    for f in folders:
        body_lines = []
        for (rel, title, d) in entries.get(f, []):
            body_lines.append(mklink_bullet(title, rel, f"{f}/index.md", link_style, d))
        body = "\n".join(body_lines) if body_lines else "_Nothing here yet — add the first page with `/" + wiki_name + "`._"
        writes.append((vault / f / "index.md", fill(read_asset("index.md.tpl"), {
            "TITLE": f.replace("_", "").title(),
            "DESCRIPTION": folder_desc(f, mode),
            "INDEX_BODY": body,
        })))
        writes.append((vault / f / "log.md", fill(read_asset("log.md.tpl"), {
            "TITLE": f.replace("_", "").title(),
            "LOG_BODY": f"## {today}\n* **Creation**: folder scaffolded.",
        })))

    # ---- root index.md + log.md -----------------------------------------------
    header = (f"> {desc}\n"
              f"> Conventions: [SPEC.md](./SPEC.md) · How-to: [README.md](./README.md)")
    sections = []
    for f in folders:
        title = f.replace("_", "").title()
        if link_style == "wikilink":
            link = mklink(title, f"{f}/index.md", "index.md", link_style)
        else:
            # folder links point at the directory for nicer browsing
            link = f"[{title}](./{f}/)"
        sections.append(f"## {title}\n\n* {link} — {folder_desc(f, mode)}")
    body_parts = [header]
    if project_overview_rel:
        ov = mklink("Overview", project_overview_rel, "index.md", link_style)
        body_parts.append(f"## Overview\n\n* {ov} — what this project is, its goal and status")
    body_parts.extend(sections)
    writes.append((vault / "index.md", fill(read_asset("index.md.tpl"), {
        "TITLE": wiki_title,
        "DESCRIPTION": "",
        "INDEX_BODY": "\n\n".join(body_parts),
    })))
    writes.append((vault / "log.md", fill(read_asset("log.md.tpl"), {
        "TITLE": wiki_title,
        "LOG_BODY": f"## {today}\n* **Creation**: wiki scaffolded by the wiki-creator skill.",
    })))

    # ---- emit ------------------------------------------------------------------
    print(f"{'DRY-RUN — would create' if dry_run else 'Building'}: {vault}")
    for path, content in writes:
        rel = path.relative_to(vault)
        if dry_run:
            print(f"  + {rel}")
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    if not dry_run:
        print(f"  wrote {len(writes)} files across {len({p.parent for p, _ in writes})} folders")

    # ---- qmd registration (optional) -------------------------------------------
    if not dry_run and config.get("qmd") and shutil.which("qmd"):
        register_qmd(vault, wiki_name, desc)

    if not dry_run:
        ok = validate(vault, quiet=True)
        print("  OKF conformance: " + ("PASS ✓" if ok == 0 else "FAIL ✗ (run validate for details)"))
    return 0


def register_qmd(vault: Path, name: str, desc: str) -> None:
    try:
        subprocess.run(["qmd", "collection", "add", str(vault), "--name", name],
                       check=False, capture_output=True)
        subprocess.run(["qmd", "context", "add", f"qmd://{name}", desc],
                       check=False, capture_output=True)
        subprocess.run(["qmd", "embed", "-c", name], check=False, capture_output=True)
        print(f"  qmd: registered collection '{name}' and embedded.")
    except Exception as exc:  # noqa: BLE001 — qmd is best-effort
        print(f"  qmd: skipped ({exc}).")


def mklink_bullet(text, target_rel, from_rel, link_style, desc="") -> str:
    link = mklink(text, target_rel, from_rel, link_style)
    return f"* {link}" + (f" — {desc}" if desc else "")


def read_asset(name: str) -> str:
    return (ASSETS / name).read_text()


# --------------------------------------------------------------------------- render meta

def render_spec(config: dict, now_iso: str) -> str:
    folders = config.get("folders", [])
    type_vocab = config.get("type_vocab", {})
    link_style = config.get("link_style", "relative")
    mode = config.get("mode", "work")
    structure = "\n".join(f"- `{f}/` — {folder_desc(f, mode)}" for f in folders)
    rows = ["| Type | Where | What it is |", "|---|---|---|"]
    seen = set()
    for f in folders:
        t = type_word(f, type_vocab)
        if t in seen:
            continue
        seen.add(t)
        rows.append(f"| `{t}` | `{f}/` | {folder_desc(f, mode)} |")
    if link_style == "wikilink":
        ls, lsd = "Obsidian wikilinks", ("Links are written as `[[folder/slug]]` (no `.md`). "
                                         "This wiki is meant to be used inside Obsidian, where these give you "
                                         "instant backlinks and the graph view.")
    else:
        ls, lsd = "portable relative links", ("Links are written as relative markdown paths with the `.md` "
                                              "extension, e.g. `[Q3 pricing](../decisions/q3-pricing.md)`. They "
                                              "work in any editor and also in Obsidian (clickable + backlinks + graph).")
    name = config["wiki_name"]
    owner = config.get("owner", "you")
    wiki_title = config.get("wiki_title", name)
    transcript_mode = config.get("transcript_mode", "narrative+distilled")
    buckets = buckets_phrase(folders, mode)
    qmd = ("Semantic search is available via **qmd** — ask your wiki questions in plain language."
           if config.get("qmd") else
           "Semantic search (qmd) is not set up yet; search falls back to keyword matching. "
           "You can enable qmd later for meaning-based recall.")
    return fill(read_asset("spec.md.tpl"), {
        "WIKI_TITLE": wiki_title,
        "WIKI_NAME": name,
        "OWNER": owner,
        "GENERATED_AT": now_iso,
        "WIKI_DESCRIPTION": config.get("wiki_description") or default_description(owner, wiki_title, mode),
        "STRUCTURE": structure,
        "TYPE_VOCAB_TABLE": "\n".join(rows),
        "LINK_STYLE": ls, "LINK_STYLE_DESC": lsd,
        "TRANSCRIPT_MODE": transcript_mode,
        "FLOW_DESC": spec_flow(name, mode, buckets, transcript_mode),
        "BUCKETS": buckets, "QMD_STATUS": qmd,
    })


def render_readme(config: dict) -> str:
    folders = config.get("folders", [])
    mode = config.get("mode", "work")
    name = config["wiki_name"]
    simple = "\n".join(f"- **{f.replace('_','').title()}** — {folder_desc(f, mode)}" for f in folders)
    buckets = buckets_phrase(folders, mode)
    kind_sentence, what_you_can_say = readme_copy(name, folders, mode, buckets)
    qmd = ("> 🔎 Semantic search is on — ask questions in plain language."
           if config.get("qmd") else
           "> 🔎 Tip: install **qmd** later to ask questions in plain language (meaning-based search).")
    return fill(read_asset("readme.md.tpl"), {
        "WIKI_TITLE": config.get("wiki_title", name),
        "WIKI_NAME": name,
        "OWNER": config.get("owner", "you"),
        "VAULT_ROOT": str(Path(os.path.expanduser(config["vault_root"])).resolve()),
        "WIKI_KIND_SENTENCE": kind_sentence,
        "WHAT_YOU_CAN_SAY": what_you_can_say,
        "BUCKETS": buckets, "STRUCTURE_SIMPLE": simple, "QMD_STATUS": qmd,
    })


# --------------------------------------------------------------------------- validate

def _frontmatter(text: str):
    m = re.match(r"^---\n(.*?)\n---\s*\n", text, flags=re.S)
    return m.group(1) if m else None


def validate(vault: Path, quiet: bool = False) -> int:
    vault = Path(os.path.expanduser(str(vault))).resolve()
    if not vault.is_dir():
        print(f"validate: not a directory: {vault}", file=sys.stderr)
        return 1
    errors, checked = [], 0
    for path in sorted(vault.rglob("*.md")):
        name = path.name
        text = path.read_text()
        fm = _frontmatter(text)
        if name in RESERVED:
            if fm is not None:
                errors.append(f"{path.relative_to(vault)}: reserved file must NOT have frontmatter")
            continue
        if name in META:
            continue
        checked += 1
        if fm is None:
            errors.append(f"{path.relative_to(vault)}: missing YAML frontmatter")
            continue
        mt = re.search(r"^type:\s*(\S.*)$", fm, flags=re.M)
        if not mt or not mt.group(1).strip() or mt.group(1).strip() in ("''", '""'):
            errors.append(f"{path.relative_to(vault)}: missing/empty required `type`")
    if not quiet:
        print(f"OKF validate: {vault}")
        print(f"  concept pages checked: {checked}")
        if errors:
            print(f"  ✗ {len(errors)} problem(s):")
            for e in errors:
                print(f"    - {e}")
        else:
            print("  ✓ conforms to OKF v0.1 (every concept page has a non-empty `type`).")
    return 1 if errors else 0


# --------------------------------------------------------------------------- main

def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    cmd = argv[1]
    if cmd == "build":
        rest = argv[2:]
        dry = "--dry-run" in rest
        today = None
        if "--today" in rest:
            today = rest[rest.index("--today") + 1]
        cfgs = [a for a in rest if not a.startswith("--") and a != today]
        if not cfgs:
            print("build: need a config.json path", file=sys.stderr)
            return 2
        config = json.loads(Path(cfgs[0]).read_text())
        for required in ("wiki_name", "vault_root", "folders"):
            if required not in config:
                print(f"build: config missing '{required}'", file=sys.stderr)
                return 2
        return build(config, dry_run=dry, today=today)
    if cmd == "validate":
        if len(argv) < 3:
            print("validate: need a vault_root path", file=sys.stderr)
            return 2
        return validate(Path(argv[2]))
    print(f"unknown command: {cmd}\n{__doc__}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
