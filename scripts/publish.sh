#!/bin/bash

for file in dist/*; do \
	test -h $file && continue;
	artifact_file=$(basename $(readlink -f $file))
	artifact_name=${artifact_file%%.*}
	artifact_type=${artifact_name%-*}
	artifact_version=${artifact_name##*-}
	gpg \
		--local-user D2C4C74D8FAA96F5 \
		--detach-sig \
		$file
	if [ "$artifact_type" = "docker" ]; then
		docker_user=$(jq -r '.docker_user' config.json)
		docker_pass=$(jq -r '.docker_pass' config.json)
		docker login -u $docker_user -p $docker_pass
		docker import - "hashbang/shell-server:$artifact_version" < "$file"
		docker tag hashbang/shell-server:latest hashbang/shell-server:latest
		docker push hashbang/shell-server:latest
		docker push hashbang/shell-server:$artifact_version
	fi
done

