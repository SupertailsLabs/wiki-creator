<!-- tpl: type=conversation; file lives at people/<slug>/conversations/<date>-<topic>.md; tokens=TITLE,DESCRIPTION,DATE,TIMESTAMP,PERSON,TOPIC,TAGS,SUMMARY,ACTIONABLES,DECISIONS,BODY,RELATED; links: relative by default -->
---
type: {{TYPE}}
title: "{{TITLE}}"
description: "{{DESCRIPTION}}"
date: {{DATE}}
timestamp: {{TIMESTAMP}}
person: "{{PERSON}}"
topic: "{{TOPIC}}"
tags: [{{TAGS}}]
---
<!-- person: link to ../profile.md . A 1:1 / sync with one person, about one topic. -->

# {{TITLE}}

## Summary

{{SUMMARY}}

## Actionables

{{ACTIONABLES}}
<!-- fan out to ../../../actionables/<slug>.md, with people: [this person] -->

## Decisions

{{DECISIONS}}

## Notes

{{BODY}}

## Related

{{RELATED}}
