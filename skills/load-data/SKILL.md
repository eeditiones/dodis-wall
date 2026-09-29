---
name: load-data
description: >-
  Load documents (TEI, DocBook, JATS, Markdown) and their images into this Jinks-generated
  TEI Publisher app so they show up in browse, search and facets. Use when the user brings
  a corpus, a zip of files or a few sample documents.
---

# Load data

Documents live in the app's **data collection**: `config.json` → `defaults.data`, `data`
unless configured otherwise. A relative value lies inside the app (`/db/apps/<abbrev>/data`);
an absolute one (`/db/apps/<name>-data`) points to a separate data package, which you
load and reindex on its own.

Browse, search and facets read the **index**, not the files. Every change to the data has
to end with the collection being indexed, or new documents stay invisible and removed ones
linger in the results.

## Where files go

| What | Where |
|---|---|
| Documents | `data/` or a subcollection, e.g. `data/letters/`. Subcollections appear as folders in browse |
| Images the documents reference | alongside the documents, or a collection named in the ODD / facsimile config |
| Sample data that came with a profile (`demo-data`) | leave it; remove the profile from `extends` to drop it |

Browse starts at `defaults.data-default`, a subcollection of the data collection. `demo-data`
sets it to `sermons`, so documents loaded elsewhere don't show up on the start page. When
you load your own corpus, set `data-default` to its collection, or to `""` for the whole
data collection.

Keep the file names stable: the document URL is derived from its path in the data
collection, so renaming a file breaks existing links to it.

## Load and index

With the command line:

```sh
xst upload --config .existdb.json letters/ /db/apps/<abbrev>/data/letters
jinks run <abbrev> reindex
```

Upload a directory rather than looping over files. `xst` recreates the directory structure
below the target collection.

## Check the result

1. Open the browse page and confirm the documents are listed with sensible titles and dates.
2. Open one document. A `tmpl:error-dynamic` or `XPTY0004` usually means its ODD isn't
   compiled — see **manage-odds**.
3. If titles or dates are wrong, the metadata comes from `index.xql`
   (`idx:get-metadata`), which reads fixed places in the header. It is on the `editable`
   list in `config.json`, so adapt the XPath expressions to your corpus there, then
   reindex. Don't fork `modules/navigation-tei.xql` for this unless the reading view needs
   it too.

## Golden rules

1. Documents go into the data collection, nowhere else.
2. Always reindex after loading or removing documents.
3. Keep file names stable once published.
4. Fix titles and dates in `index.xql`, not in the documents.
