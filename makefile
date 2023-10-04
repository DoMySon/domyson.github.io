
#.phony: up_theme

update:
	@go install -tags extended github.com/gohugoio/hugo@latest



run:
	@for i in `ls ./docs`;do if [ "$i" != .git ];then \
	rm -rf ./docs/$i; \
	fi; \
	done; \

	@hugo -d docs

	@hugo server
