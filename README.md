# windows-2019-docker

A repo demonstrating building and running Windows .NET applications on a Mac.

Please Note: Files make the assumption that they are being run on a Mac, and are very Mac specific.

## Getting started

Run `./init.sh` in the root directory. This will perform the following steps:

1. Install homebrew if you don't already have it.
1. Update homebrew if you do already have it.
1. Install/update:
  * Vagrant
  * VirtualBox
  * Docker
1. Provision a Windows Server 2019 virtual machine using Vagrant and VirtualBox.
1. Perform a sniff test to ensure can talk to the Windows Server 2019 Docker Machine.

## Trying it out

The repo contains a sample `Dockerfile` and sample application adapted from the [Microsoft Samples](https://github.com/Microsoft/dotnet-framework-docker/tree/master/samples/aspnetapp).

Run the following to build and run the application:

```console
# Swap to the Windows Docker Machine
eval $(docker-machine env 2019)

# Get the Windows Docker Machine IP
export DOCKER_WINDOWS_HOST=$(docker-machine ip 2019)

# Build the app
docker build -t aspnet_sample .

# Run the app
docker run -it --rm -p 8000:80 --name aspnet_sample aspnet_sample

# Open the app in a browser
open "http://${DOCKER_WINDOWS_HOST}:8000"
```