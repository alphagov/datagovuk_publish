# 1. licences

Date: 2018-04-18

## Status

Accepted

## Context

Licences stored in the legacy system are messy, allowing selection from a predefined list, entry of a custom licence, or a combination of both. This leads to complexity in determining what should be shown, and how to handle the presentation of large custom licences.

Currently this is handled by two fields in 'Publish'.  The licence field holds the legacy database's `license_id` field. In cases where the `license_id` field has a value of `__other__` then the `license_id` is stored in the `licence_other` field of our Dataset model. The legacy system's custom licence field is ignored entirely.

Publishing users expect that any custom licence information they provide will be stored, and shown in the user interface of [Find data](https://github.com/alphagov/datagovuk_find).

## Decision

We will simplify the storing of licence information to:

* Create new fields `licence_code`, `licence_title`, `licence_url`, and `licence_custom`
* Publish will continue (temporarily) fill the old fields so we can migrate the frontend
* We should remove the `licence` and `licence_other` fields once both publish and find apps are using the new fields.

## Consequences

This will introduce some difficulty in deploying changes to a running system, where currently the `licence_other` field contains a legacy licence id.

We will take a staged approach of adding new fields, changing the frontend and then removing the old fields from publish.
