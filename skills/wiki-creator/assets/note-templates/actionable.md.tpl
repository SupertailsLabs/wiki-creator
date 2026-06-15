<!-- tpl: type=action; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,STATUS,OWNER,DUE,SOURCE,PEOPLE,TAGS,BODY,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
status: {{STATUS}}
owner: "{{OWNER}}"
due: {{DUE}}
source: "{{SOURCE}}"
people: [{{PEOPLE}}]
tags: [{{TAGS}}]
---
<!-- status: open | in-progress | done | dropped. When done, consider creating a result that links back here. -->

# {{TITLE}}

- [ ] {{DESCRIPTION}}

## Context

{{BODY}}

## Related

{{RELATED}}
<!-- link the meeting/decision this came from, and the result once it's complete -->
