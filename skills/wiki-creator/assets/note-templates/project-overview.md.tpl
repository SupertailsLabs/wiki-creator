<!-- tpl: type=project; file lives at projects/<slug>/overview.md; tokens=TITLE,DESCRIPTION,STATUS,DATE,TIMESTAMP,PEOPLE,TAGS,BODY,GOAL,STATUS_NOTES,DECISIONS,ACTIONABLES,SUBPROJECTS,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
status: {{STATUS}}
started: {{DATE}}
timestamp: {{TIMESTAMP}}
people: [{{PEOPLE}}]
tags: [{{TAGS}}]
---
<!-- status: active | paused | shipped | archived -->

# {{TITLE}}

{{BODY}}

## Goal

{{GOAL}}

## Status

{{STATUS_NOTES}}

## Key decisions

{{DECISIONS}}

## Open actionables

{{ACTIONABLES}}

## Sub-projects

{{SUBPROJECTS}}
<!-- links to ./<sub-project>/overview.md -->

## Related

{{RELATED}}
