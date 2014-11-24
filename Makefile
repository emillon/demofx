SRC=start.coffee
SRC_FX=fire.litcoffee starfield.litcoffee cube.litcoffee wormhole.litcoffee delta.litcoffee
SRC_LIT=$(SRC_FX) app.litcoffee fpsCounter.litcoffee

.PHONY: all watch clean doc

all: gen.js doc

gen.js: $(SRC:coffee=js) $(SRC_LIT:litcoffee=js)
	cat $+ > $@

%.js: %.coffee
	coffee -b -c $<

%.js: %.litcoffee
	coffee -b -c $<

clean:
	rm -rf *.js docs

watch:
	$(MAKE) ; while true ; do inotifywait -qe close_write $(SRC) $(SRC_LIT) ; clear ; $(MAKE) ; done

doc:
	docco $(SRC_FX)
