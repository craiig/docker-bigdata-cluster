#!/bin/bash

run:
	./run-script.sh

generate-config-local:
	./run-script.sh config local

generate-config-cluster:
	./run-script.sh config

run-local: generate-config-local
	./run-script.sh

run-cluster: generate-config-cluster
	./run-script.sh

