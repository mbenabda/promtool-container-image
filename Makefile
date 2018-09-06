DOCKER_IMAGE_NAME=mbenabda/promtool
PROMTOOL_VERSION=

.PHONY: build publish sync sync_missing_versions

build: 
	docker build --build-arg=PROMTOOL_VERSION=$(PROMTOOL_VERSION) . -t $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)
	
publish: 
	docker push $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)

sync: build publish

sync_missing_versions: 
	set -e ;\
	TMP=$$(mktemp -d) ;\
	curl -s https://hub.docker.com/v2/repositories/prom/prometheus/tags/ | jq -r '.results[] | select(.name != "master" and .name != "latest") | .name' > $$TMP/prometheus.tags ;\
	curl -s https://hub.docker.com/v2/repositories/$(DOCKER_IMAGE_NAME)/tags/ | jq -r '.results[] | select(.name != "master" and .name != "latest") | .name' > $$TMP/promool.tags ;\
	grep -v -x -f $$TMP/promool.tags $$TMP/prometheus.tags > $$TMP/missing.tags ;\
	grep -v -x -f blacklist.tags $$TMP/missing.tags > $$TMP/filtered_missing.tags ;\
	cat $$TMP/filtered_missing.tags | xargs -I{} -n1 bash -c "make sync PROMTOOL_VERSION={}" ;\
