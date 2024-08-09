default: lint test

lint:
	yamllint lib/html2rss/configs/ .github/
	bundle exec rubocop -P -f quiet
	npx prettier --check lib/**/*.yml .github/**/*.yml  README.md

test:
	bundle exec rspec

test-fetch-changed-configs:
	bin/rspec_changed_configs

test-fetch-all-configs:
	bundle exec rspec --tag fetch spec/html2rss/configs

test-all: test test-fetch-all-configs

lintfix:
	bundle exec rubocop -a
	npx prettier --write lib/**/*.yml .github/**/*.yml README.md
