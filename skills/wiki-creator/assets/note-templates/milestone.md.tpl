<!-- tpl: type=milestone; a point on the project's timeline; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,STATUS,DUE,TAGS,BODY,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
status: {{STATUS}}
due: {{DUE}}
tags: [{{TAGS}}]
---
<!-- status: planned | in-progress | hit | missed | slipped. due: target date (YYYY-MM-DD). -->

# {{TITLE}}

{{BODY}}

## Related

{{RELATED}}
<!-- link the decisions, tasks, and results tied to this milestone -->
