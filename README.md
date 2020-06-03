[![Build Status](https://travis-ci.org/sul-dlss/dor_indexing_app.svg?branch=master)](https://travis-ci.org/sul-dlss/dor_indexing_app)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/dor_indexing_app/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/dor_indexing_app?branch=master)
[![OpenAPI Validator](http://validator.swagger.io/validator?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/master/openapi.yml)](http://validator.swagger.io/validator/debug?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/master/openapi.yml)

# Dor Indexing App

The dor_indexing_app is the primary API for indexing DOR objects into the Argo index.
For more information about the fields and their purpose see: https://docs.google.com/spreadsheets/d/1_uYZvh-oihcxAM_Q24qJ_3nSaqAybmS362SYlDYwYqg/edit#gid=0

## Developer setup
In order to run dor_indexing_app on your laptop (e.g. while running Argo), you need to

* Create the directory `config/certs` and (preferably) create symbolic links to dor_indexing_app's shared_configs certs.
* Create a symbolic link to development.local.yml within `config/settings/` (also found in shared_configs).

## Known Consumers
* There is a Karaf job that runs on a single node: `sulmq-prod-a:/opt/app/karaf/current/deploy/dor_prod_reindexing.xml` that queries solr for the least-recently-indexed items and indexes them
* There is a Camel route that sends messages from the fedora update topic https://github.com/sul-dlss/dor-camel-routes/blob/master/deploy/edu_stanford_dor-indexing-app-prod.indexing.xml#L116-L137

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


### Docker

Build image:
```
docker image build -t suldlss/dor-indexing-app:latest .
```

Publish:
```
docker push suldlss/dor-indexing-app:latest
```
