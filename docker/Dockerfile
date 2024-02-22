ARG ruby_version=3.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* ./
RUN bundle install
COPY . ./


FROM $base_image

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $APP_HOME .

USER app
# CMD ["sidekiq"]

LABEL org.opencontainers.image.source=https://github.com/alphagov/datagovuk_publish
