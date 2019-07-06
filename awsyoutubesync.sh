#!/bin/bash

# BEGIN EDITING HERE (or put this stuff in ~/.awsyoutubesync.env )
LOCKFILE=/var/tmp/awsyoutubesync/lockfile
S3BUCKET=NOT_A_VALID_BUCKET_NAME
S3DIR=/var/tmp/awsyoutubesync/s3
VIDEODIR=/var/tmp/awsyoutubesync/videos
VIDEONAME="%(channel)s - %(uploader)s - %(title)s.%(ext)s"
# STOP EDITING HERE

if [[ -f ~/.awsyoutubesync.env ]]; then
    source ~/.awsyoutubesync.env
fi

function sync_s3_to_local()
{
    aws s3 sync ${S3BUCKET} ${S3DIR}/
}

function fetch_youtube_links()
{
    cd $S3DIR
    for file in $(ls)
    do
	cat $file | \
	    tr -d "\n\r" | \
	    grep -Eo 'https://www.youtube.com/[a-zA-Z0-9=?&]+' $file | \
	    sort -u | \
	    youtube-dl --batch-file - \
		       --continue \
		       --no-overwrites \
		       --write-thumbnail \
		       --ignore-errors \
		       -o "${VIDEODIR}/${VIDEONAME}"
	if [[ $? -eq 0 ]]; then
	    aws s3 rm ${S3BUCKET}/$file
	fi
    done
}

function main()
{
    if [[ ! -f ${LOCKFILE} ]]; then
	touch ${LOCKFILE}
	trap "rm -f ${LOCKFILE}" EXIT
    else
	exit 1
    fi
    mkdir -p ${S3DIR}
    mkdir -p ${VIDEODIR}
    cd $LOCALDIR
    sync_s3_to_local
    fetch_youtube_links
    rm -fr ${S3DIR}/*
}

main
