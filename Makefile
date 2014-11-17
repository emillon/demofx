SRC=start.coffee fire.coffee
SRC_LIT=fpsCounter.litcoffee

.PHONY: watch clean

app.js: $(SRC:coffee=js) $(SRC_LIT:litcoffee=js)
	cat $+ > $@

%.js: %.coffee
	coffee -b -c $<

%.js: %.litcoffee
	coffee -b -c $<

clean:
	rm -f *.js

watch:
	$(MAKE) ; while true ; do inotifywait -qe close_write $(SRC) $(SRC_LIT) ; clear ; $(MAKE) ; done
