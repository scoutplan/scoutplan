FROM ruby:3.4.2-alpine

RUN apk add --no-cache --update \
    build-base \
    linux-headers \
    ffmpeg \
    git \
    postgresql-dev \
    gcompat \
    tzdata \
    ttf-freefont \
    xvfb \
    libxrender-dev \
    fontconfig \
    yaml-dev \
    freetype \
    poppler \
    poppler-utils \
    ttf-dejavu \
    ttf-opensans \
    vips

# copy Gemfile & then bundle install dependencies
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install
COPY . /app

# Precompile assets for production
# SECRET_KEY_BASE is a dummy value only used for asset compilation, not the real secret
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy_key_for_assets bundle exec rake assets:precompile

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
