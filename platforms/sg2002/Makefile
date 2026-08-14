.PHONY: all reader firmware loader

all: reader firmware loader

reader:
	bash -n deploy-sg2002-platform-over-ssh.sh install-dependencies.sh read-rtc-info.sh probe-rtc-info.sh test-sht31-hardware.sh check-sht31-readings.sh 8051/prepare-i2c3.sh

firmware:
	$(MAKE) -C 8051

loader:
	$(MAKE) -C 8051 loader
