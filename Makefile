PORT ?= 5555

run:
	bundle exec rackup config.ru --port $(PORT)

test:
	bundle exec rspec spec/
