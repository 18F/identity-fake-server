PORT ?= 5555

run:
	PORT=$(PORT) PUMA_MIN_THREADS=8 PUMA_MAX_THREADS=32 PUMA_NUM_WORKERS=3 foreman start

test:
	bundle exec rspec spec/
