SRCROOT = .
DATADIR = ../lab-data

.PHONY:
all:
	@echo "usage: make <lab>/<expN>" >&2
	@false

.PHONY: clean
clean:
	find -type f -name '*.jpg' -delete
	find -type f -name '*.png' -delete

%:
	cp $(DATADIR)/$@.m $(SRCROOT)/data.m
	octave $(SRCROOT)/$@.m
