.PHONY: build update

all: update build

build:
	docker build -t torbendury/cloudutils .

update:
	./scripts/gh-releases.sh