[![Build Status](https://travis-ci.org/sul-dlss/dor_indexing_app.svg?branch=master)](https://travis-ci.org/sul-dlss/dor_indexing_app) | [![Coverage Status](https://coveralls.io/repos/github/sul-dlss/dor_indexing_app/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/dor_indexing_app?branch=master)


# Dor Indexing App 

The dor_indexing_app is the primary API for indexing DOR objects into the DOR Index in the Solr cloud.

## Reindexing API

#### `GET|POST|PUT /dor/reindex/:pid`

#### Summary
Reindexing route

#### Description
The `/dor/reindex/:pid` endpoint is a synchronous request to update the Solr index for the given DOR Object matching `:pid`. Logs to `log/indexer.log`.

##### Parameters
Name | Located In | Description | Required | Schema | Default
---- | ---------- | ----------- | -------- | ------ | -------
`pid` | route | the unique identifier for the DOR object (e.g., `druid:aa111bb2222`) | Yes | string | None
`commitWithin` | query | uses the given `commitWithin` parameter for the Solr update | No | string | `1000`

##### Example Response

TBD

##### Response Status Codes

- `200` OK
- `404` Not Found: `pid` does not match an object in DOR

