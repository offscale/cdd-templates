install:
	mkdir -p ~/.cdd
	cp -rf * ~/.cdd/

package:
	tar tar -czvf cdd-latest-x64.tar.gz .
