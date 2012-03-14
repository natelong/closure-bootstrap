goog.require( 'closureBootstrap.templates' );

goog.provide( 'closureBootstrap.main' );

(function(){
	document.body.innerHTML += closureBase.templates.test({ text: 'Looks like your scripts are working!' });
}());