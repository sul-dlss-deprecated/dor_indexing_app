[![CircleCI](https://circleci.com/gh/sul-dlss/dor_indexing_app.svg?style=svg)](https://circleci.com/gh/sul-dlss/dor_indexing_app)
[![Maintainability](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/maintainability)](https://codeclimate.com/github/sul-dlss/dor-services-app/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/test_coverage)](https://codeclimate.com/github/sul-dlss/dor-services-app/test_coverage)
[![OpenAPI Validator](http://validator.swagger.io/validator?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)](http://validator.swagger.io/validator/?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)

# Dor Indexing App

The dor_indexing_app is the primary API for indexing DOR objects into the Argo index.
For more information about the fields and their purpose see: https://docs.google.com/spreadsheets/d/1_uYZvh-oihcxAM_Q24qJ_3nSaqAybmS362SYlDYwYqg/edit#gid=0

## Rolling indexer

This has been moved to dor-services-app for more efficient access to cocina-models for objects.

## API

See https://sul-dlss.github.io/dor_indexing_app/

## Solr configuration
The Solr configuration is https://github.com/sul-dlss/sul-solr-configs/tree/master/argo_prod

To update this configuration, see the [README](https://github.com/sul-dlss/sul-solr-configs#updating-configurations).

## Index Field Semantics

DOR indexing app indexes data into dynamic Solr fields that have semantics originally adopted by Stanford and the Samvera community, e.g., `_ssi`, `_tesim`, & `_dtsi`. These are documented in a [common Solr schema](https://github.com/sul-dlss/argo/blob/main/solr_conf/conf/schema.xml#L19-L151). The general scheme is one or two characters indicating the field type (e.g., string, integer, datetime) with the rest of the characters indicating whether the field is stored or not, indexed or not, and multi-valued or not.

## Setup RabbitMQ
You must set up the durable rabbitmq queues that bind to the exchange where workflow messages are published.

```sh
RAILS_ENV=production bin/rake rabbitmq:setup
```
This is going to create queues for this application that bind to some topics.

## RabbitMQ queue workers
In a development environment you can start sneakers this way:
```sh
WORKERS=ReindexJob,ReindexByDruidJob,DeleteByDruidJob bin/rake sneakers:run
```

but on the production machines we use systemd to do the same:
```sh
sudo /usr/bin/systemctl start sneakers
sudo /usr/bin/systemctl stop sneakers
sudo /usr/bin/systemctl status sneakers
```

This is started automatically during a deploy via capistrano


### Docker

Build image:
```
docker image build -t suldlss/dor-indexing-app:latest .
```

Publish:
```
docker push suldlss/dor-indexing-app:latest
```

#### Note
When running the workers, you need to ensure that rabbitmq is up first. You can do this by running:

```
sh -c "docker/wait-port.sh rabbitmq 5672 ; bin/rake sneakers:run"
```

## Reset Process (for QA/Stage)

1. SSH to a DIA server.
2. Delete the solr documents:
   * QA: `curl -X POST -H 'Content-Type: application/json' --data-binary '{"delete":{"query":"*:*" }}' https://sul-solr.stanford.edu/solr/argo_qa/update`
   * Stage: `curl -X POST -H 'Content-Type: application/json' --data-binary '{"delete":{"query":"*:*" }}' https://sul-solr.stanford.edu/solr/argo_stage/update`
