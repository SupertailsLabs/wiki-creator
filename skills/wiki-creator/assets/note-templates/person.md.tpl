<!-- tpl: type=person; file lives at people/<slug>/profile.md; tokens=TITLE,DESCRIPTION,RELATION,ROLE,TIMESTAMP,TAGS,BODY,GOALS,CONVERSATIONS,OPEN_ITEMS,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
relation: {{RELATION}}
role: "{{ROLE}}"
timestamp: {{TIMESTAMP}}
tags: [{{TAGS}}]
---
<!-- relation: report | manager | founder | partner | peer | client | other -->

# {{TITLE}}

## About

{{BODY}}

## Context & goals

{{GOALS}}

## Conversations

{{CONVERSATIONS}}
<!-- links into ./conversations/<date>-<topic>.md, newest first -->

## Open with them

{{OPEN_ITEMS}}
<!-- open actionables where people: includes this person -->

## Related

{{RELATED}}
