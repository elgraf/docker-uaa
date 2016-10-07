SHELL=/bin/bash
NAME=uaa
TAG=$(shell git  describe --tags --abbrev=0)
UNAME=$(shell uname)
IMAGE=vgg/$(NAME}
DIR := ${CURDIR}

.PHONY: all

# docker build
all: download tarball build

download:
	if [ ! -e apache-tomcat-8.0.28.tar.gz ]; then wget -q https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz; fi \
	&& wget -qO- https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz.md5 | awk -F '[ *]+' -v P="$(DIR)" '{ cmd="cd "P";md5 -r "$$2; while ((cmd|getline result)>0) {}; close(cmd);  if ((result == $$1" "$$2) == 1) { exit 0 }; exit 1;}'

tarball:
	env COPY_EXTENDED_ATTRIBUTES_DISABLE=true COPYFILE_DISABLE=true \
		tar cvf base.tar --exclude '\._*' \
			*.yml				\
			*.sh				\
			*.tar.gz

# docker commands
build:
	docker build -t $(NAME):$(TAG) --rm .

deps:
	curl -L https://github.com/progrium/dockerhub-tag/releases/download/v0.2.0/dockerhub-tag_0.2.0_$(UNAME)_x86_64.tgz | tar -xzC /usr/local/bin

dockerhub-tag:
	dockerhub-tag set $(IMAGE) $(TAG) $(TAG) /
