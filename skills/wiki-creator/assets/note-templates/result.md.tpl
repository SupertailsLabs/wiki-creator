<!-- tpl: type=result; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,STATUS,FOLLOWS_UP,SOURCE,TAGS,BODY,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
status: {{STATUS}}
follows_up: "{{FOLLOWS_UP}}"
source: "{{SOURCE}}"
tags: [{{TAGS}}]
---
<!-- status: win | mixed | miss | in-progress. follows_up: link to the decision OR actionable this is the outcome of — this is the load-bearing back-link that closes the loop. -->

# {{TITLE}}

**Outcome:** {{DESCRIPTION}}

## What happened

{{BODY}}

## Follows up on

{{FOLLOWS_UP}}
<!-- e.g. - [Chose tiered pricing](../decisions/chose-tiered-pricing.md) -->

## Related

{{RELATED}}
