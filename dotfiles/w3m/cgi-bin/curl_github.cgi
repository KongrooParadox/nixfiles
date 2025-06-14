#!/usr/bin/env bash

# https://github.com/tats/w3m/issues/307#issuecomment-2619217788
# Circumvent GitHub not respecting our HTTP/1.0 request

printf "%s\n\n" "Content-Type: text/html"

curl -L https://github.com/${QUERY_STRING}
