# escape=`
ARG nanoServerVersion=1809
FROM mcr.microsoft.com/powershell:nanoserver-$nanoServerVersion as build
SHELL [ "pwsh", "-command" ]

#Download an archive tool
ENV arcVersion 3.1.1
ENV arcUrl https://github.com/mholt/archiver/releases/download/v${arcVersion}/arc_windows_amd64.exe
RUN Invoke-WebRequest ($env:arcUrl) -UseBasicParsing -OutFile arc.exe

#Download AlertManager
ENV alertmanagerVersion 0.16.1
ENV alertmanagerUrl https://github.com/prometheus/alertmanager/releases/download/v${alertmanagerVersion}/alertmanager-${alertmanagerVersion}.windows-amd64.tar.gz
RUN Invoke-WebRequest ($env:alertmanagerUrl) -UseBasicParsing -OutFile alertmanager.tar.gz

#extract the archive
RUN .\arc.exe unarchive .\alertmanager.tar.gz .\alertmanager 

# Second build stage, copy the extracted files into a nanoserver container
FROM mcr.microsoft.com/windows/nanoserver:$nanoServerVersion
ENV alertmanagerVersion 0.16.1
COPY --from=build /alertmanager/alertmanager-${alertmanagerVersion}.windows-amd64/ /alertmanager

#Expose a port from the container
EXPOSE     9093

ENTRYPOINT [ "C:\\alertmanager\\alertmanager.exe" ]

CMD        [ "--config.file=/alertmanager/alertmanager.yml"]