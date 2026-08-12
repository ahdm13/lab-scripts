SRCROOT = .
DATADIR = ../lab-data

.PHONY: clean
clean:
	find -type f -name '*.jpg' -delete
	find -type f -name '*.png' -delete

%:
	cp $(DATADIR)/%.m $(SRCROOT)
	octave $(SRCROOT)/%.m
