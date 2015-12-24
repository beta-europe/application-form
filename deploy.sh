#!/bin/sh

grunt build
rsync -va dist/ europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
# this is just in order to minimize queries to node and use apache instead
# rsync -va dist/public/ europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
# npm install --production
ssh europe@meu-strasbourg.org "svc -du ~/service/apply-meus"
