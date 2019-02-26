ARG PROMTOOL_VERSION=
ARG BASE_IMAGE=alpine:3.8

FROM prom/prometheus:"$PROMTOOL_VERSION" as prometheus

FROM $BASE_IMAGE
COPY --from=prometheus /bin/promtool /bin/promtool
CMD [ "promtool" ]
