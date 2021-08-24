# https://scotto.medium.com/2021-docker-ruby-3-rails-6-puma-nginx-postgres-d84c95f68637
FROM ruby:3.0.2

# install node & yarn
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN npm install -g yarn@1
RUN mkdir /app

# copy Gemfile & then bundle install dependencies
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

EXPOSE 3000

# RUN SECRET_KEY_BASE=1 RAILS_ENV=production bundle exec rake assets:precompile
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
