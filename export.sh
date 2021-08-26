#!/bin/bash

test -z $RESOLVER && echo "RESOLVER is missing" && exit 1
test -z $DOMAIN && echo "DOMAIN is missing" && exit 1

ACME="/acme.json"
EXPORT_CERT="/export/${DOMAIN}.crt"
EXPORT_KEY="/export/${DOMAIN}.key"

function export() {
    TEMP_CERT="$(mktemp)"
    TEMP_KEY="$(mktemp)"

    cat "$ACME" | jq -r ".${RESOLVER}.Certificates[] | select(.domain.main==\"${DOMAIN}\") | .certificate" | base64 -d > "$TEMP_CERT"
    cat "$ACME" | jq -r ".${RESOLVER}.Certificates[] | select(.domain.main==\"${DOMAIN}\") | .key" | base64 -d > "$TEMP_KEY"

    if  diff -q -N "$EXPORT_CERT" "$TEMP_CERT" > /dev/null && diff -q -N "$EXPORT_KEY" "$TEMP_KEY" > /dev/null; then
        echo "Certificate and key did not change"
    else
        echo "Certificate or key were updated"
        mv "$TEMP_CERT" "$EXPORT_CERT"
        mv "$TEMP_KEY" "$EXPORT_KEY"
    fi
}

export

while true; do
    inotifywait -qq -e modify "$ACME"
    export
done