#!/bin/bash

AUTH=`echo -n "$1":"$2" | base64`

mkdir -p ./.docker
/bin/cat <<EOM >./.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "$AUTH"
		}
	}
}
EOM


