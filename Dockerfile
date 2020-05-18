# This Dockerfile is used with the docker-ckan dev stack
FROM ruby:2.6.6

WORKDIR /srv/app/src_extensions/datagovuk_publish

RUN apt-get update
RUN apt-get install -y nodejs postgresql postgresql-contrib

COPY ./ /srv/app/src_extensions/datagovuk_publish

RUN gem install bundler --conservative && \
    bundle install
