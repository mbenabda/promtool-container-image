# promtool
container image containing the promtool CLI ( https://github.com/prometheus/prometheus/tree/master/cmd/promtool ). 

Intended to be used in CI pipelines

Dockerhub
===
https://hub.docker.com/r/mbenabda/promtool/


Makefile
===
- Build promtool container images from a given version
```
make build PROMTOOL_VERSION=v1.7.1
```

- Publish built promtool container images
```
make publish PROMTOOL_VERSION=v1.7.1
```

- Build & publish promtool container images
```
make sync PROMTOOL_VERSION=v1.7.1
```

- sync promtool cointainer images missing from the promtool repos
```
make sync_missing_versions
```
