# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.DEFAULT_GOAL := help
.PHONY: help
help: ## Display this help message.
	echo $(MAKEFILE_LIST);
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

TOP=$(CURDIR)
include $(TOP)/Makefile.conf

.SILENT:

.PHONY: all
all: clean start-server

.PHONY: clean
clean:	 		## Clean log files.
	@echo "Cleaning log files...";
	-@rm $(TOP)/{,.}*{dot,log,svg};
	-@rm -rf $(TOP)/plugins/

.PHONY: start-server
start-server: 	## Start Appliance Manager server
	git clone https://github.com/VeritasOS/plugin-manager.git;
	cd plugin-manager; \
	git checkout v2; \
	make build; \
	ret=$$?; \
	if [ $${ret} -ne 0 ]; then \
		echo "Failed to build Plugin Manager (pm). Return: $${d}."; \
		exit 1; \
	fi ;
	echo "Starting Plugin Manager server...";
	./plugin-manager/bin/pm server -port 8081


.NOTPARALLEL:
