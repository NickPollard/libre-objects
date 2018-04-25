all:
	@pandoc -f markdown -t revealjs slides.md -o index.html --self-contained -V theme=moon
	@echo "Slides written to index.html"
