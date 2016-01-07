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

The default directory for the image is /module

    docker run --rm bitcraze/web-builder pwd

will print

    /module

## Interactive use

To use a container interactively with your current directory as a volume at 
/module

    docker run --rm -it -v ${PWD}:/module bitcraze/builder bash

# Limtations

1. On OS X and Windows, where the docker host is a virtual machine, the source
code you want to build must be located under /User (OS X) and c:\Users
(Windows). For more information see
https://docs.docker.com/userguide/dockervolumes/

1. We have not tested this on Windows, there might be limitations. Please
share.