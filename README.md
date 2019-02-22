# windows-2019-docker

A repo demonstrating building and running Windows .NET applications on a Mac.

Please Note: Files make the assumption that they are being run on a Mac, and are very Mac specific.

## Background

It can be a pain point developing .NET applications on a Mac. The aim of this repo was to prove that the developer experience could be streamlined using modern tooling such as Docker.

Largely based on the [https://github.com/StefanScherer/windows-docker-machine](https://github.com/StefanScherer/windows-docker-machine), as there is no point reinventing the wheel if someone has already done most of the legwork!

## Getting started

Run `./init.sh` in the root directory. This will perform the following steps:

1. Install homebrew if you don't already have it.
1. Update homebrew if you do already have it.
1. Install/update:

   - Vagrant
   - VirtualBox
   - Docker

1. Provision a Windows Server 2019 virtual machine using Vagrant and VirtualBox.
1. Perform a sniff test to ensure can talk to the Windows Server 2019 Docker Machine.

## Trying it out

The repo contains a sample `Dockerfile` and sample application adapted from the [Microsoft Samples](https://github.com/Microsoft/dotnet-framework-docker/tree/master/samples/aspnetapp).

Run the following to build and run the application:

```console
# Swap to the Windows Docker Machine
eval $(docker-machine env 2019)

# Enter the sample repo
cd ./sample

# Build the app
docker build -t aspnet_sample .

# Run the app
docker run -d --rm -p 8000:80 --name aspnet_sample aspnet_sample:latest

# Get the Windows Docker Machine IP
export DOCKER_WINDOWS_HOST=$(docker-machine ip 2019)

# Open the app in a browser
open "http://${DOCKER_WINDOWS_HOST}:8000"
```

To stop the application, run:

```console
docker stop aspnet_sample
```
