SRC=start.coffee fire.coffee

.PHONY: watch clean

app.js: $(SRC:coffee=js)
	cat $+ > $@

%.js: %.coffee
	coffee -b -c $<

clean:
	rm -f *.js

watch:
	$(MAKE) ; while true ; do inotifywait -qe close_write $(SRC) ; clear ; $(MAKE) ; done
