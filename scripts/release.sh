#!/bin/bash

atlas_api="https://atlas.hashicorp.com/api/v1/box/hashbang/shell-server"
atlas_token=$(jq -r '.atlas_token' config.json)
bintray_user=$(jq -r '.bintray_user' config.json)
bintray_key=$(jq -r '.bintray_key' config.json)
version="$VERSION"

if [ ! -z "$VERSION+x" ]; then
	printf "Version number: "
	read version
fi

for file in dist/*; do \
	test -h $file && continue;
	artifact_file=$(basename $(readlink -f $file))
	artifact_name=${artifact_file%%.*}
	artifact_type=${artifact_name%-*}
	artifact_timestamp=${artifact_name##*-}

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
		docker tag hashbang/shell-server:latest hashbang/shell-server:$version
		docker push hashbang/shell-server:$version
		docker push hashbang/shell-server:latest
		exit 0
	fi

	if [ "$artifact_type" = "vagrant" ]; then
		curl -s "${atlas_api}/versions" \
    		-X POST \
    		-H "X-Atlas-Token: ${atlas_token}" \
    		-d "version[version]=${version}" | \
    		jq -e 'has("version")' > /dev/null || {
    			printf "\n\nAtlas API: Setting version failed"; exit 1;
    		}
		curl "${atlas_api}/version/${version}/providers" \
    		-X POST \
    		-H "X-Atlas-Token: ${atlas_token}" \
  			-d provider[name]='virtualbox' | \
    		jq -e 'has("created_at")' > /dev/null || {
    			printf "\n\nAtlas API: Setting provider failed"; exit 1;
    		}
		curl "${atlas_api}/version/${version}/provider/virtualbox/upload" \
			-H "X-Atlas-Token: ${atlas_token}" | {
				IFS= read -r response;
    			echo $response | jq -e 'has("upload_path")' > /dev/null || {
    				printf "\n\nAtlas API: Getting upload path failed"; exit 1;
				}
				upload_path=$(echo $response | jq -r '.upload_path')
				echo "Uploading $file to Atlas:"
				curl \
					--progress-bar \
					-X PUT \
					--upload-file \
					"${file}" "${upload_path}" | tee
			}
		curl "${atlas_api}/version/${version}/release" \
			-X PUT \
			-H "X-Atlas-Token: ${atlas_token}" | \
			jq -e 'has("version")' > /dev/null || {
    			printf "\n\nAtlas API: Setting release failed"; exit 1;
    		}
	fi

	echo "Uploading $file to bintray:"
	curl \
		--progress-bar \
		-T "$file" \
		-u "${bintray_user}:${bintray_key}" \
		"https://api.bintray.com/content/hashbang/shell-server/${artifact_type}/${artifact_version}/${artifact_file}" \
		| tee
	curl \
		--progress-bar \
		-T "${file}.sig" \
		-u "${bintray_user}:${bintray_key}" \
		"https://api.bintray.com/content/hashbang/shell-server/${artifact_type}/${artifact_version}/${artifact_file}.sig" \
		| tee

done

