# FROM madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

FROM ruby:3.0.2-alpine

RUN apk add --no-cache --update \
    build-base \
    linux-headers \
    git \
    postgresql-dev \
    gcompat \
    tzdata \
    ttf-freefont \
    xvfb \
    libxrender-dev \
    fontconfig \
    freetype \
    wkhtmltopdf \
    ttf-dejavu \
    ttf-opensans \
    ttf-font-awesome  

# copy Gemfile & then bundle install dependencies
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN gem update bundler && bundle install
COPY . /app
RUN rake assets:precompile

# pull over an Alpine-friendly wkhtmltopdf binary, as described here:
# https://github.com/mileszs/wicked_pdf/issues/841#issuecomment-507759176
# COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin/wkhtmltopdf

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
