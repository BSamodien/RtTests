#!/bin/bash

root="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
output=${output:-"$root/.out"}
image=${image:-'rt-tests:latest'}
name=${name:-'rt-tests'}
build=${build:-n}

# Hack to use named parameter
while [ $# -gt 0 ]; do

  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
  fi

  shift
done

#podman rmi $(podman images -f 'dangling=true' -q)

iid=$( podman images ${image} -q )
if [ "${build,,}" == "y" ] || [ "${build,,}" == "yes" ]; then
    iid=''
fi

if [ "${iid}" == "" ]; then
    podman build -t ${image} -f RtTests.dockerfile
fi

id=$( podman run -d --rm --name=${name} ${image} tail -f /dev/null)
mkdir -p ${output}
podman cp ${name}:/app/dist/rt-tests.tar.gz "${output}/"
podman stop ${name}
