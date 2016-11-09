[![Build Status](https://travis-ci.org/sul-dlss/dor_indexing_app.svg?branch=master)](https://travis-ci.org/sul-dlss/dor_indexing_app) | [![Coverage Status](https://coveralls.io/repos/github/sul-dlss/dor_indexing_app/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/dor_indexing_app?branch=master)


# Dor Indexing App 

The dor_indexing_app is the primary API for indexing DOR objects into the DOR Index in the Solr cloud.

## Reindexing API

#### `POST /dor/reindex/:pid`

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


#### `POST /dor/delete_from_index/:pid`

#### Summary
Reindexing route for deleted objects

#### Description
This endpoint is a request to remove the given DOR Object from the Solr index.

##### Parameters
Name | Located In | Description | Required | Schema | Default
---- | ---------- | ----------- | -------- | ------ | -------
`pid` | route | the unique identifier for the DOR object (e.g., `druid:aa111bb2222`) | Yes | string | None
`commitWithin` | query | uses the given `commitWithin` parameter for the Solr update (in milliseconds). If none is provided, then a Solr `commit` is done on each request. | No | numeric | None

##### Example Response

The responses are always in plain text and it's simply an echo of the `:pid`

```
druid:aa111bb2222
```

##### Response Status Codes

- `200` OK
- `500` Server Error (from an unexpected exception)


#### `GET /dor/queue_size`

#### Summary
Length of queue for incoming jobs.

#### Description
This endpoint retrieve the queue size for the backlog nu

##### Parameters

None

##### Example Response

The responses are always in JSON and it holds a single `value` of integer for the queue size.

```json
{
  "value": 123
}
```

##### Response Status Codes

- `200` OK
- `500` Server Error (from an unexpected exception)

