all:
	mkdir -p output
	mkdir -p output/pdfs
	mkdir -p output/graphs
	R CMD BATCH run-all.R
	cp text.html ouput
	cp graphs/accidents-suicides.png output/graphs
	cp graphs/tijuana.png output/graphs
	cp pdfs/tijuana-ma-weekly2.png output/graphs
	cp pdfs/tijuana-daily-select2.png output/graphs
	cp graphs/aco-vs-hom.png output/graphs
	cp graphs/tijuana-diff-necropsia.png output/graphs

clean:
	-rm -rf output/*
	-rm pdfs/*
	-rm graphs/*
