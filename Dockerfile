FROM ruby:2.7.3

# Args
ARG UID
ARG GID
ARG USER_NAME=hanami_poc

ARG FORCE_BUNDLER_VERSION="2.2.17"
ARG BUNDLE_JOBS=5
ARG BUNDLE_RETRY=2

ARG BASE_PATH=/home/${USER_NAME}
ARG APP_PATH=${BASE_PATH}/app
ARG APP_BUNDLE_PATH=${BASE_PATH}/bundle_cache
# ARG APP_SPROCKETS_CACHE_PATH=${BASE_PATH}/sprockets_cache
# ARG APP_BOOTSNAP_PATH=${BASE_PATH}/bootsnap_cache

# Env Bundler
ENV BUNDLER_VERSION=${FORCE_BUNDLER_VERSION}

# Env Bundle
ENV BUNDLE_PATH="${APP_BUNDLE_PATH}/vendor"
ENV BUNDLE_BIN="${APP_BUNDLE_PATH}/bin"
ENV BUNDLE_DISABLE_SHARED_GEMS=1

# NodeJs
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash
RUN apt-get update -y
RUN apt-get install -y --allow-unauthenticated nodejs

# Host-User equivalent (non-root)
RUN groupadd --gid $GID --non-unique ${USER_NAME}
RUN useradd --create-home --uid ${UID} --gid ${GID} --non-unique --shell /bin/bash ${USER_NAME}

# Set user
USER ${USER_NAME}

# Dirs
RUN mkdir ${APP_BUNDLE_PATH}
# RUN mkdir ${APP_SPROCKETS_CACHE_PATH}
# RUN mkdir ${APP_BOOTSNAP_PATH}
WORKDIR ${APP_PATH}

# RubyGems & Bundler
RUN echo "gem: --no-document" > ${BASE_PATH}/.gemrc
RUN gem install bundler --version ${BUNDLER_VERSION}

# Gems
COPY --chown=${USER_NAME}:${USER_NAME} Gemfile* ./
RUN bundle check || bundle install --jobs ${BUNDLE_JOBS} --retry ${BUNDLE_RETRY}

#
COPY . ./

#
EXPOSE 3000 1000 2000
CMD ["bundle", "exec", "hanami", "server", "--host", "0.0.0.0"]
