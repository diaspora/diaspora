document.createElement('header');
document.createElement('footer');

// IE 9 work-around for vendor/backbone.js
if ((window.history) && (document.documentMode == 9)) {
	window.history.pushState = function() { };
}
