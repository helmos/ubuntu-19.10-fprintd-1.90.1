#!/bin/bash

docker build -t fingerprint:latest . && docker run -it --rm -v `pwd`:/bld fingerprint:latest  sh -c 'mv /*.deb /bld'
