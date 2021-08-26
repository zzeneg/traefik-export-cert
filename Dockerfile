FROM alpine

RUN apk --no-cache add bash jq inotify-tools

COPY export.sh /

RUN chmod +x /export.sh

ENTRYPOINT /export.sh