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
`commitWithin` | query | uses the given `commitWithin` parameter for the Solr update (in milliseconds). If none is provided, then a Solr `commit` is done on each request. | No | numeric | None

##### Example Response

The responses are always in plain text. There are 2 possible responses:

```
Successfully updated index for druid:aa111bb2222
```

or

```
Object does not exist in Fedora.
```

##### Response Status Codes

- `200` OK
- `404` Not Found: `pid` does not match an object in DOR
- `500` Server Error (from an unexpected exception)

