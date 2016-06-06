
books := http://snap.stanford.edu/data/amazon/productGraph/categoryFiles/reviews_Books_5.json.gz
reviews_books_first_1000.json:
	curl $(books) | gunzip | head -n 1000 > $@


#entire set
reviews_Books_5.json.gz: http://snap.stanford.edu/data/amazon/productGraph/categoryFiles/reviews_Books_5.json.gz
	curl $< >$@

