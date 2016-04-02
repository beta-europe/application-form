#!/bin/sh

export NODE_ENV=production
grunt build --force
rsync -va dist/ europe@beta-europe.org:/home/europe/projects/apply-symposium/
# this is just in order to minimize queries to node and use apache instead
# rsync -va dist/public/ europe@beta-europe.org:/home/europe/projects/apply-symposium/
# npm install --production
ssh europe@beta-europe.org "svc -du ~/service/apply-symposium"
