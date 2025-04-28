
#.phony: up_theme

.phony: update
update:
	@go install -tags extended github.com/gohugoio/hugo@latest

update_theme:
	@git submodule update --init --recursive



.phony: 
run:
	@for i in `ls ./docs`;do if [ "$i" != ads.txt ];then \
	rm -rf ./docs/$i; \
	fi; \
	done; \

	@hugo server -d docs

	@rm -r ./docs

# build:
# 	@for i in `ls ./docs`;do if [ "$i" != ads.txt ];then \
# 	rm -rf ./docs/$i; \
# 	fi; \
# 	done; \
	
# 	@hugo -d docs

# 	@echo -n "google.com, pub-7934154300350596, DIRECT, f08c47fec0942fa0" > ./docs/ads.txt

# 	#@cp ./images/avatar.png ./docs/images/avatar.png
