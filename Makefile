TEMPORARY_FOLDER?=/tmp/IconHUD-Android.dst
PREFIX?=/usr/local

XCODEFLAGS=-project 'IconHUD-Android.xcodeproj' -scheme 'iconhud-android' DSTROOT=$(TEMPORARY_FOLDER)

BINARIES_FOLDER=/usr/local/bin

VERSION_STRING=$(shell git describe --abbrev=0 --tags)

.PHONY: all clean install test uninstall

all:
	xcodebuild $(XCODEFLAGS) build

test: clean
	xcodebuild $(XCODEFLAGS) -configuration Release ENABLE_TESTABILITY=YES test

clean:
	rm -rf "$(TEMPORARY_FOLDER)"
	xcodebuild $(XCODEFLAGS) clean

install: installables
	cp -f "$(TEMPORARY_FOLDER)/usr/local/bin/iconhud-android" "$(BINARIES_FOLDER)"

uninstall:
	rm -f "$(BINARIES_FOLDER)/iconhud-android"

installables: clean
	xcodebuild install $(XCODEFLAGS)

prefix_install: installables
	mkdir -p "$(PREFIX)/bin"
	cp -f "$(TEMPORARY_FOLDER)/usr/local/bin/iconhud-android" "$(PREFIX)/bin/"
