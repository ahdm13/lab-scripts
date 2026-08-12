SRCROOT = .
DATADIR = ../lab-data

.PHONY:
all:
	@echo "usage: make <lab>/<expN>" >&2
	@false

.PHONY: clean
clean:
	rm -f data.m *.jpg *.png

%:
	cp $(DATADIR)/$@.m $(SRCROOT)/data.m
	octave $(SRCROOT)/$@.m
