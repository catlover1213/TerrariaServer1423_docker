FROM ubuntu:latest AS base
WORKDIR /usr/local/tserver
EXPOSE 7777
COPY ./server /usr/local/tserver 
ENTRYPOINT ["./TerrariaServer.bin.x86_64","-config","serverconfig.txt"]
