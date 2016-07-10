# Overview

This project will create a docker container with openvpn server, specifically to
be run within Amazon ECS.  The credentials files for the openvpn server are
stored within an s3 bucket, and the actual container instance that is run within
AWS is attached to an IAM profile which has read access to this s3 bucket.  This
keeps the secrets out of this repository.

# Container size

An attempt was made to keep the container size as small as possible, thus alpine
linux was selected. In order to retrieve the above mentioned openvpn credentials
from s3, an earlier version used amazons python cli to pull the files.  While
this functioned, it did increase the size of the image substantially, so in
order to reduce the size, a go program was written to pull down the credentials,
which is itself a much smaller binary compared to having to download a full
python runtime, the aws cli, plus other dependencies.

# [Serverspec](http://serverspec.org) within container

This shows a way to execute serverspec within a container without having to
install ruby or serverspec.  This will only do a static analysis though, but for
the purposes of this particular container this is fine since, without the
credentials embedded in the image, the container will not fully start up
anyways.

An interesting side effect of how the entrypoint is used along with how
serverspec is being called here, that the entrypoint is still executed, thus a
file is created at zero bytes due to the gets3files binary attempting to
download a file, but failing due to not having sufficient aws credentials.

## AWS command to get temporary credentials for Amazon Container Service

`aws ecr get-login`
