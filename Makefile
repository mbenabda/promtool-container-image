DOCKER_IMAGE_NAME?=mbenabda/promtool
PROMTOOL_VERSION=
BASE_IMAGE=

.PHONY: build publish sync sync_missing_versions

build: 
	docker build --build-arg=PROMTOOL_VERSION=$(PROMTOOL_VERSION) \
				 --build-arg=BASE_IMAGE=scratch \
				 . -t $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)

	docker build --build-arg=PROMTOOL_VERSION=$(PROMTOOL_VERSION) \
				 --build-arg=BASE_IMAGE=alpine:3.8 \
				 . -t $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)-alpine

publish: 
	docker push $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)
	docker push $(DOCKER_IMAGE_NAME):$(PROMTOOL_VERSION)-alpine

sync: build publish

sync_missing_versions:
	set -e; \
	TMP=$$(mktemp -d); \
	touch "$$TMP/promtool.tags"; \
	touch "$$TMP/prometheus.tags"; \
	\
	curl -s https://hub.docker.com/v2/repositories/prom/prometheus/tags/ > $$TMP/page.json; \
	cat $$TMP/page.json | jq -r '.results[] | .name' >> "$$TMP/prometheus.tags"; \
	NEXT_PAGE=$$(cat $$TMP/page.json | jq -rM '.next'); \
	while [ "$$NEXT_PAGE" != "null" ]; \
	do \
		sleep 0.5; \
		curl -s "$$NEXT_PAGE" > $$TMP/page.json; \
		cat $$TMP/page.json | jq -r '.results[] | .name' >> "$$TMP/prometheus.tags"; \
		NEXT_PAGE=$$(cat $$TMP/page.json | jq -rM '.next'); \
	done; \
	\
	curl -s https://hub.docker.com/v2/repositories/$(DOCKER_IMAGE_NAME)/tags/ > $$TMP/page.json; \
	cat $$TMP/page.json | jq -r '.results[] | .name' >> "$$TMP/promtool.tags"; \
	NEXT_PAGE=$$(cat $$TMP/page.json | jq -rM '.next'); \
	while [ "$$NEXT_PAGE" != "null" ]; \
	do \
		sleep 0.5; \
		curl -s "$$NEXT_PAGE" > $$TMP/page.json; \
		cat $$TMP/page.json | jq -r '.results[] | .name' >> "$$TMP/promtool.tags"; \
		NEXT_PAGE=$$(cat $$TMP/page.json | jq -rM '.next'); \
	done; \
	\
	(grep -v -x -f "$$TMP/promtool.tags" "$$TMP/prometheus.tags" > "$$TMP/missing.tags") || true; \
	(grep -v -x -f blacklist.tags "$$TMP/missing.tags" > "$$TMP/filtered_missing.tags") || true; \
	touch "$$TMP/filtered_missing.tags"; \
	cat "$$TMP/filtered_missing.tags" | sort | xargs -I{} -n1 bash -c "make sync PROMTOOL_VERSION={}"; \

