
## gem tasks ##

NAME = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.name")
VERSION = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.version")

PORT = 7007
PID_FILE = tmp/$(NAME).pid

count_lines:
	find lib -name "*.rb" | xargs cat | ruby -e "p STDIN.readlines.count { |l| l = l.strip; l[0, 1] != '#' && l != '' }"
cl: count_lines

gemspec_validate:
	@echo "---"
	ruby -e "s = eval(File.read(Dir['*.gemspec'].first)); s.validate"
	@echo "---"

name: gemspec_validate
	@echo "$(NAME) $(VERSION)"

build: gemspec_validate
	gem build $(NAME).gemspec
	mkdir -p pkg
	mv $(NAME)-$(VERSION).gem pkg/

push: build
	gem push pkg/$(NAME)-$(VERSION).gem


## flor tasks

RUBY=bundle exec ruby
FLOR_ENV?=dev
TO?=nil
FROM?=nil

migrate:
	$(RUBY) -Ilib -e "require 'flor/unit'; Flor::Unit.new('envs/$(FLOR_ENV)/etc/conf.json').storage.migrate($(TO), $(FROM))"


## flack tasks

serve:
	bundle exec rackup -p $(PORT)
s: serve

curl:
	curl -s http://127.0.0.1:$(PORT)/ | \
      $(RUBY) -e "require 'json'; puts JSON.pretty_generate(JSON.load(STDIN.read))"
c: curl

start:
	@if [ ! -f $(PID_FILE) ]; then \
      bundle exec rackup -p $(PORT) -P $(PID_FILE) -D; \
      sleep 1; \
      echo "listening on $(PORT), pid `cat $(PID_FILE)`"; \
    else \
      echo "already running at `cat $(PID_FILE)`"; \
    fi

stop:
	@if [ -f $(PID_FILE) ]; then \
      echo "stopping flack pid `cat $(PID_FILE)`"; \
      kill `cat $(PID_FILE)`; \
    fi

restart:
	@if [ -f $(PID_FILE) ]; then make -s stop; fi; make -s start

