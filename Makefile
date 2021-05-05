EMACS ?= emacs
CASK ?= cask

-include makefile-local

ifdef EMACS
EMACS_ENV=EMACS=$(EMACS)
endif

all: robot-and-test

install:
	$(EMACS_ENV) $(CASK) install

test: install just-test

all-test: all-robot-test test

build:
	$(EMACS_ENV) $(CASK) build

robot-and-test: basic-robot-test just-test

just-test:
	$(EMACS_ENV) $(CASK) emacs --batch -q \
	--directory=. \
	--load assess-discover.el \
	--eval '(assess-discover-run-and-exit-batch t)'

DOCKER_TAG=26
test-cp:
	docker run -it --rm --name docker-cp -v $(PWD):/usr/src/app -w /usr/src/app --entrypoint=/bin/bash  silex/emacs:$(DOCKER_TAG)-dev ./test-by-cp

test-git:
	docker run -it --rm --name docker-git -v $(PWD):/usr/src/app -w /usr/src/app --entrypoint=/bin/bash  silex/emacs:$(DOCKER_TAG)-dev ./test-from-git

docker-test:
	$(MAKE) test-git DOCKER_TAG=27.2
	$(MAKE) test-cp DOCKER_TAG=27.2
	$(MAKE) test-git DOCKER_TAG=26.3
	$(MAKE) test-cp DOCKER_TAG=26.3

clean-elc:
	$(CASK) clean-elc

all-robot-test: basic-robot-test leitner-robot-test all-card-robot-test spanish-robot-test

basic-robot-test: clean-elc
	$(EMACS_ENV) ./robot/basic-run.sh $(SMALL)

leitner-robot-test: clean-elc
	$(EMACS_ENV) ./robot/leitner-run.sh $(SMALL)

all-card-robot-test: clean-elc
	$(EMACS_ENV) ./robot/all-card-run.sh $(SMALL)

spanish-robot-test: clean-elc
	$(EMACS_ENV) ./robot/spanish-run.sh $(SMALL)

explainer-robot-test: clean-elc
	$(EMACS_ENV) ./robot/explainer-run.sh $(SMALL)

.PHONY: test
