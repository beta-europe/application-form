#!/bin/sh

meteor build build
scp build/apply-meus.tar.gz europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
scp settings.json europe@meu-strasbourg.org:/home/europe/projects/apply-meus/settings.json

ssh europe@meu-strasbourg.org "\
cd /home/europe/projects/apply-meus && \
svc -d ~/service/apply-meus && \
tar -xvf apply-meus.tar.gz && \
svc -u ~/service/apply-meus"
