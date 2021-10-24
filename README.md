# README

## Application Performance

[![View performance data on Skylight](https://badges.skylight.io/problem/R3sADLfgeNb2.svg)](https://oss.skylight.io/app/applications/R3sADLfgeNb2)
[![View performance data on Skylight](https://badges.skylight.io/typical/R3sADLfgeNb2.svg)](https://oss.skylight.io/app/applications/R3sADLfgeNb2)
[![View performance data on Skylight](https://badges.skylight.io/rpm/R3sADLfgeNb2.svg)](https://oss.skylight.io/app/applications/R3sADLfgeNb2)
[![View performance data on Skylight](https://badges.skylight.io/status/R3sADLfgeNb2.svg)](https://oss.skylight.io/app/applications/R3sADLfgeNb2)

## Assumptions & pre-reqs

* You have a FontAwesome kit defined

* You have an Adobe Fonts kit defined

* Docker & docker-compose installed

* Mapbox account


## Set up local HTTPS

See https://codewithhugo.com/docker-compose-local-https/ for inspiration

* `brew install mkcert`

* `mkcert -install`

* add to /etc/hosts: `127.0.0.1 local.scoutplan.org`


## ENV vars (.env)

### Secrets

* FONT_AWESOME_KIT_ID
* ADOBE_KIT_ID
* DATABASE_HOST
* DATABASE_NAME
* DATABASE_USERNAME
* DATABASE_PASSWORD
* REDIS_URL
* SENTRY_DSN
* SKYLIGHT_AUTHENTICATION
* SKYLIGHT_ENABLED (set to true)
* MAPBOX_TOKEN
* DO_STORAGE_SECRET
* TWILIO_SID
* TWILIO_TOKEN
* TWILIO_NUMBER

### Config vars

* DO_STORAGE_KEY_ID
* DO_STORAGE_REGION
* DO_BUCKET
* DO_STORAGE_ENDPOINT

## Docker Compose

Create docker-compose.override.yml in the project root and populate thusly:

```
services:
  db:
    image: postgres:13-alpine
    command: ["postgres", "-c", "fsync=false", "-c", "full_page_writes=off"]
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  app:
    depends_on:
      - db
```

Tag and push the image to DO...

```
docker tag scoutplan_app registry.digitalocean.com/scoutplan/scoutplan_app
docker push registry.digitalocean.com/scoutplan/scoutplan_app
```

## Email in development

The Docker Compose stack includes mailcatcher. Once the stack's up, visit http://localhost:1080 to see your mail


## Flipper

Some features are gated by Flipper and need to be enabled:

* :daily_reminder
* :receive_event_publish_notice
* :receive_bulk_publish_notice
* :receive_rsvp_confirmation
* :receive_digest
* :receive_daily_reminder
* :weekly_digest
