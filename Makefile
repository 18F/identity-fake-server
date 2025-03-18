PORT ?= 5555

run:
	PORT=$(PORT) \
	iex -S mix phx.server

test:
	mix test
