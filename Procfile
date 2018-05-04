release: bin/rails db:migrate search:reindex
web: bin/rails server -p $PORT -e $RAILS_ENV
worker: bin/sidekiq
