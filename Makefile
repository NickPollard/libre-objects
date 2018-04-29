all:
	@pandoc -f markdown -t revealjs slides.md -o index.html --self-contained -V theme=typologist -V transition=fade --highlight-style=typologist.theme
	@echo "Slides written to index.html"
