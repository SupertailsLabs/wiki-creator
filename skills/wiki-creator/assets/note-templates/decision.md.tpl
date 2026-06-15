<!-- tpl: type=decision; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,STATUS,SOURCE,PEOPLE,TAGS,BODY,OPTIONS,RATIONALE,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
status: {{STATUS}}
source: "{{SOURCE}}"
people: [{{PEOPLE}}]
tags: [{{TAGS}}]
---
<!-- status: proposed | accepted | superseded. source: link to the meeting/conversation this came from. -->

# {{TITLE}}

**Decision:** {{DESCRIPTION}}

## Context

{{BODY}}

## Options considered

{{OPTIONS}}

## Why this choice

{{RATIONALE}}

## Related

{{RELATED}}
<!-- link the meeting this came from, the actionables it created, and any result that follows it -->
