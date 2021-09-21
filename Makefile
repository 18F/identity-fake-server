PORT ?= 5555

run:
	PORT=$(PORT) foreman start

test:
	bundle exec rspec spec/
