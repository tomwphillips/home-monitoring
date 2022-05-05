#!/bin/bash

set -eu

GCLOUD_IMAGE="eu.gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine"
GCLOUD_CONTAINER="gcloud"

function finish {
    rm backups/*
}

trap finish EXIT

docker-compose exec -u "$UID" -e INFLUX_TOKEN="$INFLUX_TOKEN" influxdb influx backup /backups

if [ -z "$(docker ps -q -a -f name=$GCLOUD_CONTAINER)" ]; then
    docker run --name $GCLOUD_CONTAINER -v ~/gcp_sa_key.json:/key.json \
        "$GCLOUD_IMAGE" \
        gcloud auth activate-service-account --key-file key.json
fi

docker run --rm --volumes-from $GCLOUD_CONTAINER \
    --mount type=bind,source="$(pwd)/backups",target=/backups \
    "$GCLOUD_IMAGE" gsutil cp -r "/backups/*" gs://rpi-alpha-backup/
