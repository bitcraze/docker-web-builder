# Bitcraze web builder

This image is used to build Bitcraze web projects. It contains all the tools
needed to develop, build and run web projects. The intention is to reduce problems
with installation of languages and frameworks, and to simplify building. If a build
with the image passes on one machine it should also pass on another.

The image currently supports ruby and php.

# Usage

## Building

The standard use case is to call a build or test script

    docker run --rm -it -v ${PWD}:/module bitcraze/web-builder tools/build/build

## Development

The image is also used by scripts in web projects for running servers when
developing.

## Image structure

The default directory for the image is `/module`

    docker run --rm bitcraze/web-builder pwd

will print

    /module

## Interactive use

To use a container interactively with your current directory as a volume at
`/module`

    docker run --rm -it -v ${PWD}:/module bitcraze/web-builder bash

# Docs theme

The docs-theme directory contains a simple jekyll theme that is used to
serve the docs directory of a repository locally when writing docs.

Example usage:

    docker run --rm -it --volume=$PWD/docs:/module -p 80:80 bitcraze/web-builder jekyll serve --host 0.0.0.0 --port 80  --incremental --config /docs-config.yml
