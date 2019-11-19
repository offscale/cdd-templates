install: clean
	rm -rf ~/.cdd
	mkdir -p ~/.cdd
	mkdir -p ~/.cdd/templates
	cp -r ./templates/* ~/.cdd/templates/
	cp openapi.yml ~/.cdd/openapi.yml

clean:
	rm -rf templates/rust/target

package: clean
	rm -rf bin
	mkdir -p bin
	cd ../cdd-ctl && make install
	cd ../cdd-rust && make install
	tar -czvf cdd-latest-x64.tar.gz Makefile openapi.yml bin templates

copy-linux:
	cp ../cdd-ctl/target/debug/cdd bin/cdd