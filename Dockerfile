FROM ruby:2.7.5

WORKDIR /srv/app/datagovuk_publish

RUN apt-get update
RUN apt-get install -y nodejs postgresql postgresql-contrib

# To allow tests to be run with the test database
ENV DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL true

COPY ./ /srv/app/datagovuk_publish

RUN gem install bundler --conservative && \
    bundle install
