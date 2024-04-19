FROM registry.fedoraproject.org/fedora-minimal:latest as build
LABEL maintainer="Simon Krenger <simon@krenger.ch>"
WORKDIR /go/src/iperf3_exporter
# Not ideal as it also copies all the git objects, but it is only the build container   
COPY . .
RUN microdnf install -y golang git && go get
# http://blog.wrouesnel.com/articles/Totally%20static%20Go%20builds/
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o iperf3_exporter .

FROM alpine:latest
LABEL maintainer="Edgard Castro <edgardcastro@gmail.com>, Simon Krenger <simon@krenger.ch>"
COPY --from=build /go/src/iperf3_exporter/iperf3_exporter /bin/iperf3_exporter

ENTRYPOINT ["/bin/iperf3_exporter"]
EXPOSE     9579
