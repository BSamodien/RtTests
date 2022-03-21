#!/bin/bash

root="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
output="$( cd -- "$(dirname "${root}/.")" >/dev/null 2>&1 ; pwd -P )/.out"
image=${image:-'rt-kernel:5.16.2-rt19'}
name=${name:-'rt-kernel'}
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
    podman build -t ${image} -f RtKernel.dockerfile
fi

id=$( podman run -d --rm --name=${name} ${image} tail -f /dev/null)
mkdir -p ${output}
podman cp ${name}:/app/dist/. "${output}/"
podman stop ${name}
