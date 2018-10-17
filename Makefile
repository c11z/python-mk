.PHONY: test clean

test: dummy
	cp python.mk dummy/python.mk
	cd dummy && $(MAKE) -f python.mk install

clean:
	rm -r dummy

dummy:
	mkdir -p $@
