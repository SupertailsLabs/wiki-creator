<!-- tpl: type=meeting; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,PARTICIPANTS,TAGS,SUMMARY,ACTIONABLES,DECISIONS,PATTERNS,RESULTS,RELATED,RAW_BLOCK; links: relative by default — if SPEC.md says wikilinks, use [[folder/slug]] without .md -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
participants: [{{PARTICIPANTS}}]
tags: [{{TAGS}}]
---

# {{TITLE}}

## Summary

{{SUMMARY}}

## Actionables

{{ACTIONABLES}}
<!-- each: - [ ] [Title](../actionables/<slug>.md) — owner: Name, due: YYYY-MM-DD -->

## Decisions

{{DECISIONS}}
<!-- each: - [Title](../decisions/<slug>.md) — one line -->

## Patterns

{{PATTERNS}}
<!-- each: - [Title](../patterns/<slug>.md) — one line -->

## Results (follow-up on prior commitments)

{{RESULTS}}
<!-- each: - [Title](../results/<slug>.md) — outcome of an earlier decision/actionable -->

## Related

{{RELATED}}

{{RAW_BLOCK}}
<!-- RAW_BLOCK is empty unless transcript_mode = raw+distilled, in which case:
## Raw transcript
<details><summary>Full transcript</summary>

…full pasted transcript…

</details> -->
