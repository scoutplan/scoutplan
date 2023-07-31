# https://stackoverflow.com/questions/71040681/qemu-x86-64-could-not-open-lib64-ld-linux-x86-64-so-2-no-such-file-or-direc
FROM --platform=linux/amd64 madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

FROM ruby:3.2.2-alpine

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
    libssl1.1 \
    fontconfig \
    freetype \
    # wkhtmltopdf \
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

# pull over an Alpine-friendly wkhtmltopdf binary, as described here:
# https://github.com/mileszs/wicked_pdf/issues/841#issuecomment-507759176
COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin/wkhtmltopdf

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
