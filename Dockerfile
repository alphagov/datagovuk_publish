# Use an official Ruby runtime as a parent image
FROM ruby:2.4.3-alpine

RUN apk update && \
    apk add --no-cache build-base postgresql-dev nodejs tzdata && \
    apk add curl wget bash vim && \
    apk add ruby ruby-bundler && \
    rm -rf /var/cache/apk/*

# Set the working directory to /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app
COPY Gemfile.lock /usr/src/app
RUN bundle install

# Copy the contents of the Rails app folder into the container
COPY . /usr/src/app
