# Build
FROM golang:1.15-buster AS build
WORKDIR /go/src/github.com/mpolden/echoip
COPY . .

# Must build without cgo because libc is unavailable in runtime image
ENV GO111MODULE=on CGO_ENABLED=0
RUN make

# Run
FROM scratch
EXPOSE 8080

COPY --from=build /go/bin/echoip /opt/echoip/
COPY html /opt/echoip/html

ARG RAILWAY_ENVIRONMENT
ARG AccountID
ARG LicenseKey

RUN apt update && apt install wget curl tar -y
WORKDIR /opt
RUN curl -u $AccountID:$LicenseKey -o /opt/city.tar.gz "https://download.maxmind.com/geoip/databases/GeoLite2-City/download?suffix=tar.gz"
RUN tar -zxvf /opt/city.tar.gz
    
WORKDIR /opt/echoip
ENTRYPOINT ["/opt/echoip/echoip","-H","X-Real-IP"]
