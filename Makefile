default: lint test

lint:
	yamllint lib/html2rss/configs/
	bundle exec rubocop -P -f quiet

test:
	bundle exec rspec

test-fetch-changed-configs:
	bin/rspec_changed_configs

test-fetch-all-configs:
	bundle exec rspec --tag fetch spec/html2rss/configs

test-all: test test-fetch-all-configs

