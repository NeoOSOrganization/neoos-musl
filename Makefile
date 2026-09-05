# NeoOS musl build
# Full implementation in Phase 4 (musl migration)

KERNEL_SHIM_DIR ?= ../neoos-kernel/third_party/shim
PREFIX ?= build-output
UPSTREAM_DIR ?= upstream

.PHONY: all clean

all:
	@echo "musl build: placeholder (implementation in Phase 4)"
	@echo "When complete, will:"
	@echo "  1. Integrate shim from $(KERNEL_SHIM_DIR)"
	@echo "  2. Build musl at $(UPSTREAM_DIR)"
	@echo "  3. Install to $(PREFIX)"

clean:
	rm -rf $(PREFIX)
