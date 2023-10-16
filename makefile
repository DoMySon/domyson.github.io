
#.phony: up_theme

update:
	@go install -tags extended github.com/gohugoio/hugo@latest



run:
	make build
	
	
	@hugo server -d docs

build:
	@for i in `ls ./docs`;do if [ "$i" != ads.txt ];then \
	rm -rf ./docs/$i; \
	fi; \
	done; \

	@hugo -d docs

