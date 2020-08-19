# Makefile for letter g-brief2 template.

exit_code = 1

PANDOC = pandoc
PANDOCFLAGS = \
	--standalone \
	--template g-brief2 \
	--pdf-engine xelatex \
	--data-dir ./

PDFTOPPM = pdftoppm

CP = cp
MKDIR = mkdir
OPEN = xdg-open
RM = rm
TAR = tar
ZIP = zip

TARFLAGS = cfvj
ZIPFLAGS = -r -X
# Specify version on command line: `make release VERSION=1.0.0`
DIST = ./dist
TARFILE = $(DIST)/g-brief2-v$(VERSION).tar.bz2
ZIPFILE = $(DIST)/g-brief2-v$(VERSION).zip

SOURCE := ./example
PDF := $(patsubst %.md,%.pdf, \
       $(wildcard $(SOURCE)/*.md))
PNG := $(patsubst %.pdf,%.png, \
	   $(wildcard $(SOURCE)/*.pdf))
TEX := $(patsubst %.md,%.tex, \
	   $(wildcard $(SOURCE)/*.md))

all: $(PDF) $(PNG)
pdf: $(PDF)
png: $(PDF) $(PNG)
tex: $(TEX)
tex: PANDOCFLAGS = \
		--template g-brief2 \
		--data-dir ./

.PHONY: clean open release

# Create pdf from markdown file.
%.pdf: %.md
	$(PANDOC) \
		$(PANDOCFLAGS) \
		--from markdown $< \
		-o $@

# Create png from pdf.
%.png: %.pdf
	$(PDFTOPPM) \
		$< \
		$(basename $@) \
	   -png	\
	   -f 1 \
	   -singlefile \
	   -rx 300 -ry 300

# Create LaTeX file from markdown file.
%.tex: %.md
	$(PANDOC) \
		$(PANDOCFLAGS) \
		--from markdown $< \
		-o $@

open: $(PDF)
	for file in $(PDF); do \
		$(OPEN) $$file; \
	done

clean:
	$(RM) -f $(PDF)
	$(RM) -f $(PNG)
	$(RM) -f $(TEX)

$(DIST):
	$(MKDIR) -p $(DIST)
release: $(PDF) $(PNG) ./example/letter.md g-brief2.latex CHANGELOG.md README.md LICENSE
	if [ ! "$(VERSION)" ]; then \
		echo "\nErr: No version number specified! e. g. \`make VERSION=1.0.0\`!\n"; \
		exit $(exit_code); \
	fi
	exit $(val)
	$(MKDIR) -p $(DIST)
	$(TAR) $(TARFLAGS) $(TARFILE) \
		$^
	$(ZIP) $(ZIPFLAGS) $(ZIPFILE) \
		$^
	# For easily fetching latest release assets.
	$(CP) $(TARFILE) $(DIST)/g-brief2.tar.bz2
	$(CP) $(ZIPFILE) $(DIST)/g-brief2.tar.zip

	echo "\nAfter a file check you may run the following commands:"
	echo "git tag -a v$(VERSION) -m "Release version v$(VERSION)""
	echo "git push  origin v$(VERSION)"
