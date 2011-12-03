all: html css compress-js-simple compress-js-advanced
	mkdir -p www
	cp tmp/html/* www
	mkdir -p www/css
	cp tmp/css/* www/css
	mkdir -p www/js
	cp tmp/js/* www/js

clean:
	rm -rf tmp www

# Compress the javascript using advanced optimizations
# optional optimization flags for no legacy IE support
# --define='goog.userAgent.ASSUME_MOBILE_WEBKIT=true' --define='goog.userAgent.jscript.ASSUME_NO_JSCRIPT=true'
compress-js-advanced: js-compiled
	java -jar closure/compiler/compiler.jar --js tmp/js/main.js --js_output_file tmp/js/main.xmin.js --compilation_level ADVANCED_OPTIMIZATIONS

# Compress the js using simple optimizations
compress-js-simple: js-compiled
	java -jar closure/compiler/compiler.jar --js tmp/js/main.js --js_output_file tmp/js/main.min.js --compilation_level SIMPLE_OPTIMIZATIONS

# Run the closure templates compiler on the templates folder
js-templates:
	mkdir -p tmp
	mkdir -p tmp/js
	java -jar closure/templates/SoyToJsSrcCompiler.jar \
		--outputPathFormat tmp/templates/templates.js \
		--shouldProvideRequireSoyNamespaces \
		www-src/templates/*.soy

# Assemble the scripts file by looking at the main JS file and pulling in any necessary dependencies
js-compiled: www-src/js/main.js js-templates
	mkdir -p tmp
	mkdir -p tmp/js
	closure/library/closure/bin/calcdeps.py \
		-i www-src/js/main.js \
		-p closure/library/closure \
		-p closure/templates \
		-p www-src/js \
		-p tmp/templates \
		-o script \
		> tmp/js/main.js

# Compile Closure stylesheets
css: www-src/css/main.gss
	mkdir -p tmp
	mkdir -p tmp/css
	java -jar closure/stylesheets/closure-stylesheets.jar \
		-o tmp/css/main.css \
		www-src/css/*

# Copy HTML files into compiled directory
html:
	mkdir -p tmp
	mkdir -p tmp/html
	cp www-src/html/*.html tmp/html/