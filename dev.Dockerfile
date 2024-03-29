FROM microsoft/dotnet-framework:4.7.2-sdk

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature enable -n allowGlobalConfirmation;

RUN choco install \
    nodejs.install;

RUN Add-WindowsFeature \
    Web-server, \
    NET-Framework-45-ASPNET, \
    Web-Asp-Net45;

COPY package*.json C:/tmp/
RUN cd C:/tmp; \
    npm install; \
    npm install pm2 -g; \
    Move-Item -Path C:/tmp/node_modules -Destination C:/node_modules;

RUN rm -r C:\inetpub\wwwroot

COPY scripts/watcher.js .

WORKDIR C:/app

EXPOSE 80

ENTRYPOINT [ "powershell" ]