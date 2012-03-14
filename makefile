all: html css compress-js-simple compress-js-advanced
	@echo "Copying temp files into www folder"
	@mkdir -p www
	@cp tmp/html/* www
	@mkdir -p www/css
	@cp tmp/css/* www/css
	@mkdir -p www/js
	@cp tmp/js/* www/js

clean:
	@rm -rf tmp www
	@echo "All clean!"

# Compress the javascript using advanced optimizations
# optional optimization flags for no legacy IE support
# --define='goog.userAgent.ASSUME_MOBILE_WEBKIT=true' --define='goog.userAgent.jscript.ASSUME_NO_JSCRIPT=true'
compress-js-advanced: js-compiled
	@echo "Compiling JavaScript with advanced optimizations"
	@java -jar closure/compiler/compiler.jar \
		--warning_level QUIET \
		--js tmp/js/main.js \
		--js_output_file tmp/js/main.xmin.js \
		--compilation_level ADVANCED_OPTIMIZATIONS

#Compress the js using simple optimizations
compress-js-simple: js-compiled
	@echo "Compiling JavaScript with simple optimizations"
	@java -jar closure/compiler/compiler.jar \
		--warning_level QUIET \
		--js tmp/js/main.js \
		--js_output_file tmp/js/main.min.js \
		--compilation_level SIMPLE_OPTIMIZATIONS

# Run the closure templates compiler on the templates folder
js-templates:
	@echo "Compiling JavaScript templates"
	@mkdir -p tmp
	@mkdir -p tmp/js
	@java -jar closure/templates/SoyToJsSrcCompiler.jar \
		--outputPathFormat tmp/templates/templates.js \
		--shouldProvideRequireSoyNamespaces \
		www-src/templates/*.soy

# Assemble the scripts file by looking at the main JS file and pulling in any necessary dependencies
js-compiled: www-src/js/main.js js-templates
	@echo "Combining JavaScript dependencies"
	@mkdir -p tmp
	@mkdir -p tmp/js
	@closure/library/closure/bin/build/closurebuilder.py \
	 	--input=www-src/js/main.js \
		--root=closure/library/closure/ \
		--root=closure/library/third_party/closure/ \
		--root=closure/templates \
		--root=www-src/js \
		--root=tmp/templates \
		--output_mode=script \
		--output_file=tmp/js/main.js

# Compile Closure stylesheets
css: www-src/css/main.gss
	@echo "Compiling GSS to CSS"
	@mkdir -p tmp
	@mkdir -p tmp/css
	@java -jar closure/stylesheets/closure-stylesheets.jar \
		-o tmp/css/main.css \
		www-src/css/*

# Copy HTML files into compiled directory
html:
	@echo "Copying HTML"
	@mkdir -p tmp
	@mkdir -p tmp/html
	@cp www-src/html/*.html tmp/html/