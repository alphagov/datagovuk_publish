# First time setup

## Publish Setup
First, follow the steps on the first page for setting up Publish Data.

## Importing data dumps
```
$ wget https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz
$ wget https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz
```

Rename them to make this easier...
```
$ mv data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz datasets.jsonl.gz
$ mv data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz orgs.jsonl.gz
```

Unzip
```
$ gunzip *.gz
```

At this point, ensure:
* Your database is set up
* Redis is running
* Sidekiq is running
* Elasticsearch is running
* You can start the app

Load Data
```
$ rails import:organisations[orgs.jsonl]
$ rails import:datasets[datasets.jsonl]
```

That second command is going to take a while...

You can watch indexing happenning real-time on your elasticsearch process, and if you start the app and go to the `/sidekiq` route you'll see the preview generation jobs in the queue.

## If you need to reindex or regenerate previews...
### Indexes

Make sure you're pointed at your local index
```
$ rails search:reindex
```
