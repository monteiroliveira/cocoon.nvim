.PHONY: lint fmt

fmt:
	stylua lua --config-path .stylua.toml

lint:
	luacheck lua --globals vim
