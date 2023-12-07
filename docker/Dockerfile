FROM ruby:3.2.2

WORKDIR /srv/app/datagovuk_publish

RUN apt-get update
RUN apt-get install -y nodejs postgresql postgresql-contrib

# To allow tests to be run with the test database
ENV DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL true

ENV DATAGOVUK_HOME /srv/app/datagovuk_publish

# Create datagovuk user
RUN useradd -r -u 900 -m -c "datagovuk account" -d $DATAGOVUK_HOME -s /bin/false datagovuk

COPY ./ $DATAGOVUK_HOME

RUN gem install bundler && bundle install

RUN chown -R datagovuk:datagovuk $DATAGOVUK_HOME
USER datagovuk

# TODO: check if we really need the datagovuk user to own DATAGOVUK_HOME
