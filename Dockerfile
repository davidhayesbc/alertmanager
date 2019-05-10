# escape=`
ARG nanoServerVersion=1809
FROM mcr.microsoft.com/powershell:nanoserver-$nanoServerVersion as build
ARG arcVersion=3.1.1
ARG alertmanagerVersion 
SHELL [ "pwsh", "-command" ]

#Download an archive tool
ENV arcUrl https://github.com/mholt/archiver/releases/download/v${arcVersion}/arc_windows_amd64.exe
RUN md c:\temp
RUN Invoke-WebRequest ($env:arcUrl) -UseBasicParsing -OutFile c:\temp\arc.exe

#Download AlertManager
ENV alertmanagerVersion $alertmanagerVersion
ENV alertmanagerUrl https://github.com/prometheus/alertmanager/releases/download/v${alertmanagerVersion}/alertmanager-${alertmanagerVersion}.windows-amd64.tar.gz
RUN Invoke-WebRequest ($env:alertmanagerUrl) -UseBasicParsing -OutFile c:\temp\alertmanager.tar.gz

#extract the archive
RUN c:\temp\arc.exe unarchive c:\temp\alertmanager.tar.gz c:\temp\alertmanager 
#Move the alertmanager Directory to take aout the version number
RUN mv c:\temp\alertmanager\alertmanager-$env:alertmanagerVersion.windows-amd64\ c:\temp\alertmanager\alertmanager

# Second build stage, copy the extracted files into a nanoserver container
FROM mcr.microsoft.com/windows/nanoserver:$nanoServerVersion
COPY --from=build /alertmanager/alertmanager/ /alertmanager
LABEL maintainer="david.hayes@spindriftpages.net"

#Expose a port from the container
EXPOSE     9093

ENTRYPOINT [ "C:\\alertmanager\\alertmanager.exe" ]

CMD        [ "--config.file=/alertmanager/alertmanager.yml"]