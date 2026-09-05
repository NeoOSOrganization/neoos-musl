# NeoOS musl build

KERNEL_SHIM_DIR ?= ../neoos-kernel/third_party/shim
PREFIX ?= build-output
UPSTREAM_DIR ?= upstream

.PHONY: all clean verify help submodule-init

all: build-output/lib/libc.a

submodule-init:
	@if [ ! -f "$(UPSTREAM_DIR)/.git" ]; then \
		echo "Initializing upstream submodule..."; \
		git submodule update --init upstream; \
	fi

build-output/lib/libc.a: submodule-init
	@[ -d "$(KERNEL_SHIM_DIR)" ] || { \
		echo "Error: Kernel shim not found at $(KERNEL_SHIM_DIR)"; \
		exit 1; \
	}
	@./build.sh

clean:
	rm -rf $(PREFIX)

verify:
	@if [ -f "$(PREFIX)/lib/libc.a" ]; then \
		echo "OK libc.a built"; \
	else \
		echo "ERROR libc.a not found"; \
		exit 1; \
	fi

help:
	@echo "NeoOS musl build"
	@echo "Usage: make [KERNEL_SHIM_DIR=path]"
