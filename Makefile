BUNDLE = BUNDLE_GEMFILE=tool/Gemfile bundle exec
BUNDLE_RUBY = BUNDLE_GEMFILE=tool/Gemfile bundle exec ruby

.PHONY: default check ready lint validate test registry-build test-fetch-changed-configs test-fetch-all-configs test-fetch-botasaurus-configs test-config test-domain lintfix

default: check

check: validate

ready: lint validate test

lint:
	yamllint configs/ .github/
	$(BUNDLE) rubocop -P --cache false -f quiet

validate:
	$(BUNDLE_RUBY) tool/validate

test:
	$(BUNDLE) rspec test

registry-build: validate
	$(BUNDLE_RUBY) tool/registry-build

test-fetch-changed-configs:
	bin/rspec_changed_configs

test-fetch-all-configs:
	$(BUNDLE) rspec --tag fetch test/configs_dynamic_spec.rb

test-fetch-botasaurus-configs:
	bin/rspec_botasaurus_configs

test-config:
	@if [ -z "$(CONFIG)" ]; then \
		echo "Usage: make test-config CONFIG=github.com/releases.yml"; \
		echo "       make test-config CONFIG=github.com"; \
		exit 1; \
	fi
	$(BUNDLE) rspec --example "$(CONFIG)" test/configs_dynamic_spec.rb

test-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make test-domain DOMAIN=github.com"; \
		exit 1; \
	fi
	$(BUNDLE) rspec --example "$(DOMAIN)" test/configs_dynamic_spec.rb

lintfix:
	$(BUNDLE) rubocop -a
