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

# Dynamic test commands
test-config:
	@if [ -z "$(CONFIG)" ]; then \
		echo "Usage: make test-config CONFIG=github.com/releases.yml"; \
		echo "       make test-config CONFIG=github.com"; \
		exit 1; \
	fi
	bundle exec rspec --example "$(CONFIG)" spec/html2rss/configs_dynamic_spec.rb

test-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make test-domain DOMAIN=github.com"; \
		exit 1; \
	fi
	bundle exec rspec --example "$(DOMAIN)" spec/html2rss/configs_dynamic_spec.rb

test-debug:
	@if [ -z "$(CONFIG)" ]; then \
		echo "Usage: make test-debug CONFIG=github.com/releases.yml"; \
		exit 1; \
	fi
	DEBUG_CONFIG=$(CONFIG) bundle exec rspec spec/html2rss/configs_dynamic_spec.rb

# Migration commands
migrate-tests:
	bin/migrate_to_dynamic_tests

restore-tests:
	@if [ -d "spec/html2rss/configs_backup" ]; then \
		cp -r spec/html2rss/configs_backup/* spec/html2rss/configs/; \
		echo "✅ Restored tests from backup"; \
	else \
		echo "❌ No backup found"; \
	fi

lintfix:
	bundle exec rubocop -a
	npx prettier --write lib/**/*.yml .github/**/*.yml README.md
