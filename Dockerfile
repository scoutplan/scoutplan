FROM ruby:3.2.2-alpine

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
RUN rake assets:precompile

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
