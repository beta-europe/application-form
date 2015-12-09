#!/bin/sh

TMPDIR=`mktemp -d` || exit 1
meteor build --directory $TMPDIR
rsync -va $TMPDIR/ europe@meu-strasbourg.org:/home/europe/projects/apply-meus/
scp settings.json europe@meu-strasbourg.org:/home/europe/projects/apply-meus/settings.json

ssh europe@meu-strasbourg.org "svc -du ~/service/apply-meus"

rm -fr $TMPDIR