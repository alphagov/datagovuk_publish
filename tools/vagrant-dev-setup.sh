git clone https://github.com/rbenv/rbenv.git ~/.rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.profile
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
rbenv install 2.4.0
rbenv global 2.4.0
gem install bundler
rbenv rehash
gem install pg -v '0.21.0'
gem install rails -v 5.1.4
cd /vagrant
gem install bundler --pre
bundle install
echo 'export SECRET_KEY_BASE=meh' >> ~/.profile
echo 'export RAILS_ENV=development' >> ~/.profile
echo 'export DEVISE_SECRET_KEY=bah' >> ~/.profile
echo 'export ES_HOST=10.0.2.2:9200' >> ~/.profile
echo 'export REDIS_IP=10.0.2.2' >> ~/.profile
echo 'export REDIS_PORT=6379' >> ~/.profile
echo 'export REDIS_PASSWORD=blah' >> ~/.profile

export SECRET_KEY_BASE=meh
export RAILS_ENV=development
export DEVISE_SECRET_KEY=bah
export ES_HOST=10.0.2.2:9200
export REDIS_IP=10.0.2.2
export REDIS_PORT=6379
export REDIS_PASSWORD=blah

rails db:drop db:create db:schema:load db:seed
