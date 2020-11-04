default: lint test

lint:
	yamllint lib/html2rss/configs/
	bundle exec rubocop -P -f quiet
	yarn exec prettier -- --check lib/**/*.yml

test:
	bundle exec rspec

test-fetch-changed-configs:
	bin/rspec_changed_configs

test-fetch-all-configs:
	bundle exec rspec --tag fetch spec/html2rss/configs

test-all: test test-fetch-all-configs

lintfix:
	bundle exec rubocop -a
	yarn exec prettier -- --write lib/**/*.yml

config:
	@if [ -z "$(domain)" ] || [ -z "$(name)" ]; \
	then \
		echo "Usage: make config domain=domain.tld name=latest"; \
	else \
		git stash; \
		git checkout master && \
		git pull && \
		git stash pop; \
		git checkout -b "feat/add-$(domain)-$(name)" && \
		mkdir -p "lib/html2rss/configs/$(domain)/" && \
		mkdir -p "spec/html2rss/configs/$(domain)/" && \
		bin/template_gen_config_spec "$(domain)/$(name).yml" > "spec/html2rss/configs/$(domain)/$(name).yml_spec.rb" && \
		bin/template_gen_config "$(domain)" "$(name)" > "lib/html2rss/configs/$(domain)/$(name).yml"; \
	fi;
