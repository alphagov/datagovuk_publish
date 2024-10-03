FROM ghcr.io/alphagov/datagovuk_publish:3cbafbd8d3edbb8b2d0f903576ae43b6bda7b137

USER root
ENV BUNDLE_WITHOUT=""
ENV RAILS_ENV=development
RUN install_packages \
    g++ git gpg libc-dev libcurl4-openssl-dev libgdbm-dev libssl-dev \
    libmariadb-dev-compat libpq-dev libyaml-dev make xz-utils
RUN bundle install

USER app
