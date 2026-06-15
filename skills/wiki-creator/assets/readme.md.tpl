# {{WIKI_TITLE}}

Welcome, {{OWNER}}! This is your personal work wiki. You don't have to organize anything by
hand — just talk to the **`{{WIKI_NAME}}`** assistant and it files things for you.

## What you can say

- **Capture a meeting** — paste or describe it:
  > `/{{WIKI_NAME}} meeting` … then paste the notes or transcript

  It writes a meeting note and pulls out {{BUCKETS}} automatically.

- **Log a 1:1** with someone:
  > `/{{WIKI_NAME}} person Asha` … then describe what you discussed

- **Ask your wiki anything**:
  > `/{{WIKI_NAME}} query what did we decide about pricing?`

- **Add a project or person**:
  > `/{{WIKI_NAME}} init project Q3 Launch`

- **Tidy up**:
  > `/{{WIKI_NAME}} lint`

## Where things live

Your wiki is a folder of plain-text files at:

```
{{VAULT_ROOT}}
```

Open it in any app — a plain text editor, VS Code, or Obsidian. Nothing is locked to one
tool. Each folder has an `index.md` you can read like a table of contents.

## How it's organized

{{STRUCTURE_SIMPLE}}

That's it — capture things as they happen, ask questions when you need answers, and let the
assistant keep it tidy. For the technical conventions, see [SPEC.md](./SPEC.md).

{{QMD_STATUS}}
