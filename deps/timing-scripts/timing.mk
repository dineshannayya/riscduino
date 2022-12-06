OPENLANE_TAG ?=  2022.02.23_02.50.41
OPENLANE_IMAGE_NAME ?=  efabless/openlane:$(OPENLANE_TAG)
export PDK ?= sky130A
export RCX_CORNER ?= nom
export LIB_CORNER ?= t
export ALLOW_MISSING_SPEF ?= 1
export PDK_REF_PATH = $(PDK_ROOT)/$(PDK)/libs.ref/
export PDK_TECH_PATH = $(PDK_ROOT)/$(PDK)/libs.tech/
export PROJECT_ROOT ?= $(CARAVEL_ROOT)

logs-dir = $(PROJECT_ROOT)/logs
logs = $(logs-dir)/rcx $(logs-dir)/sdf $(logs-dir)/top $(logs-dir)/sta
$(logs):
	mkdir -p $@

SPEF_OVERWRITE ?= ""
define docker_run_base
	docker run \
		--rm \
		-e PROJECT_ROOT=$(PROJECT_ROOT) \
		-e BLOCK=$1 \
		-e PDK=$(PDK) \
		-e LIB_CORNER=$(LIB_CORNER) \
		-e RCX_CORNER=$(RCX_CORNER) \
		-e MCW_ROOT=$(MCW_ROOT) \
		-e SPEF_OVERWRITE=$(SPEF_OVERWRITE) \
		-e CUP_ROOT=$(CUP_ROOT) \
		-e CARAVEL_ROOT=$(CARAVEL_ROOT) \
		-e TIMING_ROOT=$(TIMING_ROOT) \
		-e PDK_REF_PATH=$(PDK_ROOT)/$(PDK)/libs.ref/ \
		-e PDK_TECH_PATH=$(PDK_ROOT)/$(PDK)/libs.tech/ \
		-e ALLOW_MISSING_SPEF=$(ALLOW_MISSING_SPEF) \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(CUP_ROOT):$(CUP_ROOT) \
		-v $(MCW_ROOT):$(MCW_ROOT) \
		-v $(TIMING_ROOT):$(TIMING_ROOT) \
		-v $(CARAVEL_ROOT):$(CARAVEL_ROOT) \
		-v $(HOME):$(HOME) \
		-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
		$(OPENLANE_IMAGE_NAME)
endef


define docker_run_sta
	$(call docker_run_base,$1) \
		bash -c "set -eo pipefail && sta -exit $(TIMING_ROOT)/scripts/openroad/sta-$*.tcl \
			|& tee $(logs-dir)/sta/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
	@echo "logged to $(logs-dir)/sta/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
endef

define docker_run_sdf
	$(call docker_run_base,$1) \
		bash -c "set -eo pipefail && openroad -exit $(TIMING_ROOT)/scripts/openroad/sdf.tcl \
			|& tee $(logs-dir)/sdf/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
	@echo "logged to $(logs-dir)/sdf/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
endef

define docker_run_rcx
	$(call docker_run_base,$1) \
		bash -c "set -eo pipefail && openroad -exit $(TIMING_ROOT)/scripts/openroad/rcx.tcl \
			|& tee $(logs-dir)/rcx/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
	@echo "logged to $(logs-dir)/rcx/$*-$(RCX_CORNER)-$(LIB_CORNER).log"
endef

blocks  = $(shell cd $(CARAVEL_ROOT)/openlane && find * -maxdepth 0 -type d)
blocks := $(subst user_project_wrapper,,$(blocks))
ifneq ($(CARAVEL_ROOT),$(MCW_ROOT))
blocks += $(shell cd $(MCW_ROOT)/openlane && find * -maxdepth 0 -type d)
endif
ifneq ($(CARAVEL_ROOT),$(CUP_ROOT))
blocks += $(shell cd $(CUP_ROOT)/openlane && find * -maxdepth 0 -type d)
endif

# we don't have user_id_programming.def)
# mgmt_protect_hvl use hvl library which we don't handle yet
blocks := $(subst mgmt_protect_hvl,,$(blocks))
blocks := $(subst chip_io_alt,,$(blocks))
blocks := $(subst user_id_programming,,$(blocks))
blocks := $(subst user_analog_project_wrapper,,$(blocks))
blocks := $(subst caravan,,$(blocks))

defs  = $(shell cd $(CARAVEL_ROOT)/def && find *.def -maxdepth 0 -type f ! -name 'user_project_wrapper.def') 
ifneq ($(CARAVEL_ROOT),$(MCW_ROOT))
defs += $(shell cd $(MCW_ROOT)/def && find *.def -maxdepth 0 -type f)
endif
ifneq ($(CARAVEL_ROOT),$(CUP_ROOT))
defs += $(shell cd $(CUP_ROOT)/def && find *.def -maxdepth 0 -type f)
endif

rcx-blocks     = $(defs:%.def=rcx-%)
rcx-blocks-nom = $(blocks:%=rcx-%-nom)
rcx-blocks-max = $(blocks:%=rcx-%-max)
rcx-blocks-min = $(blocks:%=rcx-%-min)
rcx-blocks-t = $(blocks:%=rcx-%-t)
rcx-blocks-f = $(blocks:%=rcx-%-f)
rcx-blocks-s = $(blocks:%=rcx-%-s)

sdf-blocks = $(blocks:%=sdf-%)
sdf-blocks-t = $(blocks:%=sdf-%-t)
sdf-blocks-f = $(blocks:%=sdf-%-f)
sdf-blocks-s = $(blocks:%=sdf-%-s)
sdf-blocks-nom = $(blocks:%=sdf-%-nom)
sdf-blocks-min = $(blocks:%=sdf-%-min)
sdf-blocks-max = $(blocks:%=sdf-%-max)

$(sdf-blocks): sdf-%: 
	$(MAKE) -f timing.mk sdf-$*-nom
	$(MAKE) -f timing.mk sdf-$*-min
	$(MAKE) -f timing.mk sdf-$*-max

$(sdf-blocks-nom): export RCX_CORNER = nom
$(sdf-blocks-min): export RCX_CORNER = min
$(sdf-blocks-max): export RCX_CORNER = max
$(sdf-blocks-nom): sdf-%-nom: sdf-%-t sdf-%-f sdf-%-s
$(sdf-blocks-min): sdf-%-min: sdf-%-t sdf-%-f sdf-%-s
$(sdf-blocks-max): sdf-%-max: sdf-%-t sdf-%-f sdf-%-s

$(sdf-blocks-t): export LIB_CORNER = t
$(sdf-blocks-s): export LIB_CORNER = s
$(sdf-blocks-f): export LIB_CORNER = f
$(sdf-blocks-t): sdf-%-t:
	$(call docker_run_sdf,$*)
$(sdf-blocks-s): sdf-%-s:
	$(call docker_run_sdf,$*)
$(sdf-blocks-f): sdf-%-f:
	$(call docker_run_sdf,$*)


sta-blocks = $(blocks:%=sta-%)
sta-blocks-t = $(blocks:%=sta-%-t)
sta-blocks-f = $(blocks:%=sta-%-f)
sta-blocks-s = $(blocks:%=sta-%-s)
sta-blocks-nom = $(blocks:%=sta-%-nom)
sta-blocks-min = $(blocks:%=sta-%-min)
sta-blocks-max = $(blocks:%=sta-%-max)

$(sta-blocks): sta-%:
	$(MAKE) -f timing.mk sta-$*-nom
	$(MAKE) -f timing.mk sta-$*-min
	$(MAKE) -f timing.mk sta-$*-max

$(sta-blocks-nom): export RCX_CORNER = nom
$(sta-blocks-min): export RCX_CORNER = min
$(sta-blocks-max): export RCX_CORNER = max
$(sta-blocks-nom): sta-%-nom: sta-%-t sta-%-f sta-%-s
$(sta-blocks-min): sta-%-min: sta-%-t sta-%-f sta-%-s
$(sta-blocks-max): sta-%-max: sta-%-t sta-%-f sta-%-s

$(sta-blocks-t): export LIB_CORNER = t
$(sta-blocks-s): export LIB_CORNER = s
$(sta-blocks-f): export LIB_CORNER = f
$(sta-blocks-t): sta-%-t: $(logs-dir)/sta
	$(call docker_run_sta,$*)
$(sta-blocks-s): sta-%-s:
	$(call docker_run_sta,$*)
$(sta-blocks-f): sta-%-f:
	$(call docker_run_sta,$*)


$(rcx-blocks): rcx-%: $(rcx-requirements)
	$(MAKE) -f timing.mk rcx-$*-nom &
	$(MAKE) -f timing.mk rcx-$*-min &
	$(MAKE) -f timing.mk rcx-$*-max

$(rcx-blocks-nom): export RCX_CORNER = nom
$(rcx-blocks-min): export RCX_CORNER = min
$(rcx-blocks-max): export RCX_CORNER = max
$(rcx-blocks-nom): rcx-%-nom: rcx-%-t
$(rcx-blocks-min): rcx-%-min: rcx-%-t
$(rcx-blocks-max): rcx-%-max: rcx-%-t

$(rcx-blocks-t): export LIB_CORNER = t
$(rcx-blocks-s): export LIB_CORNER = s
$(rcx-blocks-f): export LIB_CORNER = f
$(rcx-blocks-t): rcx-%-t: $(logs-dir)/rcx
	$(call docker_run_rcx,$*)
$(rcx-blocks-s): rcx-%-s:
	$(call docker_run_rcx,$*)
$(rcx-blocks-f): rcx-%-f:
	$(call docker_run_rcx,$*)


define docker_run_caravel_timing
	$(call docker_run_base,caravel) \
		bash -c "set -eo pipefail && sta -no_splash -exit $(TIMING_ROOT)/scripts/openroad/timing_top.tcl |& tee \
			$(logs-dir)/top/caravel-timing-$$(basename $(LIB_CORNER))-$(RCX_CORNER).log"
	@echo "logged to $(logs-dir)/top/caravel-timing-$$(basename $(LIB_CORNER))-$(RCX_CORNER).log"
endef


caravel-timing-typ-targets  = caravel-timing-typ-nom
caravel-timing-typ-targets += caravel-timing-typ-min
caravel-timing-typ-targets += caravel-timing-typ-max

caravel-timing-slow-targets  = caravel-timing-slow-nom
caravel-timing-slow-targets += caravel-timing-slow-min
caravel-timing-slow-targets += caravel-timing-slow-max

caravel-timing-fast-targets  = caravel-timing-fast-nom
caravel-timing-fast-targets += caravel-timing-fast-min
caravel-timing-fast-targets += caravel-timing-fast-max

caravel-timing-targets  = $(caravel-timing-slow-targets)
caravel-timing-targets += $(caravel-timing-fast-targets)
caravel-timing-targets += $(caravel-timing-typ-targets)

.PHONY: caravel-timing-typ
$(caravel-timing-typ-targets): export LIB_CORNER = t
caravel-timing-typ: caravel-timing-typ-nom caravel-timing-typ-min caravel-timing-typ-max

.PHONY: caravel-timing-typ-nom
.PHONY: caravel-timing-typ-min
.PHONY: caravel-timing-typ-max
caravel-timing-typ-nom: export RCX_CORNER = nom
caravel-timing-typ-min: export RCX_CORNER = min
caravel-timing-typ-max: export RCX_CORNER = max

.PHONY: caravel-timing-slow
$(caravel-timing-slow-targets): export LIB_CORNER = s
caravel-timing-slow: caravel-timing-slow-nom caravel-timing-slow-min caravel-timing-slow-max

.PHONY: caravel-timing-slow-nom
.PHONY: caravel-timing-slow-min
.PHONY: caravel-timing-slow-max
caravel-timing-slow-nom: export RCX_CORNER = nom
caravel-timing-slow-min: export RCX_CORNER = min
caravel-timing-slow-max: export RCX_CORNER = max

.PHONY: caravel-timing-fast
$(caravel-timing-fast-targets): export LIB_CORNER = f
caravel-timing-fast: caravel-timing-fast-nom caravel-timing-fast-min caravel-timing-fast-max

.PHONY: caravel-timing-fast-nom
.PHONY: caravel-timing-fast-min
.PHONY: caravel-timing-fast-max
caravel-timing-fast-nom: export RCX_CORNER = nom
caravel-timing-fast-min: export RCX_CORNER = min
caravel-timing-fast-max: export RCX_CORNER = max

$(caravel-timing-targets): $(logs-dir)/top
	$(call docker_run_caravel_timing)


# some useful dev double checking
#
rcx-requirements  = $(CARAVEL_ROOT)/def/%.def
rcx-requirements += $(CARAVEL_ROOT)/lef/%.lef
rcx-requirements += $(CARAVEL_ROOT)/sdc/%.sdc
rcx-requirements += $(CARAVEL_ROOT)/verilog/gl/%.v

exceptions  = $(MCW_ROOT)/lef/caravel.lef
exceptions += $(MCW_ROOT)/lef/caravan.lef
# lets ignore these for now
exceptions += $(MCW_ROOT)/sdc/user_analog_project_wrapper.sdc
exceptions += $(MCW_ROOT)/sdc/user_project_wrapper.sdc
exceptions += $(MCW_ROOT)/verilog/gl/user_analog_project_wrapper.v
exceptions += $(MCW_ROOT)/verilog/gl/user_project_wrapper.v

.PHONY: list-rcx
.PHONY: list-sdf
.PHONY: rcx-all
list-rcx:
	@blocks="$(rcx-blocks)";\
		for block in $${blocks}; do echo "$$block"; done
list-sdf:
	@echo $(sdf-blocks)
list-sta:
	@echo $(sta-blocks)
rcx-all: $(rcx-blocks)

$(exceptions):
	$(warning we don't need lefs for $@ but take note anyway)

$(CARAVEL_ROOT)/def/%.def: $(MCW_ROOT)/def/%.def ;
$(MCW_ROOT)/def/%.def: $(CUP_ROOT)/def/%.def ;
$(CUP_ROOT)/def/%.def:
	$(error error if you are here it probably means that $@.def is mising from mcw and caravel)

$(CARAVEL_ROOT)/lef/%.lef: $(MCW_ROOT)/lef/%.lef ;
$(MCW_ROOT)/lef/%.lef: $(CUP_ROOT)/lef/%.lef ;
$(CUP_ROOT)/lef/%.lef:
	$(error error if you are here it probably means that $@.lef is mising from mcw and caravel)

$(CARAVEL_ROOT)/sdc/%.sdc: $(MCW_ROOT)/sdc/%.sdc ;
$(MCW_ROOT)/sdc/%.sdc: $(CUP_ROOT)/sdc/%.sdc ;
$(CUP_ROOT)/sdc/%.sdc:
	$(error error if you are here it probably means that $@.sdc is mising from mcw and caravel)

$(CARAVEL_ROOT)/verilog/gl/%.v: $(MCW_ROOT)/verilog/gl/%.v ;
$(MCW_ROOT)/verilog/gl/%.v: $(CUP_ROOT)/verilog/gl/%.v ;
$(CUP_ROOT)/verilog/gl/%.v:
	$(error error if you are here it probably means that gl/$@.v is mising from mcw and caravel)

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

$(call check_defined, \
	MCW_ROOT \
	CUP_ROOT \
	PDK_ROOT \
	CARAVEL_ROOT \
	TIMING_ROOT \
)
