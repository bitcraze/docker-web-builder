FROM ruby:3.0.1-buster

RUN apt-get update && apt-get install -y --no-install-recommends \
		php7.3-cli php-xml \
		zip unzip \
		locales \
		ditaa \
		nodejs \
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
ENV DOCKER_VERSION 20.10.6
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin

# Set the locale to make ruby open text files as UTF-8 default
# (Encoding.default_external). Required to make html-proofer handle UTF-8.
ENV LANG C.UTF-8

# Jekyll is used to generate HTML from markdown
# html-proofer is used to validate html (including links)
# kramdown-math-katex is used to suport LaTex in the markdown, mainly for math
# therubyracer adds js support that is required by katex
RUN gem install jekyll:4.2.0 jekyll-feed html-proofer kramdown-math-katex:1.0.1 therubyracer webrick

# A note on kaTex and CSS
# The version of kaTex (used to generate html from LaTex) and the kaTex CSS that is used in the theme in this image and
# the bitcraze website theme, must match. If you update kramdown-math-katex, check the version of the CSS as well.
# The kramdown-math-katex ruby gem uses the katex ruby gem (https://github.com/glebm/katex-ruby) and it can tell
# you the version of katex that is used:
# 	irb
# 	require 'katex'
#	Katex::KATEX_VERSION

# Create gem for the docs jekyll theme
ADD docs-theme/ /docs-theme/
RUN cd /docs-theme; gem build docs-theme.gemspec; gem install /docs-theme/docs-theme-0.1.0.gem;

# Create a gem for the Jekyll-ditaa plugin
ADD jekyll-ditaa/ /jekyll-ditaa/
RUN cd /jekyll-ditaa; gem build jekyll-ditaa.gemspec; gem install /jekyll-ditaa/jekyll-ditaa-1.0.1.gem;

# Create a gem for the Jekyll-relative-links plugin
# Should be replaced with the official gem when pushed to ruby gems
ADD jekyll-relative-links/ /jekyll-relative-links/
RUN cd /jekyll-relative-links; gem build jekyll-relative-links.gemspec; gem install /jekyll-relative-links/jekyll-relative-links-0.6.2.gem;
# RUN gem install jekyll-relative-links

RUN mkdir /var/site && chmod 777 /var/site
ADD docs-config.yml /docs-config.yml

# The toolbelt docs command, maps <repo>/docs into /module/docs. On linux /module/docs will be owned by the correct user
# while /module is owned by root. The Jekyll server that serves the docs will try to create a meta data file in /module
# and will fail unless we make sure it exists and can be written by all users.
RUN mkdir /module && chmod 777 /module

WORKDIR /module
