FROM ruby:2.6.3

MAINTAINER Kristoffer Richardsson <kristoffer@bitcraze.io>

RUN apt-get update && apt-get install -y --no-install-recommends \
		php7.3-cli php-xml \
		zip unzip \
		locales \
		ditaa \
	&& rm -rf /var/lib/apt/lists/*

# Add wkhtmltopdf, see https://hub.docker.com/r/icalialabs/wkhtmltopdf and https://github.com/IcaliaLabs/docker-wkhtmltopdf

ENV WKHTMLTOX_VERSION=0.12.5
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		fontconfig \
		fontconfig-config \
		fonts-dejavu-core \
		libbsd0 \
		libexpat1 \
		libfontconfig1 \
		libfontenc1 \
		libfreetype6 \
		libjpeg62-turbo \
		libpng16-16 \
		libssl1.1 \
		libx11-6 \
		libx11-data \
		libxau6 \
		libxcb1 \
		libxdmcp6 \
		libxext6 \
		libxfont2 \
		libxrender1 \
		ucf \
		x11-common \
		xfonts-75dpi \
		xfonts-base \
		xfonts-encodings \
		xfonts-utils \
  	&& rm -rf /var/lib/apt/lists/*

COPY --from=icalialabs/wkhtmltopdf:0.12.5-stretch /usr/local/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf

# Install docker
ENV DOCKER_VERSION 19.03.1
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin

# Set the locale to make ruby open text files as UTF-8 default
# (Encoding.default_external). Required to make html-proofer handle UTF-8.
ENV LANG C.UTF-8

RUN gem install jekyll jekyll-feed html-proofer

# Create gem for the docs jekyll theme
ADD docs-theme/ /docs-theme/
RUN cd /docs-theme; gem build docs-theme.gemspec; gem install /docs-theme/docs-theme-0.1.0.gem;

# Create a gem for the Jekyll-ditaa plugin
ADD jekyll-ditaa/ /jekyll-ditaa/
RUN cd /jekyll-ditaa; gem build jekyll-ditaa.gemspec; gem install /jekyll-ditaa/jekyll-ditaa-1.0.1.gem;

RUN mkdir /var/site; chmod 777 /var/site
ADD docs-config.yml /docs-config.yml

WORKDIR /module
