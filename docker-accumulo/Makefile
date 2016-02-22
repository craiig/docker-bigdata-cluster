
all:

CONTAINERTAG := accumulo

build: Dockerfile
	docker build -t $(CONTAINERTAG) .

run_shell:
	docker run -ti $(CONTAINERTAG) bash
