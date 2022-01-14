[![CircleCI](https://circleci.com/gh/sul-dlss/dor_indexing_app.svg?style=svg)](https://circleci.com/gh/sul-dlss/dor_indexing_app)
[![Maintainability](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/maintainability)](https://codeclimate.com/github/sul-dlss/dor-services-app/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/955223f2386ae5f10e33/test_coverage)](https://codeclimate.com/github/sul-dlss/dor-services-app/test_coverage)
[![OpenAPI Validator](http://validator.swagger.io/validator?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)](http://validator.swagger.io/validator/?url=https://raw.githubusercontent.com/sul-dlss/dor_indexing_app/main/openapi.yml)

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

## API

See sul-dlss.github.io/dor_indexing_app/

### Docker

Build image:
```
docker image build -t suldlss/dor-indexing-app:latest .
```

Publish:
```
docker push suldlss/dor-indexing-app:latest
```
