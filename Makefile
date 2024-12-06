# Variables
LATEX = xelatex
LATEX_FLAGS = -synctex=1 -interaction=nonstopmode -file-line-error
DOCFILE = slide.tex

# Default target
all: $(DOCFILE)
	$(LATEX) $(LATEX_FLAGS) $(DOCFILE) > .output;\
	$(LATEX) $(LATEX_FLAGS) $(DOCFILE) >> .output;\
	$(MAKE) clean >> .output

%:
	$(LATEX) $(LATEX_FLAGS) "\def\compileSection{$*} \input{$(DOCFILE)}" > .output;\
	$(LATEX) $(LATEX_FLAGS) "\def\compileSection{$*} \input{$(DOCFILE)}" >> .output;\
	$(MAKE) clean >> .output

# Clean auxiliary files
clean:
	rm -f *.toc *.bbl *.blg *.out *.aux *.log *.bak *.thm *.fdb_latexmk *.fls *.glo *.gls *.idx *.ilg *.ind *.nav *.snm *.hd *.ins *.vrb >> .output

.PHONY: all clean