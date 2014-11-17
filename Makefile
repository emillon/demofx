SRC=start.coffee
SRC_LIT=app.litcoffee fpsCounter.litcoffee fire.litcoffee starfield.litcoffee

.PHONY: watch clean

gen.js: $(SRC:coffee=js) $(SRC_LIT:litcoffee=js)
	cat $+ > $@

%.js: %.coffee
	coffee -b -c $<

%.js: %.litcoffee
	coffee -b -c $<

clean:
	rm -f *.js

watch:
	$(MAKE) ; while true ; do inotifywait -qe close_write $(SRC) $(SRC_LIT) ; clear ; $(MAKE) ; done
