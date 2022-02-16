[![CircleCI](https://circleci.com/gh/sul-dlss/dor_indexing_app.svg?style=svg)](https://circleci.com/gh/sul-dlss/dor_indexing_app)
[![Maintainability](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/maintainability)](https://codeclimate.com/github/sul-dlss/dor-services-app/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/test_coverage)](https://codeclimate.com/github/sul-dlss/dor-services-app/test_coverage)
[![OpenAPI Validator](http://validator.swagger.io/validator?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)](http://validator.swagger.io/validator/?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)

# Dor Indexing App

The dor_indexing_app is the primary API for indexing DOR objects into the Argo index.
For more information about the fields and their purpose see: https://docs.google.com/spreadsheets/d/1_uYZvh-oihcxAM_Q24qJ_3nSaqAybmS362SYlDYwYqg/edit#gid=0

## Known Consumers
* There is a Karaf job that runs on a single node: `sulmq-prod-a:/opt/app/karaf/current/deploy/dor_prod_reindexing.xml` that queries solr for the least-recently-indexed items and indexes them
* There is a Camel route that sends messages from the fedora update topic https://github.com/sul-dlss/dor-camel-routes/blob/master/deploy/edu_stanford_dor-indexing-app-prod.indexing.xml#L116-L137

## Rolling indexer
This helps keep the index fresh by reindexing the oldest data.

```
RAILS_ENV=production bin/rolling_index start
RAILS_ENV=production bin/rolling_index stop

```

## API

See https://sul-dlss.github.io/dor_indexing_app/

## RabbitMQ Setup

NOTE: This is done automatically by Capistrano on deployment, so one generally shouldn't need to run this task manually. This is for informational purposes only.

In order for Sneakers jobs to work off durable queues populated by RabbitMQ, queues must first be bound to their corresponding topic exchanges (the ones to which appropriate messages are published):

```sh
RAILS_ENV=production bin/rake rabbitmq:setup
```

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
