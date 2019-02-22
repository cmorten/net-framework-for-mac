FROM microsoft/dotnet-framework:4.7.2-sdk AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY sample/*.sln .
COPY sample/aspnetapp/*.csproj ./aspnetapp/
COPY sample/aspnetapp/*.config ./aspnetapp/
RUN nuget restore

# Copy everything else and build app
COPY sample/aspnetapp/. ./aspnetapp/
WORKDIR /app/aspnetapp
RUN msbuild /p:Configuration=Release


# Build the final container
FROM microsoft/aspnet:4.7.2 AS runtime
WORKDIR /inetpub/aspnetapp
COPY --from=build /app/aspnetapp/. ./
