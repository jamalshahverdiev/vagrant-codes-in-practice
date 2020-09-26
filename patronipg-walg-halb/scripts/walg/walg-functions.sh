#!/usr/bin/env bash

checkVariables() {
    if [ $USER != "postgres" ]; then
        echo "Script must be run as user: postgres"
        exit -1
    fi

    if [[ -z "$WALG_S3_PREFIX" ]]; then
      echo 'WALG_S3_PREFIX variables are undefined'
      exit 1
    fi

    if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
      echo 'AWS_ACCESS_KEY_ID variables are undefined'
      exit 1
    fi

    if [[ -z "$AWS_ENDPOINT" ]]; then
      echo 'AWS_ENDPOINT variables are undefined'
      exit 1
    fi

    if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
      echo 'AWS_SECRET_ACCESS_KEY variables are undefined'
      exit 1
    fi

    if [[ -z "$PGDATA" ]]; then
      echo 'PGDATA variables are undefined'
      exit 1
    fi
}

