# awsyoutubesync

Given an AWS SES endpoint that delivers messages to an S3 bucket, parse youtube URLs from the files in the bucket and fetch them to local filesystem via youtube-dl

This allows me to send youtube video links in email (including the built-in "share via email" feature from youtube) to a known address, and the videos get archived on my home fileserver.