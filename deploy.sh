#!/bin/sh

meteor build build
scp build/applicationFormt-meteor.tar.gz riemann.cc:/home/rriemann/projects/uiaed
scp settings-production.json riemann.cc:/home/rriemann/projects/uiaed/settings-production.json

ssh riemann.cc "\
cd /home/rriemann/projects/uiaed && \
svc -d ~/service/uiaed && \
tar -xvf uiaed-meteor.tar.gz && \
svc -u ~/service/uiaed"
