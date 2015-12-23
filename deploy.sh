#!/bin/sh

grunt build
rsync -va dist/ europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
# npm install --production
ssh europe@meu-strasbourg.org "svc -du ~/service/apply-meus"
