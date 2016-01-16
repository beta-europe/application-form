#!/bin/sh

export NODE_ENV=production
grunt build
rsync -va dist/ europe@beta-europe.org:/home/europe/projects/apply-meu-kiev/
# this is just in order to minimize queries to node and use apache instead
# rsync -va dist/public/ europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
# npm install --production
ssh europe@beta-europe.org "svc -du ~/service/apply-meu-kiev"
