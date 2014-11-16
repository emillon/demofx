SRC=start.coffee fire.coffee

.PHONY: watch clean

app.js: app.coffee
	coffee -b -c $<

app.coffee: $(SRC)
	cat $+ > $@

clean:
	rm -f app.js app.coffee

watch:
	$(MAKE) ; while true ; do inotifywait -qe close_write $(SRC) ; clear ; $(MAKE) ; done
