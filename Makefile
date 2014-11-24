SRC=start.coffee
SRC_FX=fire.litcoffee starfield.litcoffee cube.litcoffee wormhole.litcoffee delta.litcoffee
SRC_LIT=$(SRC_FX) app.litcoffee fpsCounter.litcoffee

SNAP=index.html gen.js style.css docs

.PHONY: all watch clean doc snapshot

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

snapshot:
	$(MAKE)
	$(eval TMPDIR:=$(shell mktemp -d))
	cp -rfv $(SNAP) $(TMPDIR)/
	git checkout gh-pages
	cp -rfv $(TMPDIR)/* .
	git add $(SNAP)
	git commit -m 'snapshot'
	git checkout master
	rm -rf $(TMPDIR)
