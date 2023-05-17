.PHONY: .build .clean

build:
	docker run --rm -it -v "${PWD}:/src" --entrypoint bash ruby:2.4 -c "cd /src ; bundle install ; bundle exec rake generate_definitions; gem build fedex-web-services.gemspec"


clean:
	rm -rf lib/fedex_web_services/soap/*
