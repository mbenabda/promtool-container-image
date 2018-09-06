ARG PROMTOOL_VERSION=


FROM prom/prometheus:"$PROMTOOL_VERSION" as prometheus


FROM alpine:3.8
COPY --from=prometheus /bin/promtool /bin/promtool
CMD [ "promtool" ]
