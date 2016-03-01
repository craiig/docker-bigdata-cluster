# a basic setup for hadoop configs
# given a master hostname, builds configurations for hadoop clients to use


include ../Makefile.options
#HADOOP_MASTER_HOSTNAME_FILE := ../docker-hadoop/build/hostname
#HADOOP_MASTER_HOSTNAME := $(shell cat $(HADOOP_MASTER_HOSTNAME_FILE))
OUT := out/

$(OUT):
	mkdir -p $(OUT)

#list of all templates to generate
generated := $(patsubst templates/%.template,$(OUT)/%,$(wildcard templates/*))
# templates/core-site.xml.template -> out/core-site.xml
all: $(OUT) $(generated)

clean:
	-rm -rf $(OUT)/*

$(OUT)/%: templates/%.template
	sed s/{{MASTER}}/${HADOOP_MASTER_HOSTNAME}/g $< > $@

install: $(generated)
	rsync -rav static/* $(HADOOP_CONFIG_DIR)
	cp $(OUT)/* $(HADOOP_CONFIG_DIR)
