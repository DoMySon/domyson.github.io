
#.phony: up_theme

update:
	@go install -tags extended github.com/gohugoio/hugo@latest



run:
	@for i in `ls ./doc`;do if [ "$i" != ads.txt ];then \
	rm -rf ./doc/$i; \
	fi; \
	done; \
	
	@hugo server -d doc

build:
	@for i in `ls ./docs`;do if [ "$i" != ads.txt ];then \
	rm -rf ./docs/$i; \
	fi; \
	done; \

	@hugo -d docs

