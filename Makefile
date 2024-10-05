# Variables
LATEX = xelatex
LATEX_FLAGS = -synctex=1 -interaction=nonstopmode -file-line-error
DOCFILE = slide.tex

# Default target
all:$(DOCFILE)
	$(LATEX) $(LATEX_FLAGS) $(DOCFILE)
	$(LATEX) $(LATEX_FLAGS) $(DOCFILE)
	$(MAKE) clean

# Clean auxiliary files
clean:
	rm -f *.toc *.bbl *.blg *.out *.aux *.log *.bak *.thm *.synctex.gz *.fdb_latexmk *.fls *.glo *.gls *.idx *.ilg *.ind *.nav *.snm *.hd *.ins *.vrb

.PHONY: all clean