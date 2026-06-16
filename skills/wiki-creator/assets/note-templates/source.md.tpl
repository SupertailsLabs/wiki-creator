<!-- tpl: type=source; a thing you read/watched/listened to; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,AUTHOR,KIND,URL,STATUS,TAGS,TAKEAWAY,HIGHLIGHTS,RELATED; links: relative by default — if SPEC.md says wikilinks, use [[folder/slug]] without .md -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
author: "{{AUTHOR}}"
kind: {{KIND}}
url: "{{URL}}"
status: {{STATUS}}
tags: [{{TAGS}}]
---
<!-- kind: article | book | video | podcast | paper | thread | other. status: to-read | reading | read. url: where it lives. -->

# {{TITLE}}

## My takeaway

{{TAKEAWAY}}
<!-- The one thing worth remembering, in your own words. This is the part you'll actually reread. -->

## Highlights

{{HIGHLIGHTS}}
<!-- Quotes / passages worth keeping, each on its own line as a > blockquote. -->

## Related

{{RELATED}}
<!-- link the ideas this sparked (../ideas/<slug>.md) and the topic(s) it belongs to -->
