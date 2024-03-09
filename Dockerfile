ARG GO_VERSION=1.22
FROM golang:${GO_VERSION}-bookworm AS base

# Set up working directory and base config
ARG APP_DIR="/opt/app"
ENV APP_DIR="${APP_DIR}"
RUN mkdir -p "${APP_DIR}" &&\
  chown -R 1000:1000 "${APP_DIR}";
WORKDIR ${APP_DIR}

# Install dependent software
RUN apt-get update -qq &&\
  apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates &&\
  # Clean up after aptitude
  apt-get autoremove -y && apt-get clean -y &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;


###
# Development Stage
#  - Use the `DEV_PACKAGES` argument to install additional
#    desired 'personal preference' packages within development.
#  - As an example, `zsh` to make the container terminal more like the
#    host terminal.
###
FROM base AS develop
ARG DEV_PACKAGES
RUN apt-get update -qq &&\
  apt-get install -y --no-install-recommends \
  curl \
  git \
  ssh \
  ${DEV_PACKAGES} &&\
  # Clean up after aptitude
  apt-get autoremove -y && apt-get clean -y &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# Since this is a development container, the command should just run the
# container without starting any "real" processes, as those will be run
# as part of the development itself.
CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]

###
# Builder Stage
###
FROM base AS builder
# Build the app


###
# Production Stage
###
FROM debian:bookworm-slim AS prod
# Copy the built app
# Run the app
