##############################################################
# Author: raila@illinois.edu
##############################################################
IMAGES 	:= fedora code-insiders clang gcc7 \
				dev-centos-69
#dsidev centos69  gcc7-centos69 dsidev-centos69 
VOLUMES	:= gcc7-src clang-src
ORG 		:= dr/

#  Deps - order dependent builds
#code-insiders: fedora
#dsidev: code-insiders

##############################################################
# Configuration options
##############################################################

##############################################################
# BUILDDIR  - 	storage for all build things and dependency mgmt
##############################################################
BUILDDIR	:= _output
BUILDFILES		= $(IMAGES:%=Dockerfile.%)
TIMESTAMPS		= $(IMAGES:%=$(BUILDDIR)/%.d)
PUSHTARGETS		= $(IMAGES:%=$(BUILDDIR)/%.d.push)
PATCH				= $(shell git symbolic-ref --short HEAD || true)
DOTPATCH			= $(PATCH:%=.%)
RELEASE			?=
ORG				?=
CACHE				=

all:				$(TIMESTAMPS)
.PHONY:			all clean realclean ALWAYS

$(BUILDDIR):
	@-mkdir -p $(BUILDDIR)
$(TIMESTAMPS):  |$(BUILDDIR)
$(TIMESTAMPS): $(MAKEFILE_LIST)

##############################################################
# Pull timestamps from docker to filesystem for make
# Relies on make restart after setting timestamps in submake
# timestamp = docker image build time or now-10years
##############################################################
-include $(BUILDDIR)/timestamps.d
ifdef DOCKER_TIMESTAMPS
$(BUILDDIR)/timestamps.d: $(BUILDDIR)
	@-touch $(BUILDDIR)/timestamps.d
$(BUILDDIR)/%.d : ALWAYS $(BUILDDIR)
	@-$(eval TMP := $(docker inspect --format='{{ .Created }}' $* || true))
	@-rm -f $@ 
	@-touch -d "$(docker inspect --format='{{ .Created }}' $* > /dev/null 2>&1 || echo "now-10years")" $@
else
.PHONY: $(BUILDDIR)/timestamps.d
$(BUILDDIR)/timestamps.d: $(BUILDDIR)
	@$(MAKE) -s DOCKER_TIMESTAMPS=true $(BUILDDIR)/timestamps.d $(TIMESTAMPS)
endif

$(BUILDDIR)/%.d : Dockerfile.% $(DEPS.%)
	@-docker rmi -f --no-prune $* > /dev/null 2>&1 || true   # rmi required as docker build does not update the Created metadata on new build - Docker bug
	docker build $(BUILDARGS.$*:%=--build-arg %) -t $(ORG)$*$(RELEASE) -f $< .
	@touch $@

$(BUILDDIR)/%.d.push: $(BUILDDIR)/%.d
		docker push $(ORG)$*:$(RELEASE) 


push: CACHE = --no-cache
push: clean
push: $(PUSHTARGETS)
		
###############################################
#
# Rule and dependency template for IMAGES
#
################################################
define TEMPLATE_DEP =
 FILES.$(1) = $(shell [ -d FILES.$(1) ] && find FILES.$(1) -type f -print)
 IMAGE.$(1) : $(BUILDDIR)/$(1).d
 $(BUILDDIR)/$(1).d: $$(DEPS.$(1)) $$(FILES.$(1)) $$(PREREQS.$(1)) Dockerfile.$(1)
 $(1): $(BUILDDIR)/$(1).d
endef

$(foreach p,$(IMAGES),$(eval $(call TEMPLATE_DEP,$(p))))

################################################
#
# Cleanup
#
################################################
clean: cleandir
realclean: clean cleandocker
cleandir:
	@-rm -rf $(BUILDDIR)
	@-rm -rf nds-build
cleandocker:
	@-docker rmi -f $(IMAGES)  > /dev/null 2>&1 || true

#
# Omit old fashioed sccs/rcs, etc searching.   Improves performance and noise on debug
#
.SUFFIXES:            # Delete unused old default suffixes
%:: RCS/%,v
%:: RCS/%
%:: s.%
%:: SCCS/s.%
%:: %,v


#
# multiline outputs to build commands
# Note 2 lines in _newline def
# use as:
# define CMDS
# 	echo this
# 	echo that
# 	...
# endef
# foo:
# 	$(call multiline $(CMDS))
#
define _newline


endef
multiline	= '$(subst $(_newline),\n,$1)'


#
# test parts
#
test:
	echo $(TIMESTAMPS)
