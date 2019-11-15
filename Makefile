install: clean
	rm -rf ~/.cdd
	mkdir -p ~/.cdd
	cp -rf * ~/.cdd/

clean:
	rm -rf templates/rust/target

package: clean
	tar -czvf cdd-latest-x64.tar.gz Makefile openapi.yml bin templates

copy-linux:
	cp ../cdd-ctl/target/debug/cdd bin/linux/
