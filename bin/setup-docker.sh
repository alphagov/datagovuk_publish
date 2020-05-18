#!/bin/bash
# This setup script is used with the docker-ckan dev stack

echo '===== Setup datagovuk publish ====='

RETRIES=10
until psql -h db -U ckan -d ckan -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
    sleep 1
done

bin/rails db:setup
rails db:environment:set RAILS_ENV=development

# wait until elasticsearch is running
until [ "$health" = 'yellow' -o "$health" = 'green' ]; do
    health="$(curl -fsSL "elasticsearch:9200/_cat/health?h=status")"
    if [ "$health" != 'yellow' -a "$health" != 'green' ]; then
        echo "Elastic Search is unavailable - sleeping"
        sleep 1
    fi
done

bin/rails search:reindex
mkdir -p /var/log/sidekiq
bundle exec sidekiq 2>&1 | tee /var/log/sidekiq/sidekiq.log
