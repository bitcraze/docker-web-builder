FROM ruby:2.6.3

MAINTAINER Kristoffer Richardsson <kristoffer@bitcraze.io>

RUN apt-get update && apt-get install -y --no-install-recommends \
		php7.3-cli php-xml \
		zip unzip \
		locales \
	&& rm -rf /var/lib/apt/lists/*

# Install docker
ENV DOCKER_VERSION 19.03.1
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin

# Install kubectl
ENV KUBECTL_VERSION 1.14.6
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Set the locale to make ruby open text files as UTF-8 default
# (Encoding.default_external). Required to make html-proofer handle UTF-8.
ENV LANG C.UTF-8

RUN gem install jekyll jekyll-feed html-proofer

# Create gem for the docs jekyll theme
ADD docs-theme/ /docs-theme/
RUN cd /docs-theme; gem build docs-theme.gemspec; gem install /docs-theme/docs-theme-0.1.0.gem;

RUN mkdir /var/site; chmod 777 /var/site
ADD docs-config.yml /docs-config.yml

WORKDIR /module
