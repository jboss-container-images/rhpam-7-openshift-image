BUILD_ENGINE := docker
.DEFAULT_GOAL := all
# List of all images
IMAGES=businesscentral businesscentral-monitoring controller dashbuilder kieserver process-migration smartrouter

# Build and test all images
.PHONY: all
# start to build and test the images
all:  _all
_all:
	@for f in $(shell make list-images); do make image image_name=$${f}; done

.PHONY: image
image_name=
image:
# if ignore_build is set to true, ignore the build
ifneq ($(ignore_build),true)
	cekit --descriptor=${image_name}/image.yaml -v --redhat build --overrides-file ${image_name}/branch-overrides.yaml ${BUILD_ENGINE}
endif
# if ignore_test is set to true, ignore the tests
ifneq ($(ignore_test),true)
	cekit --descriptor=${image_name}/image.yaml -v --redhat test --overrides-file ${image_name}/branch-overrides.yaml behave
endif


.PHONY: list-images
list-images:
	@for image in ${IMAGES} ; do echo $$image ; done