FROM ruby:2.3.0

MAINTAINER Kristoffer Richardsson <kristoffer@bitcraze.io>

RUN apt-get update && apt-get install -y --no-install-recommends \
		php5 \
		zip unzip \
		locales \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://get.docker.com/ | sh

# Set the locale to make ruby open text files as UTF-8 default
# (Encoding.default_external). Required to make html-proofer handle UTF-8.
ENV LANG C.UTF-8

RUN gem install compass jekyll jekyll-feed jekyll-compass html-proofer

WORKDIR /module
