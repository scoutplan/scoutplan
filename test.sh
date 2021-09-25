# docker-compose run -e "RAILS_ENV=test" app bundle exec rspec
docker-compose run -e "RAILS_ENV=test" app sh -c "bundle exec rspec"
