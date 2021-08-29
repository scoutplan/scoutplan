# README

## Assumptions & pre-reqs

* You have a FontAwesome kit defined

* You have an Adobe Fonts kit defined

* Docker & docker-compose installed

## ENV vars (.env)

* FONT_AWESOME_KIT_ID
* ADOBE_KIT_ID
* DATABASE_HOST
* DATABASE_NAME
* DATABASE_USERNAME
* DATABASE_PASSWORD

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

