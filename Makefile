index.html: hmlc.pl lincfg.hml
	perl hmlc.pl lincfg.hml >index.html

clean:
	rm -f index.html
