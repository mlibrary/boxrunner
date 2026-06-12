# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.9
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

WORKDIR /rails

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3" \
    PATH="/usr/local/node/bin:${PATH}" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential curl git libjemalloc2 libvips sqlite3 libyaml-dev node-gyp pkg-config python-is-python3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG NODE_VERSION=26.0.0
ARG YARN_VERSION=1.22.22
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@"${YARN_VERSION}" && \
    rm -rf /tmp/node-build-master

COPY Gemfile Gemfile.lock ./
COPY package.json yarn.lock ./
COPY vendor/ ./vendor/

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    yarn install --immutable

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

USER rails

CMD ["sleep", "infinity"]

