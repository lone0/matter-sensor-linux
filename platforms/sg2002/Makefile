.PHONY: all reader firmware loader

all: reader firmware loader

reader:
	bash -n read-rtc-info.sh probe-rtc-info.sh

firmware:
	$(MAKE) -C 8051

loader:
	$(MAKE) -C 8051 loader
