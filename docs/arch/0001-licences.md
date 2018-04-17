# Decision record: Handling licences

Date: 2018-04-18

## Context

Licences stored in the legacy system are messy, allowing selection from a predefined list, entry of a custom licence, or a combination of both. This leads to complexity in determining what should be shown, and how to handle the presentation of large custom licences.

Currently this is handled by two fields in 'Publish'.  The licence field holds the legacy database's `license_id` field. In cases where the `license_id` field has a value of `__other__` then the `license_id` is stored in the `licence_other` field of our Dataset model. The legacy system's custom licence field is ignored entirely.

Publishing users expect that any custom licence information they provide will be stored, and shown in the user interface of [Find data](https://github.com/alphagov/datagovuk_find).

## Decision

We will simplify the storing of licence information to:

* Store the legacy `licence_id` field in the new `licence` field and only index the short licence identifier, e.g. uk-ogl
* Store the legacy custom licence field (in the `dataset[extras]` record where `key="licence"`) in `licence_other`

It is expected this will be used by the presentation layer by looking up the `licence` field in a table that contains both the title and the url (if any).

**licence but no licence_other**

The `licence` field will be used to find the title and url of the licence, and this will be displayed.

**licence_other and no licence**

The custom licence in `licence_other` will be displayed, and truncated if it is too long. Some custom licences are just a block of HTML, some are HTML followed by text/markdown and some are just text/markdown.

**licence and licence_other**

The `licence` field will be used to find the title and the url of the licence, and this will be displayed.  The custom licence will also be displayed, but truncated as above.


## Consequences

This will introduce some difficulty in deploying changes to a running system, where currently the `licence_other` field contains a legacy licence id.
