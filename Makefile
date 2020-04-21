.PHONY: test clean

default: test

test: dummy
	cp python.mk dummy/python.mk
	cd dummy && $(MAKE) -f python.mk install

dummy:
	mkdir -p $@

clean:
	rm -r dummy
