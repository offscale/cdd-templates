install:
	mkdir -p ~/.cdd
	mkdir -p ~/.cdd/templates
	cp -rf templates/* ~/.cdd/templates

package:
	tar tar -czvf cdd-0.1-x64.tar.gz .
