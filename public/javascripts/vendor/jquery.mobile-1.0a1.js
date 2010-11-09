/*!
 * jQuery Mobile
 * http://jquerymobile.com/
 *
 * Copyright 2010, jQuery Project
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 */
/*!
 * jQuery UI Widget @VERSION
 *
 * Copyright 2010, AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * http://docs.jquery.com/UI/Widget
 */
(function( $, undefined ) {

// jQuery 1.4+
if ( $.cleanData ) {
	var _cleanData = $.cleanData;
	$.cleanData = function( elems ) {
		for ( var i = 0, elem; (elem = elems[i]) != null; i++ ) {
			$( elem ).triggerHandler( "remove" );
		}
		_cleanData( elems );
	};
} else {
	var _remove = $.fn.remove;
	$.fn.remove = function( selector, keepData ) {
		return this.each(function() {
			if ( !keepData ) {
				if ( !selector || $.filter( selector, [ this ] ).length ) {
					$( "*", this ).add( [ this ] ).each(function() {
						$( this ).triggerHandler( "remove" );
					});
				}
			}
			return _remove.call( $(this), selector, keepData );
		});
	};
}

$.widget = function( name, base, prototype ) {
	var namespace = name.split( "." )[ 0 ],
		fullName;
	name = name.split( "." )[ 1 ];
	fullName = namespace + "-" + name;

	if ( !prototype ) {
		prototype = base;
		base = $.Widget;
	}

	// create selector for plugin
	$.expr[ ":" ][ fullName ] = function( elem ) {
		return !!$.data( elem, name );
	};

	$[ namespace ] = $[ namespace ] || {};
	$[ namespace ][ name ] = function( options, element ) {
		// allow instantiation without initializing for simple inheritance
		if ( arguments.length ) {
			this._createWidget( options, element );
		}
	};

	var basePrototype = new base();
	// we need to make the options hash a property directly on the new instance
	// otherwise we'll modify the options hash on the prototype that we're
	// inheriting from
//	$.each( basePrototype, function( key, val ) {
//		if ( $.isPlainObject(val) ) {
//			basePrototype[ key ] = $.extend( {}, val );
//		}
//	});
	basePrototype.options = $.extend( true, {}, basePrototype.options );
	$[ namespace ][ name ].prototype = $.extend( true, basePrototype, {
		namespace: namespace,
		widgetName: name,
		widgetEventPrefix: $[ namespace ][ name ].prototype.widgetEventPrefix || name,
		widgetBaseClass: fullName
	}, prototype );

	$.widget.bridge( name, $[ namespace ][ name ] );
};

$.widget.bridge = function( name, object ) {
	$.fn[ name ] = function( options ) {
		var isMethodCall = typeof options === "string",
			args = Array.prototype.slice.call( arguments, 1 ),
			returnValue = this;

		// allow multiple hashes to be passed on init
		options = !isMethodCall && args.length ?
			$.extend.apply( null, [ true, options ].concat(args) ) :
			options;

		// prevent calls to internal methods
		if ( isMethodCall && options.charAt( 0 ) === "_" ) {
			return returnValue;
		}

		if ( isMethodCall ) {
			this.each(function() {
				var instance = $.data( this, name );
				if ( !instance ) {
					throw "cannot call methods on " + name + " prior to initialization; " +
						"attempted to call method '" + options + "'";
				}
				if ( !$.isFunction( instance[options] ) ) {
					throw "no such method '" + options + "' for " + name + " widget instance";
				}
				var methodValue = instance[ options ].apply( instance, args );
				if ( methodValue !== instance && methodValue !== undefined ) {
					returnValue = methodValue;
					return false;
				}
			});
		} else {
			this.each(function() {
				var instance = $.data( this, name );
				if ( instance ) {
					instance.option( options || {} )._init();
				} else {
					$.data( this, name, new object( options, this ) );
				}
			});
		}

		return returnValue;
	};
};

$.Widget = function( options, element ) {
	// allow instantiation without initializing for simple inheritance
	if ( arguments.length ) {
		this._createWidget( options, element );
	}
};

$.Widget.prototype = {
	widgetName: "widget",
	widgetEventPrefix: "",
	options: {
		disabled: false
	},
	_createWidget: function( options, element ) {
		// $.widget.bridge stores the plugin instance, but we do it anyway
		// so that it's stored even before the _create function runs
		$.data( element, this.widgetName, this );
		this.element = $( element );
		this.options = $.extend( true, {},
			this.options,
			this._getCreateOptions(),
			options );

		var self = this;
		this.element.bind( "remove." + this.widgetName, function() {
			self.destroy();
		});

		this._create();
		this._trigger( "create" );
		this._init();
	},
	_getCreateOptions: function() {
		var options = {};
		if ( $.metadata ) {
			options = $.metadata.get( element )[ this.widgetName ];
		}
		return options;
	},
	_create: function() {},
	_init: function() {},

	destroy: function() {
		this.element
			.unbind( "." + this.widgetName )
			.removeData( this.widgetName );
		this.widget()
			.unbind( "." + this.widgetName )
			.removeAttr( "aria-disabled" )
			.removeClass(
				this.widgetBaseClass + "-disabled " +
				"ui-state-disabled" );
	},

	widget: function() {
		return this.element;
	},

	option: function( key, value ) {
		var options = key;

		if ( arguments.length === 0 ) {
			// don't return a reference to the internal hash
			return $.extend( {}, this.options );
		}

		if  (typeof key === "string" ) {
			if ( value === undefined ) {
				return this.options[ key ];
			}
			options = {};
			options[ key ] = value;
		}

		this._setOptions( options );

		return this;
	},
	_setOptions: function( options ) {
		var self = this;
		$.each( options, function( key, value ) {
			self._setOption( key, value );
		});

		return this;
	},
	_setOption: function( key, value ) {
		this.options[ key ] = value;

		if ( key === "disabled" ) {
			this.widget()
				[ value ? "addClass" : "removeClass"](
					this.widgetBaseClass + "-disabled" + " " +
					"ui-state-disabled" )
				.attr( "aria-disabled", value );
		}

		return this;
	},

	enable: function() {
		return this._setOption( "disabled", false );
	},
	disable: function() {
		return this._setOption( "disabled", true );
	},

	_trigger: function( type, event, data ) {
		var callback = this.options[ type ];

		event = $.Event( event );
		event.type = ( type === this.widgetEventPrefix ?
			type :
			this.widgetEventPrefix + type ).toLowerCase();
		data = data || {};

		// copy original event properties over to the new event
		// this would happen if we could call $.event.fix instead of $.Event
		// but we don't have a way to force an event to be fixed multiple times
		if ( event.originalEvent ) {
			for ( var i = $.event.props.length, prop; i; ) {
				prop = $.event.props[ --i ];
				event[ prop ] = event.originalEvent[ prop ];
			}
		}

		this.element.trigger( event, data );

		return !( $.isFunction(callback) &&
			callback.call( this.element[0], event, data ) === false ||
			event.isDefaultPrevented() );
	}
};

})( jQuery );
(function( $ ) {

$.widget( "mobile.widget", {
	_getCreateOptions: function() {
		var elem = this.element,
			options = {};
		$.each( this.options, function( option ) {
			var value = elem.data( option.replace( /[A-Z]/g, function( c ) {
				return "-" + c.toLowerCase();
			} ) );
			if ( value !== undefined ) {
				options[ option ] = value;
			}
		});
		return options;
	}
});

})( jQuery );
/*
Possible additions:
	scollTop
	CSS Matrix
*/

// test whether a CSS media type or query applies
$.media = (function() {
	// TODO: use window.matchMedia once at least one UA implements it
	var cache = {},
		$html = $( "html" ),
		testDiv = $( "<div id='jquery-mediatest'>" ),
		fakeBody = $( "<body>" ).append( testDiv );
	
	return function( query ) {
		if ( !( query in cache ) ) {
			var styleBlock = $( "<style type='text/css'>" +
				"@media " + query + "{#jquery-mediatest{position:absolute;}}" +
				"</style>" );
			$html.prepend( fakeBody ).prepend( styleBlock );
			cache[ query ] = testDiv.css( "position" ) === "absolute";
			fakeBody.add( styleBlock ).remove();
		}
		return cache[ query ];
	};
})();

var fakeBody = $( "<body>" ).prependTo( "html" ),
	fbCSS = fakeBody[0].style,
	vendors = ['webkit','moz','o'],
	webos = window.palmGetResource || window.PalmServiceBridge, //only used to rule out scrollTop 
	bb = window.blackberry; //only used to rule out box shadow, as it's filled opaque on BB

//thx Modernizr
function propExists( prop ){
	var uc_prop = prop.charAt(0).toUpperCase() + prop.substr(1),
		props   = (prop + ' ' + vendors.join(uc_prop + ' ') + uc_prop).split(' ');
	for(var v in props){
		if( fbCSS[ v ] !== undefined ){
			return true;
		}
	}
};

$.extend( $.support, {
	orientation: "orientation" in window,
	touch: "ontouchend" in document,
	WebKitAnimationEvent: typeof WebKitTransitionEvent === "object",
	pushState: !!history.pushState,
	mediaquery: $.media('only all'),
	cssPseudoElement: !!propExists('content'),
	boxShadow: !!propExists('boxShadow') && !bb,
	scrollTop: ("pageXOffset" in window || "scrollTop" in document.documentElement || "scrollTop" in fakeBody[0]) && !webos
});

fakeBody.remove();

//for ruling out shadows via css
if( !$.support.boxShadow ){ $('html').addClass('ui-mobile-nosupport-boxshadow'); }// add new event shortcuts
$.each( "touchstart touchmove touchend orientationchange tap taphold swipe swipeleft swiperight scrollstart scrollstop".split( " " ), function( i, name ) {
	$.fn[ name ] = function( fn ) {
		return fn ? this.bind( name, fn ) : this.trigger( name );
	};
	$.attrFn[ name ] = true;
});

var supportTouch = $.support.touch,
	scrollEvent = "touchmove scroll",
	touchStartEvent = supportTouch ? "touchstart" : "mousedown",
	touchStopEvent = supportTouch ? "touchend" : "mouseup",
	touchMoveEvent = supportTouch ? "touchmove" : "mousemove";

// also handles scrollstop
$.event.special.scrollstart = {
	enabled: true,
	
	setup: function() {
		var thisObject = this,
			$this = $( thisObject ),
			scrolling,
			timer;
		
		function trigger( event, state ) {
			scrolling = state;
			var originalType = event.type;
			event.type = scrolling ? "scrollstart" : "scrollstop";
			$.event.handle.call( thisObject, event );
			event.type = originalType;
		}
		
		// iPhone triggers scroll after a small delay; use touchmove instead
		$this.bind( scrollEvent, function( event ) {
			if ( !$.event.special.scrollstart.enabled ) {
				return;
			}
			
			if ( !scrolling ) {
				trigger( event, true );
			}
			
			clearTimeout( timer );
			timer = setTimeout(function() {
				trigger( event, false );
			}, 50 );
		});
	}
};

// also handles taphold
$.event.special.tap = {
	setup: function() {
		var thisObject = this,
			$this = $( thisObject );
		
		$this
			.bind( touchStartEvent, function( event ) {
				if ( event.which && event.which !== 1 ) {
					return;
				}
				
				var moved = false,
					touching = true,
					originalType,
					timer;
				
				function moveHandler() {
					moved = true;
				}
				
				timer = setTimeout(function() {
					if ( touching && !moved ) {
						originalType = event.type;
						event.type = "taphold";
						$.event.handle.call( thisObject, event );
						event.type = originalType;
					}
				}, 750 );
				
				$this
					.one( touchMoveEvent, moveHandler)
					.one( touchStopEvent, function( event ) {
						$this.unbind( touchMoveEvent, moveHandler );
						clearTimeout( timer );
						touching = false;
						
						if ( !moved ) {
							originalType = event.type;
							event.type = "tap";
							$.event.handle.call( thisObject, event );
							event.type = originalType;
						}
					});
			});
	}
};

// also handles swipeleft, swiperight
$.event.special.swipe = {
	setup: function() {
		var thisObject = this,
			$this = $( thisObject );
		
		$this
			.bind( touchStartEvent, function( event ) {
				var data = event.originalEvent.touches ?
						event.originalEvent.touches[ 0 ] :
						event,
					start = {
						time: (new Date).getTime(),
						coords: [ data.pageX, data.pageY ],
						origin: $( event.target )
					},
					stop;
				
				function moveHandler( event ) {
					if ( !start ) {
						return;
					}
					
					var data = event.originalEvent.touches ?
							event.originalEvent.touches[ 0 ] :
							event;
					stop = {
							time: (new Date).getTime(),
							coords: [ data.pageX, data.pageY ]
					};
					
					// prevent scrolling
					if ( Math.abs( start.coords[0] - stop.coords[0] ) > 10 ) {
						event.preventDefault();
					}
				}
				
				$this
					.bind( touchMoveEvent, moveHandler )
					.one( touchStopEvent, function( event ) {
						$this.unbind( touchMoveEvent, moveHandler );
						if ( start && stop ) {
							if ( stop.time - start.time < 1000 && 
									Math.abs( start.coords[0] - stop.coords[0]) > 30 &&
									Math.abs( start.coords[1] - stop.coords[1]) < 20 ) {
								start.origin
								.trigger( "swipe" )
								.trigger( start.coords[0] > stop.coords[0] ? "swipeleft" : "swiperight" );
							}
						}
						start = stop = undefined;
					});
			});
	}
};

$.event.special.orientationchange = {
	orientation: function( elem ) {
		return document.body && elem.width() / elem.height() < 1.1 ? "portrait" : "landscape";
	},
	
	setup: function() {
		var thisObject = this,
			$this = $( thisObject ),
			orientation = $.event.special.orientationchange.orientation( $this );

		function handler() {
			var newOrientation = $.event.special.orientationchange.orientation( $this );
			
			if ( orientation !== newOrientation ) {
				$.event.handle.call( thisObject, "orientationchange", {
					orientation: newOrientation
				} );
				orientation = newOrientation;
			}
		}

		if ( $.support.orientation ) {
			thisObject.addEventListener( "orientationchange", handler, false );
		} else {
			$this.bind( "resize", handler );
		}
	}
};

$.each({
	scrollstop: "scrollstart",
	taphold: "tap",
	swipeleft: "swipe",
	swiperight: "swipe"
}, function( event, sourceEvent ) {
	$.event.special[ event ] = {
		setup: function() {
			$( this ).bind( sourceEvent, $.noop );
		}
	};
});
/*!
 * jQuery hashchange event - v1.3 - 7/21/2010
 * http://benalman.com/projects/jquery-hashchange-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */

// Script: jQuery hashchange event
//
// *Version: 1.3, Last updated: 7/21/2010*
// 
// Project Home - http://benalman.com/projects/jquery-hashchange-plugin/
// GitHub       - http://github.com/cowboy/jquery-hashchange/
// Source       - http://github.com/cowboy/jquery-hashchange/raw/master/jquery.ba-hashchange.js
// (Minified)   - http://github.com/cowboy/jquery-hashchange/raw/master/jquery.ba-hashchange.min.js (0.8kb gzipped)
// 
// About: License
// 
// Copyright (c) 2010 "Cowboy" Ben Alman,
// Dual licensed under the MIT and GPL licenses.
// http://benalman.com/about/license/
// 
// About: Examples
// 
// These working examples, complete with fully commented code, illustrate a few
// ways in which this plugin can be used.
// 
// hashchange event - http://benalman.com/code/projects/jquery-hashchange/examples/hashchange/
// document.domain - http://benalman.com/code/projects/jquery-hashchange/examples/document_domain/
// 
// About: Support and Testing
// 
// Information about what version or versions of jQuery this plugin has been
// tested with, what browsers it has been tested in, and where the unit tests
// reside (so you can test it yourself).
// 
// jQuery Versions - 1.2.6, 1.3.2, 1.4.1, 1.4.2
// Browsers Tested - Internet Explorer 6-8, Firefox 2-4, Chrome 5-6, Safari 3.2-5,
//                   Opera 9.6-10.60, iPhone 3.1, Android 1.6-2.2, BlackBerry 4.6-5.
// Unit Tests      - http://benalman.com/code/projects/jquery-hashchange/unit/
// 
// About: Known issues
// 
// While this jQuery hashchange event implementation is quite stable and
// robust, there are a few unfortunate browser bugs surrounding expected
// hashchange event-based behaviors, independent of any JavaScript
// window.onhashchange abstraction. See the following examples for more
// information:
// 
// Chrome: Back Button - http://benalman.com/code/projects/jquery-hashchange/examples/bug-chrome-back-button/
// Firefox: Remote XMLHttpRequest - http://benalman.com/code/projects/jquery-hashchange/examples/bug-firefox-remote-xhr/
// WebKit: Back Button in an Iframe - http://benalman.com/code/projects/jquery-hashchange/examples/bug-webkit-hash-iframe/
// Safari: Back Button from a different domain - http://benalman.com/code/projects/jquery-hashchange/examples/bug-safari-back-from-diff-domain/
// 
// Also note that should a browser natively support the window.onhashchange 
// event, but not report that it does, the fallback polling loop will be used.
// 
// About: Release History
// 
// 1.3   - (7/21/2010) Reorganized IE6/7 Iframe code to make it more
//         "removable" for mobile-only development. Added IE6/7 document.title
//         support. Attempted to make Iframe as hidden as possible by using
//         techniques from http://www.paciellogroup.com/blog/?p=604. Added 
//         support for the "shortcut" format $(window).hashchange( fn ) and
//         $(window).hashchange() like jQuery provides for built-in events.
//         Renamed jQuery.hashchangeDelay to <jQuery.fn.hashchange.delay> and
//         lowered its default value to 50. Added <jQuery.fn.hashchange.domain>
//         and <jQuery.fn.hashchange.src> properties plus document-domain.html
//         file to address access denied issues when setting document.domain in
//         IE6/7.
// 1.2   - (2/11/2010) Fixed a bug where coming back to a page using this plugin
//         from a page on another domain would cause an error in Safari 4. Also,
//         IE6/7 Iframe is now inserted after the body (this actually works),
//         which prevents the page from scrolling when the event is first bound.
//         Event can also now be bound before DOM ready, but it won't be usable
//         before then in IE6/7.
// 1.1   - (1/21/2010) Incorporated document.documentMode test to fix IE8 bug
//         where browser version is incorrectly reported as 8.0, despite
//         inclusion of the X-UA-Compatible IE=EmulateIE7 meta tag.
// 1.0   - (1/9/2010) Initial Release. Broke out the jQuery BBQ event.special
//         window.onhashchange functionality into a separate plugin for users
//         who want just the basic event & back button support, without all the
//         extra awesomeness that BBQ provides. This plugin will be included as
//         part of jQuery BBQ, but also be available separately.

(function($,window,undefined){
  '$:nomunge'; // Used by YUI compressor.
  
  // Reused string.
  var str_hashchange = 'hashchange',
    
    // Method / object references.
    doc = document,
    fake_onhashchange,
    special = $.event.special,
    
    // Does the browser support window.onhashchange? Note that IE8 running in
    // IE7 compatibility mode reports true for 'onhashchange' in window, even
    // though the event isn't supported, so also test document.documentMode.
    doc_mode = doc.documentMode,
    supports_onhashchange = 'on' + str_hashchange in window && ( doc_mode === undefined || doc_mode > 7 );
  
  // Get location.hash (or what you'd expect location.hash to be) sans any
  // leading #. Thanks for making this necessary, Firefox!
  function get_fragment( url ) {
    url = url || location.href;
    return '#' + url.replace( /^[^#]*#?(.*)$/, '$1' );
  };
  
  // Method: jQuery.fn.hashchange
  // 
  // Bind a handler to the window.onhashchange event or trigger all bound
  // window.onhashchange event handlers. This behavior is consistent with
  // jQuery's built-in event handlers.
  // 
  // Usage:
  // 
  // > jQuery(window).hashchange( [ handler ] );
  // 
  // Arguments:
  // 
  //  handler - (Function) Optional handler to be bound to the hashchange
  //    event. This is a "shortcut" for the more verbose form:
  //    jQuery(window).bind( 'hashchange', handler ). If handler is omitted,
  //    all bound window.onhashchange event handlers will be triggered. This
  //    is a shortcut for the more verbose
  //    jQuery(window).trigger( 'hashchange' ). These forms are described in
  //    the <hashchange event> section.
  // 
  // Returns:
  // 
  //  (jQuery) The initial jQuery collection of elements.
  
  // Allow the "shortcut" format $(elem).hashchange( fn ) for binding and
  // $(elem).hashchange() for triggering, like jQuery does for built-in events.
  $.fn[ str_hashchange ] = function( fn ) {
    return fn ? this.bind( str_hashchange, fn ) : this.trigger( str_hashchange );
  };
  
  // Property: jQuery.fn.hashchange.delay
  // 
  // The numeric interval (in milliseconds) at which the <hashchange event>
  // polling loop executes. Defaults to 50.
  
  // Property: jQuery.fn.hashchange.domain
  // 
  // If you're setting document.domain in your JavaScript, and you want hash
  // history to work in IE6/7, not only must this property be set, but you must
  // also set document.domain BEFORE jQuery is loaded into the page. This
  // property is only applicable if you are supporting IE6/7 (or IE8 operating
  // in "IE7 compatibility" mode).
  // 
  // In addition, the <jQuery.fn.hashchange.src> property must be set to the
  // path of the included "document-domain.html" file, which can be renamed or
  // modified if necessary (note that the document.domain specified must be the
  // same in both your main JavaScript as well as in this file).
  // 
  // Usage:
  // 
  // jQuery.fn.hashchange.domain = document.domain;
  
  // Property: jQuery.fn.hashchange.src
  // 
  // If, for some reason, you need to specify an Iframe src file (for example,
  // when setting document.domain as in <jQuery.fn.hashchange.domain>), you can
  // do so using this property. Note that when using this property, history
  // won't be recorded in IE6/7 until the Iframe src file loads. This property
  // is only applicable if you are supporting IE6/7 (or IE8 operating in "IE7
  // compatibility" mode).
  // 
  // Usage:
  // 
  // jQuery.fn.hashchange.src = 'path/to/file.html';
  
  $.fn[ str_hashchange ].delay = 50;
  /*
  $.fn[ str_hashchange ].domain = null;
  $.fn[ str_hashchange ].src = null;
  */
  
  // Event: hashchange event
  // 
  // Fired when location.hash changes. In browsers that support it, the native
  // HTML5 window.onhashchange event is used, otherwise a polling loop is
  // initialized, running every <jQuery.fn.hashchange.delay> milliseconds to
  // see if the hash has changed. In IE6/7 (and IE8 operating in "IE7
  // compatibility" mode), a hidden Iframe is created to allow the back button
  // and hash-based history to work.
  // 
  // Usage as described in <jQuery.fn.hashchange>:
  // 
  // > // Bind an event handler.
  // > jQuery(window).hashchange( function(e) {
  // >   var hash = location.hash;
  // >   ...
  // > });
  // > 
  // > // Manually trigger the event handler.
  // > jQuery(window).hashchange();
  // 
  // A more verbose usage that allows for event namespacing:
  // 
  // > // Bind an event handler.
  // > jQuery(window).bind( 'hashchange', function(e) {
  // >   var hash = location.hash;
  // >   ...
  // > });
  // > 
  // > // Manually trigger the event handler.
  // > jQuery(window).trigger( 'hashchange' );
  // 
  // Additional Notes:
  // 
  // * The polling loop and Iframe are not created until at least one handler
  //   is actually bound to the 'hashchange' event.
  // * If you need the bound handler(s) to execute immediately, in cases where
  //   a location.hash exists on page load, via bookmark or page refresh for
  //   example, use jQuery(window).hashchange() or the more verbose 
  //   jQuery(window).trigger( 'hashchange' ).
  // * The event can be bound before DOM ready, but since it won't be usable
  //   before then in IE6/7 (due to the necessary Iframe), recommended usage is
  //   to bind it inside a DOM ready handler.
  
  // Override existing $.event.special.hashchange methods (allowing this plugin
  // to be defined after jQuery BBQ in BBQ's source code).
  special[ str_hashchange ] = $.extend( special[ str_hashchange ], {
    
    // Called only when the first 'hashchange' event is bound to window.
    setup: function() {
      // If window.onhashchange is supported natively, there's nothing to do..
      if ( supports_onhashchange ) { return false; }
      
      // Otherwise, we need to create our own. And we don't want to call this
      // until the user binds to the event, just in case they never do, since it
      // will create a polling loop and possibly even a hidden Iframe.
      $( fake_onhashchange.start );
    },
    
    // Called only when the last 'hashchange' event is unbound from window.
    teardown: function() {
      // If window.onhashchange is supported natively, there's nothing to do..
      if ( supports_onhashchange ) { return false; }
      
      // Otherwise, we need to stop ours (if possible).
      $( fake_onhashchange.stop );
    }
    
  });
  
  // fake_onhashchange does all the work of triggering the window.onhashchange
  // event for browsers that don't natively support it, including creating a
  // polling loop to watch for hash changes and in IE 6/7 creating a hidden
  // Iframe to enable back and forward.
  fake_onhashchange = (function(){
    var self = {},
      timeout_id,
      
      // Remember the initial hash so it doesn't get triggered immediately.
      last_hash = get_fragment(),
      
      fn_retval = function(val){ return val; },
      history_set = fn_retval,
      history_get = fn_retval;
    
    // Start the polling loop.
    self.start = function() {
      timeout_id || poll();
    };
    
    // Stop the polling loop.
    self.stop = function() {
      timeout_id && clearTimeout( timeout_id );
      timeout_id = undefined;
    };
    
    // This polling loop checks every $.fn.hashchange.delay milliseconds to see
    // if location.hash has changed, and triggers the 'hashchange' event on
    // window when necessary.
    function poll() {
      var hash = get_fragment(),
        history_hash = history_get( last_hash );
      
      if ( hash !== last_hash ) {
        history_set( last_hash = hash, history_hash );
        
        $(window).trigger( str_hashchange );
        
      } else if ( history_hash !== last_hash ) {
        location.href = location.href.replace( /#.*/, '' ) + history_hash;
      }
      
      timeout_id = setTimeout( poll, $.fn[ str_hashchange ].delay );
    };
    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvv REMOVE IF NOT SUPPORTING IE6/7/8 vvvvvvvvvvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    $.browser.msie && !supports_onhashchange && (function(){
      // Not only do IE6/7 need the "magical" Iframe treatment, but so does IE8
      // when running in "IE7 compatibility" mode.
      
      var iframe,
        iframe_src;
      
      // When the event is bound and polling starts in IE 6/7, create a hidden
      // Iframe for history handling.
      self.start = function(){
        if ( !iframe ) {
          iframe_src = $.fn[ str_hashchange ].src;
          iframe_src = iframe_src && iframe_src + get_fragment();
          
          // Create hidden Iframe. Attempt to make Iframe as hidden as possible
          // by using techniques from http://www.paciellogroup.com/blog/?p=604.
          iframe = $('<iframe tabindex="-1" title="empty"/>').hide()
            
            // When Iframe has completely loaded, initialize the history and
            // start polling.
            .one( 'load', function(){
              iframe_src || history_set( get_fragment() );
              poll();
            })
            
            // Load Iframe src if specified, otherwise nothing.
            .attr( 'src', iframe_src || 'javascript:0' )
            
            // Append Iframe after the end of the body to prevent unnecessary
            // initial page scrolling (yes, this works).
            .insertAfter( 'body' )[0].contentWindow;
          
          // Whenever `document.title` changes, update the Iframe's title to
          // prettify the back/next history menu entries. Since IE sometimes
          // errors with "Unspecified error" the very first time this is set
          // (yes, very useful) wrap this with a try/catch block.
          doc.onpropertychange = function(){
            try {
              if ( event.propertyName === 'title' ) {
                iframe.document.title = doc.title;
              }
            } catch(e) {}
          };
          
        }
      };
      
      // Override the "stop" method since an IE6/7 Iframe was created. Even
      // if there are no longer any bound event handlers, the polling loop
      // is still necessary for back/next to work at all!
      self.stop = fn_retval;
      
      // Get history by looking at the hidden Iframe's location.hash.
      history_get = function() {
        return get_fragment( iframe.location.href );
      };
      
      // Set a new history item by opening and then closing the Iframe
      // document, *then* setting its location.hash. If document.domain has
      // been set, update that as well.
      history_set = function( hash, history_hash ) {
        var iframe_doc = iframe.document,
          domain = $.fn[ str_hashchange ].domain;
        
        if ( hash !== history_hash ) {
          // Update Iframe with any initial `document.title` that might be set.
          iframe_doc.title = doc.title;
          
          // Opening the Iframe's document after it has been closed is what
          // actually adds a history entry.
          iframe_doc.open();
          
          // Set document.domain for the Iframe document as well, if necessary.
          domain && iframe_doc.write( '<script>document.domain="' + domain + '"</script>' );
          
          iframe_doc.close();
          
          // Update the Iframe's hash, for great justice.
          iframe.location.hash = hash;
        }
      };
      
    })();
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    // ^^^^^^^^^^^^^^^^^^^ REMOVE IF NOT SUPPORTING IE6/7/8 ^^^^^^^^^^^^^^^^^^^
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    return self;
  })();
  
})(jQuery,this);
(function ( $ ) {

$.widget( "mobile.page", $.mobile.widget, {
	options: {},
	
	_create: function() {
		if ( this._trigger( "beforeCreate" ) === false ) {
			return;
		}
		
		//some of the form elements currently rely on the presence of ui-page and ui-content
		// classes so we'll handle page and content roles outside of the main role processing
		// loop below.
		this.element.find( "[data-role=page],[data-role=content]" ).andSelf().each(function() {
			var $this = $( this );
			$this.addClass( "ui-" + $this.data( "role" ) );
		});
		
		this.element.find( "[data-role=nojs]" ).addClass( "ui-nojs" );
		this._enchanceControls();
		
		//pre-find data els
		var $dataEls = this.element.find( "[data-role]" ).andSelf().each(function() {
			var $this = $( this ),
				role = $this.data( "role" ),
				theme = $this.data( "theme" );
			
			//apply theming and markup modifications to page,header,content,footer
			if ( role === "header" || role === "footer" ) {
				$this.addClass( "ui-bar-" + (theme || "a") );
				
				//add ARIA role
				if( role == "header" ){
					$this.attr("role","banner");
				}
				else{
					$this.attr("role","contentinfo");
				}
				
				//right,left buttons
				var $headeranchors = $this.children( "a" ),
					leftbtn = $headeranchors.filter( ".ui-btn-left" ).length,
					rightbtn = $headeranchors.filter( ".ui-btn-right" ).length;
				
				if ( !leftbtn ) {
					leftbtn = $headeranchors.eq( 0 ).not('.ui-btn-right').addClass( "ui-btn-left" ).length;
				}
				if ( !rightbtn ) {
					rightbtn = $headeranchors.eq( 1 ).addClass( "ui-btn-right" ).length;
				}
				
				//auto-add back btn on pages beyond first view
				if ( $.mobile.addBackBtn && role === "header" && ($.mobile.urlStack.length > 1 || $('.ui-page').length > 1) && !leftbtn && !$this.data( "noBackBtn" ) ) {
					$( "<a href='#' class='ui-btn-left' data-icon='arrow-l'>Back</a>" )
						.tap(function() {
							history.back();
							return false;
						})
						.click(function() {
							return false;
						})
						.prependTo( $this );
				}
				
				//page title	
				$this.children( ":header" )
					.addClass( "ui-title" )
					.attr( "tabindex" , "0")
					.attr( "role" ,"heading")
					.attr( "aria-level", "1" ); //regardless of h element number in src, it becomes h1 for the enhanced page
			} else if ( role === "content" ) {
				if( theme ){
					$this.addClass( "ui-body-" + theme);
				}
				//add ARIA role
				$this.attr("role","main");
			}
			else if( role == "page" ){
				$this.addClass( "ui-body-" + (theme || "c") );
			}
			
			switch(role) {
			case "header":
			case "footer":
			case "page":
			case "content":
				$this.addClass( "ui-" + role );
				break;
			case "collapsible":
			case "fieldcontain":
			case "navbar":
			case "listview":
			case "dialog":
			case "ajaxform":
				$this[ role ]();
				break;
			}
		});
		
		//links in bars, or those with data-role become buttons
		this.element.find( "[data-role=button], .ui-bar a, .ui-header a, .ui-footer a" )
			.not( ".ui-btn" )
			.buttonMarkup();
		
		
		this.element
			.find('[data-role="controlgroup"]')
			.controlgroup();
		
		//links within content areas
		this.element.find( "a:not(.ui-btn):not(.ui-link-inherit)" )
			.addClass( "ui-link" );	
		
		//fix toolbars
		this.element.fixHeaderFooter();
	},
	
	_enchanceControls: function() {
		// degrade inputs to avoid poorly implemented native functionality
		this.element.find( "input" ).each(function() {
			var type = this.getAttribute( "type" );
			if ( $.mobile.degradeInputs[ type ] ) {
				$( this ).replaceWith(
					$( "<div>" ).html( $(this).clone() ).html()
						.replace( /type="([a-zA-Z]+)"/, "data-type='$1'" ) );
			}
		});
		
		// enchance form controls
		this.element
			.find( ":radio, :checkbox" )
			.customCheckboxRadio();
		this.element
			.find( ":button, :submit, :reset, :image" )
			.not( ".ui-nojs" )
			.customButton();
		this.element
			.find( "input, textarea" )
			.not( ":radio, :checkbox, :button, :submit, :reset, :image" )
			.customTextInput();
		this.element
			.find( "input, select" )
			.filter( "[data-role=slider], [data-type=range]" )
			.slider();
		this.element
			.find( "select" )
			.not( "[data-role=slider]" )
			.customSelect();
	}
});

})( jQuery );
/*
* jQuery Mobile Framework : sample scripting for manipulating themed interaction states
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.clickable = function(){
	return $(this).each(function(){
		var theme = $(this).attr('data-theme');
		$(this)
			.mousedown(function(){
				$(this).removeClass('ui-btn-up-'+theme).addClass('ui-btn-down-'+theme);
			})
			.mouseup(function(){
				$(this).removeClass('ui-btn-down-'+theme).addClass('ui-btn-up-'+theme);
			})
			.bind('mouseover focus',function(){
				$(this).removeClass('ui-btn-up-'+theme).addClass('ui-btn-hover-'+theme);
			})
			.bind('mouseout blur',function(){
				$(this).removeClass('ui-btn-hover-'+theme).addClass('ui-btn-up-'+theme);
			});
	});	
};		
})(jQuery);


/*
* jQuery Mobile Framework : prototype for "fixHeaderFooter" plugin - on-demand positioning for headers,footers
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.fixHeaderFooter = function(options){
	if( !$.support.scrollTop ){ return $(this); }
	return $(this).each(function(){
		if( $(this).data('fullscreen') ){ $(this).addClass('ui-page-fullscreen'); }
		$(this).find('.ui-header[data-position="fixed"]').addClass('ui-header-fixed ui-fixed-inline fade'); //should be slidedown
		$(this).find('.ui-footer[data-position="fixed"]').addClass('ui-footer-fixed ui-fixed-inline fade'); //should be slideup		
	});
};				

//single controller for all showing,hiding,toggling		
$.fixedToolbars = (function(){
	if( !$.support.scrollTop ){ return; }
	var currentstate = 'inline',
		delayTimer,
		ignoreTargets = 'a,input,textarea,select,button,label,.ui-header-fixed,.ui-footer-fixed',
		toolbarSelector = '.ui-page-active .ui-header-fixed:first, .ui-page-active .ui-footer-fixed:not(.ui-footer-duplicate):last',
		stickyFooter, //for storing quick references to duplicate footers
		supportTouch = $.support.touch,
		touchStartEvent = supportTouch ? "touchstart" : "mousedown",
		touchStopEvent = supportTouch ? "touchend" : "mouseup",
		stateBefore = null,
		scrollTriggered = false;
		
	$(function() {
		$(document)
			.bind(touchStartEvent,function(event){
				if( $(event.target).closest(ignoreTargets).length ){ return; }
				stateBefore = currentstate;
				$.fixedToolbars.hide(true);
			})
			.bind('scrollstart',function(event){
				if( $(event.target).closest(ignoreTargets).length ){ return; } //because it could be a touchmove...
				scrollTriggered = true;
				if(stateBefore == null){ stateBefore = currentstate; }
				$.fixedToolbars.hide(true);
			})
			.bind(touchStopEvent,function(event){
				if( $(event.target).closest(ignoreTargets).length ){ return; }
				if( !scrollTriggered ){
					$.fixedToolbars.toggle(stateBefore);
					stateBefore = null;
				}
			})
			.bind('scrollstop',function(event){
				if( $(event.target).closest(ignoreTargets).length ){ return; }
				scrollTriggered = false;
				$.fixedToolbars.toggle( stateBefore == 'overlay' ? 'inline' : 'overlay' );
				stateBefore = null;
			});
		
		//function to return another footer already in the dom with the same data-id
		function findStickyFooter(el){
			var thisFooter = el.find('[data-role="footer"]');
			return jQuery( '.ui-footer[data-id="'+ thisFooter.data('id') +'"]:not(.ui-footer-duplicate)' ).not(thisFooter);
		}
		
		//before page is shown, check for duplicate footer
		$('.ui-page').live('beforepageshow', function(event, ui){
			stickyFooter = findStickyFooter( $(event.target) );
			if( stickyFooter.length ){
				//if the existing footer is the first of its kind, create a placeholder before stealing it 
				if( stickyFooter.parents('.ui-page:eq(0)').find('.ui-footer[data-id="'+ stickyFooter.data('id') +'"]').length == 1 ){
					stickyFooter.before( stickyFooter.clone().addClass('ui-footer-duplicate') );
				}
				$(event.target).find('[data-role="footer"]').addClass('ui-footer-duplicate');
				stickyFooter.appendTo('body').css('top',0);
				setTop(stickyFooter);
			}
		});

		//after page is shown, append footer to new page
		$('.ui-page').live('pageshow', function(event, ui){
			if( stickyFooter && stickyFooter.length ){
				stickyFooter.appendTo(event.target).css('top',0);
			}
			$.fixedToolbars.show(true);
		});
		
	});
	
	function setTop(el){
		var fromTop = $(window).scrollTop(),
			thisTop = el.offset().top,
			thisCSStop = el.css('top') == 'auto' ? 0 : parseFloat(el.css('top')),
			screenHeight = window.innerHeight,
			thisHeight = el.outerHeight(),
			useRelative = el.parents('.ui-page:not(.ui-page-fullscreen)').length,
			relval;
		if( el.is('.ui-header-fixed') ){
			relval = fromTop - thisTop + thisCSStop;
			if( relval < thisTop){ relval = 0; }
			return el.css('top', ( useRelative ) ? relval : fromTop);
		}
		else{
			relval = -1 * (thisTop - (fromTop + screenHeight) + thisCSStop + thisHeight);
			if( relval > thisTop ){ relval = 0; }
			return el.css('top', ( useRelative ) ? relval : fromTop + screenHeight - thisHeight );
		}
	}

	//exposed methods
	return {
		show: function(immediately){
			currentstate = 'overlay';
			return $( toolbarSelector ).each(function(){
				var el = $(this),
					fromTop = $(window).scrollTop(),
					thisTop = el.offset().top,
					screenHeight = window.innerHeight,
					thisHeight = el.outerHeight(),
					alreadyVisible = (el.is('.ui-header-fixed') && fromTop <= thisTop + thisHeight) || (el.is('.ui-footer-fixed') && thisTop <= fromTop + screenHeight);	
				
				//add state class
				el.addClass('ui-fixed-overlay').removeClass('ui-fixed-inline');	
					
				if( !alreadyVisible && !immediately ){
					el.addClass('in').animationComplete(function(){
						el.removeClass('in');
					});
				}
				setTop(el);
			});	
		},
		hide: function(immediately){
			currentstate = 'inline';
			return $( toolbarSelector ).each(function(){
				var el = $(this);
				
				//add state class
				el.addClass('ui-fixed-inline').removeClass('ui-fixed-overlay');
				
				if(immediately){
					el.css('top',0);
				}
				else{
					if( el.css('top') !== 'auto' && parseFloat(el.css('top')) !== 0 ){
						var classes = 'out reverse';
						el.addClass(classes).animationComplete(function(){
							el.removeClass(classes);
							el.css('top',0);
						});	
					}
				}
			});
		},
		hideAfterDelay: function(){
			delayTimer = setTimeout(function(){
				$.fixedToolbars.hide();
			}, 3000);
		},
		toggle: function(from){
			if(from){ currentstate = from; }
			return (currentstate == 'overlay') ? $.fixedToolbars.hide() : $.fixedToolbars.show();
		}
	};
})();

})(jQuery);/*
* jQuery Mobile Framework : "customCheckboxRadio" plugin (based on code from Filament Group,Inc)
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/  
(function($){
$.fn.customCheckboxRadio = function(options){
	return $(this).each(function(){	
		if($(this).is('[type=checkbox],[type=radio]')){
			var input = $(this);
			
			var o = $.extend({
				theme: $(this).data('theme'),
				icon: $(this).data('icon') || !input.parents('[data-type="horizontal"]').length,
				checkedicon: 'ui-icon-'+input.attr('type')+'-on',
				uncheckedicon: 'ui-icon-'+input.attr('type')+'-off'
			},options);
			
			// get the associated label using the input's id
			var label = $('label[for='+input.attr('id')+']').buttonMarkup({iconpos: o.icon ? 'left' : '', theme: o.theme, icon: o.icon ? o.uncheckedicon : null, shadow: false});
						
			var icon = label.find('.ui-icon');
			
			// wrap the input + label in a div 
			input
				.add(label)
				.wrapAll('<div class="ui-'+ input.attr('type') +'"></div>');
			
			// necessary for browsers that don't support the :hover pseudo class on labels
			label
			.mousedown(function(){
				$(this).data('state', input.attr('checked'));
			})
			.click(function(){
				setTimeout(function(){
					if(input.attr('checked') == $(this).data('state')){
						input.trigger('click');
					}
				}, 1);
			})
			.clickable();
			
			//bind custom event, trigger it, bind click,focus,blur events					
			input.bind('updateState', function(){	
				if(input.is(':checked')){
					label.addClass('ui-btn-active');
					icon.addClass(o.checkedicon);
					icon.removeClass(o.uncheckedicon);
				}
				else {
					label.removeClass('ui-btn-active'); 
					icon.removeClass(o.checkedicon);
					icon.addClass(o.uncheckedicon);
				} 
				if(!input.is(':checked')){ label.removeClass('ui-focus'); }
			})
			.trigger('updateState')
			.click(function(){ 
				$('input[name='+ $(this).attr('name') +']').trigger('updateState'); 
			})
			.focus(function(){ 
				label.addClass('ui-focus'); 
				if(input.is(':checked')){  label.addClass('ui-focus'); } 
			})
			.blur(function(){ label.removeClass('ui-focus'); });
		}
	});
};
})(jQuery);/*
* jQuery Mobile Framework : "customTextInput" plugin for text inputs, textareas (based on code from Filament Group,Inc)
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
jQuery.fn.customTextInput = function(options){
	return $(this).each(function(){	
		var input = $(this);
		
		var o = $.extend({
			search: input.is('[type="search"],[data-type="search"]'), 
			theme: input.data("theme") || "c"
		}, options);
		
		$('label[for='+input.attr('id')+']').addClass('ui-input-text');
		
		input.addClass('ui-input-text ui-body-'+ o.theme);
		
		var focusedEl = input;
		
		//"search" input widget
		if(o.search){
			focusedEl = input.wrap('<div class="ui-input-search ui-shadow-inset ui-btn-corner-all ui-body-c ui-btn-shadow ui-icon-search"></div>').parent();
			var clearbtn = $('<a href="#" class="ui-input-clear" title="clear text">clear text</a>')
				.buttonMarkup({icon: 'delete', iconpos: 'notext', corners:true, shadow:true})
				.click(function(){
					input.val('').focus();
					input.trigger('change'); 
					clearbtn.addClass('ui-input-clear-hidden');
					return false;
				})
				.appendTo(focusedEl);
			
			function toggleClear(){
				if(input.val() == ''){
					clearbtn.addClass('ui-input-clear-hidden');
				}
				else{
					clearbtn.removeClass('ui-input-clear-hidden');
				}
			}
			
			toggleClear();
			input.keyup(toggleClear);	
		}
		else{
			input.addClass('ui-corner-all ui-shadow-inset');
		}
				
		input
			.focus(function(){
				focusedEl.addClass('ui-focus');
			})
			.blur(function(){
				focusedEl.removeClass('ui-focus');
			});	
			
		//autogrow	
		if(input.is('textarea')){
			input.keydown(function(){
				if( input[0].offsetHeight < input[0].scrollHeight ){
					input.css({height: input[0].scrollHeight + 10 });
				}
			})
		}	
	});
};
})(jQuery);
/*
* jQuery Mobile Framework : "customSelect" plugin (based on code from Filament Group,Inc)
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/  
(function($){
$.fn.customSelect = function(options){
	return $(this).each(function(){	
		var select = $(this)
						.attr( "tabindex", "-1" )
						.wrap( "<div class='ui-select'>" ),
			selectID = select.attr( "id" ),
			label = $( "label[for="+ selectID +"]" )
						.addClass( "ui-select" ),
				
		//extendable options
		o = $.extend({
			closeText: "close",
			chooseText: label.text(),
			theme: select.data("theme")
		}, options),

		buttonId = selectID + "-button",
		menuId = selectID + "-menu",
		thisPage = select.closest( ".ui-page" ),
		menuType,
		currScroll,		
		button = $( "<a>", { 
				"href": "#",
				"role": "button",
				"title": "select menu",
				"id": buttonId,
				"aria-haspopup": "true",
				"aria-owns": menuId 
			})
			.text( $( this.options.item(this.selectedIndex) ).text() )
			.insertBefore( select )
			.buttonMarkup({
				iconpos: 'right',
				icon: 'arrow-d',
				theme: o.theme
			}),
		menuPage = $( "<div data-role='dialog' data-theme='a'>" +
					"<div data-role='header' data-theme='b'>" +
						"<a href='#' class='ui-btn-left' data-icon='delete' data-iconpos='notext'>"+ o.closeText +"</a>"+
						"<div class='ui-title'>" + o.chooseText + "</div>"+
					"</div>"+
					"<div data-role='content'></div>"+
				"</div>" )
				.appendTo( "body" )
				.page(),	
		menuPageContent = menuPage.find( ".ui-content" ),			
		screen = $( "<div>", {
						"class": "ui-listbox-screen ui-overlay ui-screen-hidden fade"
				})
				.appendTo( thisPage ),					
		listbox = $( "<div>", { "class": "ui-listbox ui-listbox-hidden ui-body-a ui-overlay-shadow ui-corner-all pop"} )
				.insertAfter(screen),
		list = $( "<ul>", { 
				"class": "ui-listbox-list", 
				"id": menuId, 
				"role": "listbox", 
				"aria-labelledby": buttonId
			})
			.appendTo( listbox );
			
		//populate menu
		select.find( "option" ).each(function( i ){
			var selected = (select[0].selectedIndex == i),
				anchor = $("<a>", { 
							"aria-selected": selected, 
							"role": "option", 
							"href": "#"
						})
						.text( $(this).text() );
			
			$( "<li>", {
					"class": selected ? "ui-btn-active" : '', 
					"data-icon": "checkbox-on"
				})
				.append( anchor )
				.appendTo( list );
		});
		
		//now populated, create listview
		list.listview();
		
		
		
		function showmenu(){
			var menuHeight = list.outerHeight();
			currScroll = [ $(window).scrollLeft(), $(window).scrollTop() ];
			
			if( menuHeight > window.innerHeight - 80 || !$.support.scrollTop ){
				menuType = "page";		
				menuPageContent.append( list );
				$.changePage(thisPage, menuPage, false, false);
			}
			else {
				menuType = "overlay";
				
				screen
					.height( $(document).height() )
					.removeClass('ui-screen-hidden');
					
				listbox
					.append( list )
					.removeClass( "ui-listbox-hidden" )
					.css({
						top: $(window).scrollTop() + (window.innerHeight/2), 
						"margin-top": -menuHeight/2,
						left: window.innerWidth/2,
						"margin-left": -1* listbox.outerWidth() / 2
					})
					.addClass("in");
			}
		};
		
		function hidemenu(){
			if(menuType == "page"){			
				$.changePage(menuPage, thisPage, false, true);
			}
			else{
				screen.addClass( "ui-screen-hidden" );
				listbox.addClass( "ui-listbox-hidden" ).removeAttr( "style" ).removeClass("in");
			}
		};
		
		//page show/hide events
		menuPage
			.bind("pageshow", function(){
				list.find( ".ui-btn-active" ).focus();
				return false;
			})
			.bind("pagehide", function(){
				window.scrollTo(currScroll[0], currScroll[1]);
				select.focus();
				listbox.append( list ).removeAttr('style');
				return false;
			});
			

		//select properties,events
		select
			.change(function(){ 
				var $el = select.get(0);
				button.find( ".ui-btn-text" ).text( $($el.options.item($el.selectedIndex)).text() ); 
			})
			.focus(function(){
				$(this).blur();
				button.focus();
			});		
		
		//button events
		button.mousedown(function(event){
				showmenu();
				return false;
			});
		
		//apply click events for items
		list
			.find("li")
			.mousedown(function(){
				//deselect active
				list.find( "li" )
					.removeClass( "ui-btn-active" )
					.children(0)
					.attr( "aria-selected", "false");
					
				//select this one	
				$(this)
					.addClass( "ui-btn-active" )
					.find( "a" )
					.attr( "aria-selected", "true");
				
				//update select	
				var newIndex = list.find( "li" ).index( this ),
					prevIndex = select[0].selectedIndex;

				select[0].selectedIndex = newIndex;
				
				//trigger change event
				if(newIndex !== prevIndex){ 
					select.trigger( "change" ); 
				}
				
				//hide custom select
				hidemenu();
				return false;
			});	

		//menu page back button
		menuPage.find( ".ui-btn-left" ).click(function(){
			hidemenu();
			return false;
		});
	
		//hide on outside click
		screen.click(function(){
			hidemenu();
			return false;
		});	
	});
};

})(jQuery);
	
/*
* jQuery Mobile Framework : sample plugin for making button-like links
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/ 
(function($){

$.fn.buttonMarkup = function( options ){
	return this.each( function() {
		var el = $( this ),
		    o = $.extend( {}, {
				theme: (function(){
					//if data-theme attr is present
					if(el.is('[data-theme]')){
						return el.attr('data-theme');
					}
					//if not, try to find closest theme container
					else if( el.parents('body').length ) {
						var themedParent = el.closest('[class*=ui-bar-],[class*=ui-body-]'); 
						return themedParent.length ? themedParent.attr('class').match(/ui-(bar|body)-([a-z])/)[2] : 'c';
					}
					else{
						return 'c';
					}
				})(),
				iconpos: el.data('iconpos'),
				icon: el.data('icon'),
				inline: el.data('inline')
			}, $.fn.buttonMarkup.defaults, options),
			
			// Classes Defined
			buttonClass = "ui-btn ui-btn-up-" + o.theme,
			innerClass = "ui-btn-inner",
			iconClass;
		
		if( o.inline ){
			buttonClass += " ui-btn-inline";
		}
		
		if (o.icon) {
			o.icon = 'ui-icon-' + o.icon;

			iconClass = "ui-icon " + o.icon;

			if (o.shadow) { iconClass += " ui-icon-shadow" }
			o.iconpos = o.iconpos || 'left';
		}
		
		if (o.iconpos){
			buttonClass += " ui-btn-icon-" + o.iconpos;
			
			if( o.iconpos == 'notext' && !el.attr('title') ){
				el.attr('title', el.text() );
			}
			
		}
		
		
		
		
		if (o.corners) { 
			buttonClass += " ui-btn-corner-all";
			innerClass += " ui-btn-corner-all";
		}
		
		if (o.shadow) {
			buttonClass += " ui-shadow";
		}
		
		el
			.attr( 'data-theme', o.theme )
			.addClass( buttonClass )
			.wrapInner( $( '<' + o.wrapperEls + '>', { className: "ui-btn-text" } ) );
		
		if (o.icon) {
			el.prepend( $( '<span>', { className: iconClass } ) );
		}
		
		el.wrapInner( $('<' + o.wrapperEls + '>', { className: innerClass }) );
		
		el.clickable();
	});		
};

$.fn.buttonMarkup.defaults = {
	corners: true,
	shadow: true,
	iconshadow: true,
	wrapperEls: 'span'
};

})(jQuery);

/*
* jQuery Mobile Framework : sample plugin for making button links that proxy to native input/buttons
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/ 
(function($){
$.fn.customButton = function(){
	return $(this).each(function(){	
		var button = $(this).addClass('ui-btn-hidden').attr('tabindex','-1');
		//add ARIA role
		$('<a href="#" role="button">'+ (button.text() || button.val()) +'</a>')
			.buttonMarkup({
				theme: button.data('theme'), 
				icon: button.data('icon'),
				iconpos: button.data('iconpos'),
				inline: button.data('inline')
			})
			.click(function(){
				button.click(); 
				return false;
			})
			.insertBefore(button);
	});
};
})(jQuery);/*
* jQuery Mobile Framework : "slider" plugin (based on code from Filament Group,Inc)
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/  
(function($){
$.fn.slider = function(options){
	return this.each(function(){	
		var control = $(this),
			themedParent = control.parents('[class*=ui-bar-],[class*=ui-body-]').eq(0),
			
			o = $.extend({
				trackTheme: (themedParent.length ? themedParent.attr('class').match(/ui-(bar|body)-([a-z])/)[2] : 'c'),
				theme: control.data("theme") || (themedParent.length ? themedParent.attr('class').match(/ui-(bar|body)-([a-z])/)[2] : 'c')
			},options),
			
			cType = control[0].nodeName.toLowerCase(),
			selectClass = (cType == 'select') ? 'ui-slider-switch' : '',
			controlID = control.attr('id'),
			labelID = controlID + '-label',
			label = $('[for='+ controlID +']').attr('id',labelID),
			val = (cType == 'input') ? control.val() : control[0].selectedIndex,
			min = (cType == 'input') ? parseFloat(control.attr('min')) : 0,
			max = (cType == 'input') ? parseFloat(control.attr('max')) : control.find('option').length-1,
			percent = val / (max - min) * 100,
			snappedPercent = percent,
			slider = $('<div class="ui-slider '+ selectClass +' ui-btn-down-'+o.trackTheme+' ui-btn-corner-all" role="application"></div>'),
			handle = $('<a href="#" class="ui-slider-handle"></a>')
				.appendTo(slider)
				.buttonMarkup({corners: true, theme: o.theme, shadow: true})
				.attr({
					'role': 'slider',
					'aria-valuemin': min,
					'aria-valuemax': max,
					'aria-valuenow': val,
					'aria-valuetext': val,
					'title': val,
					'aria-labelledby': labelID
				}),
			dragging = false;
			
		if(cType == 'select'){
			slider.wrapInner('<div class="ui-slider-inneroffset"></div>');
			var options = control.find('option');
				
			control.find('option').each(function(i){
				var side = (i==0) ?'b':'a',
					corners = (i==0) ? 'right' :'left',
					theme = (i==0) ? ' ui-btn-down-' + o.trackTheme :' ui-btn-active';
				$('<div class="ui-slider-labelbg ui-slider-labelbg-'+ side + theme +' ui-btn-corner-'+ corners+'"></div>').prependTo(slider);	
				$('<span class="ui-slider-label ui-slider-label-'+ side + theme +' ui-btn-corner-'+ corners+'" role="img">'+$(this).text()+'</span>').prependTo(handle);
			});
			
		}	
		
		function updateControl(val){
			if(cType == 'input'){ 
				control.val(val); 
			}
			else { 
				control[0].selectedIndex = val;
			}
		}
			
		function slideUpdate(event, val){
			if (val){
				percent = parseFloat(val) / (max - min) * 100;
			} else {
				var data = event.originalEvent.touches ? event.originalEvent.touches[ 0 ] : event,
					// a slight tolerance helped get to the ends of the slider
					tol = 4;
				if( !dragging 
						|| data.pageX < slider.offset().left - tol 
						|| data.pageX > slider.offset().left + slider.width() + tol ){ 
					return; 
				}
				percent = Math.round(((data.pageX - slider.offset().left) / slider.width() ) * 100);
			}
			if( percent < 0 ) { percent = 0; }
			if( percent > 100 ) { percent = 100; }
			var newval = Math.round( (percent/100) * max );
			if( newval < min ) { newval = min; }
			if( newval > max ) { newval = max; }
			//flip the stack of the bg colors
			if(percent > 60 && cType == 'select'){ 
				
			}
			snappedPercent = Math.round( newval / max * 100 );
			handle.css('left', percent + '%');
			handle.attr({
					'aria-valuenow': (cType == 'input') ? newval : control.find('option').eq(newval).attr('value'),
					'aria-valuetext': (cType == 'input') ? newval : control.find('option').eq(newval).text(),
					'title': newval
				});
			updateSwitchClass(newval);
			updateControl(newval);
		}
		
		function updateSwitchClass(val){
			if(cType == 'input'){return;}
			if(val == 0){ slider.addClass('ui-slider-switch-a').removeClass('ui-slider-switch-b'); }
			else { slider.addClass('ui-slider-switch-b').removeClass('ui-slider-switch-a'); }
		}
		
		updateSwitchClass(val);
		
		function updateSnap(){
			if(cType == 'select'){
				handle
					.addClass('ui-slider-handle-snapping')
					.css('left', snappedPercent + '%')
					.animationComplete(function(){
						handle.removeClass('ui-slider-handle-snapping');
					});
			}
		}
		
		label.addClass('ui-slider');
		
		control
			.addClass((cType == 'input') ? 'ui-slider-input' : 'ui-slider-switch')
			.keyup(function(e){
				slideUpdate(e, $(this).val() );
			});
					
		slider
			.bind($.support.touch ? "touchstart" : "mousedown", function(event){
				dragging = true;
				if((cType == 'select')){
					val = control[0].selectedIndex;
				}
				slideUpdate(event);
				return false;
			})
			.bind($.support.touch ? "touchmove" : "mousemove", function(event){
				slideUpdate(event);
				return false;
			})
			.bind($.support.touch ? "touchend" : "mouseup", function(event){
				dragging = false;
				if(cType == 'select'){
					if(val == control[0].selectedIndex){
						val = val == 0 ? 1 : 0;
						//tap occurred, but value didn't change. flip it!
						slideUpdate(event,val);
					}
					updateSnap();
				}
				return false;
			})
			.insertAfter(control);
		
		handle
			.css('left', percent + '%')
			.bind('click', function(e){ return false; });	
	});
};
})(jQuery);
	
/*
* jQuery Mobile Framework : "collapsible" plugin (based on code from Filament Group,Inc)
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/ 
(function($){
$.fn.collapsible = function(options){
	return $(this).each(function(){
		var o = $.extend({
			expandCueText: ' click to expand contents',
			collapseCueText: ' click to collapse contents',
			collapsed: $(this).is('[data-state="collapsed"]'),
			heading: '>h1,>h2,>h3,>h4,>h5,>h6,>legend',
			theme: $(this).data('theme'),
			iconTheme: $(this).data('icontheme') || 'd'
		},options);

		//define
		var collapsibleContain = $(this).addClass('ui-collapsible-contain'),
			collapsibleHeading = $(this).find(o.heading).eq(0),
			collapsibleContent = collapsibleContain.wrapInner('<div class="ui-collapsible-content"></div>').find('.ui-collapsible-content');				
		
		//replace collapsibleHeading if it's a legend	
		if(collapsibleHeading.is('legend')){
			collapsibleHeading = $('<div role="heading">'+ collapsibleHeading.html() +'</div>').insertBefore(collapsibleHeading);
			collapsibleHeading.next().remove();
		}	
		
		//drop heading in before content
		collapsibleHeading.insertBefore(collapsibleContent);
		
		//modify markup & attributes
		collapsibleHeading.addClass('ui-collapsible-heading')
			.append('<span class="ui-collapsible-heading-status"></span>')
			.wrapInner('<a href="#" class="ui-collapsible-heading-toggle"></a>')
			.find('a:eq(0)')
			.buttonMarkup({
				shadow: true,
				corners:false,
				iconPos: 'left',
				icon: 'plus',
				theme: o.theme
			})
			.removeClass('ui-btn-corner-all')
			.addClass('ui-corner-all')
			.find('.ui-btn-inner')
			.removeClass('ui-btn-corner-all')
			.addClass('ui-corner-all')
			.find('.ui-icon')
			.removeAttr('class')
			.buttonMarkup({
				shadow: true,
				corners:true,
				iconPos: 'notext',
				icon: 'plus',
				theme: o.iconTheme
			});
		
		//events
		collapsibleContain	
			.bind('collapse', function(){
				collapsibleHeading
					.addClass('ui-collapsible-heading-collapsed')
					.find('.ui-collapsible-heading-status').text(o.expandCueText);
				
				collapsibleHeading.find('.ui-icon').removeClass('ui-icon-minus').addClass('ui-icon-plus');	
				collapsibleContent.addClass('ui-collapsible-content-collapsed').attr('aria-hidden',true);						
				
			})
			.bind('expand', function(){
				collapsibleHeading
					.removeClass('ui-collapsible-heading-collapsed')
					.find('.ui-collapsible-heading-status').text(o.collapseCueText);
				
				collapsibleHeading.find('.ui-icon').removeClass('ui-icon-plus').addClass('ui-icon-minus');	
				collapsibleContent.removeClass('ui-collapsible-content-collapsed').attr('aria-hidden',false);

			})
			.trigger(o.collapsed ? 'collapse' : 'expand');
			
		collapsibleHeading.click(function(){ 
			if( collapsibleHeading.is('.ui-collapsible-heading-collapsed') ){
				collapsibleContain.trigger('expand'); 
			}	
			else {
				collapsibleContain.trigger('collapse'); 
			}
			return false;
		});
			
	});	
};	
})(jQuery);/*
* jQuery Mobile Framework : prototype for "controlgroup" plugin - corner-rounding for groups of buttons, checks, radios, etc
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.controlgroup = function(options){
		
	return $(this).each(function(){
		var o = $.extend({
			direction: $( this ).data( "type" ) || "vertical",
			shadow: false
		},options);
		var groupheading = $(this).find('>legend'),
			flCorners = o.direction == 'horizontal' ? ['ui-corner-left', 'ui-corner-right'] : ['ui-corner-top', 'ui-corner-bottom'],
			type = $(this).find('input:eq(0)').attr('type');
		
		//replace legend with more stylable replacement div	
		if( groupheading.length ){
			$(this).wrapInner('<div class="ui-controlgroup-controls"></div>');	
			$('<div role="heading" class="ui-controlgroup-label">'+ groupheading.html() +'</div>').insertBefore( $(this).children(0) );	
			groupheading.remove();	
		}

		$(this).addClass('ui-corner-all ui-controlgroup ui-controlgroup-'+o.direction);
		
		function flipClasses(els){
			els
				.removeClass('ui-btn-corner-all ui-shadow')
				.eq(0).addClass(flCorners[0])
				.end()
				.filter(':last').addClass(flCorners[1]).addClass('ui-controlgroup-last');
		}
		flipClasses($(this).find('.ui-btn'));
		flipClasses($(this).find('.ui-btn-inner'));
		if(o.shadow){
			$(this).addClass('ui-shadow');
		}
	});	
};
})(jQuery);/*
* jQuery Mobile Framework : prototype for "fieldcontain" plugin - simple class additions to make form row separators
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.fieldcontain = function(options){
	var o = $.extend({
		theme: 'c'
	},options);
	return $(this).addClass('ui-field-contain ui-body ui-br');
};
})(jQuery);/*
* jQuery Mobile Framework : listview plugin
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function( $ ) {

$.widget( "mobile.listview", $.mobile.widget, {
	options: {
		theme: "c",
		countTheme: "c",
		headerTheme: "b",
		dividerTheme: "b",
		splitIcon: "arrow-r",
		splitTheme: "b",
		inset: false
	},
	
	_create: function() {
		var o = this.options
			$list = this.element;
		
		this._createSubPages();
		
		//create listview markup 
		this.element
			.addClass( "ui-listview" )
			.attr( "role", "listbox" )
			.find( "li" )
				.attr("role","option")
				.attr("tabindex","-1")
				.focus(function(){
					$(this).attr("tabindex","0");
				})
				.each(function() {
					var $li = $( this ),
						role = $li.data( "role" ),
						dividertheme = $list.data( "dividertheme" ) || o.dividerTheme;
					if ( $li.is( ":has(img)" ) ) {
						if ($li.is( ":has(img.ui-li-icon)" )){
							$li.addClass( "ui-li-has-icon" );
						}
						else{
							$li.addClass( "ui-li-has-thumb" );
						}
					
					}
					if ( $li.is( ":has(.ui-li-aside)" ) ) {
						var aside = $li.find('.ui-li-aside');
						aside.prependTo(aside.parent()); //shift aside to front for css float
					}
					$li.addClass( "ui-li" );
					
					if( $li.find('a').length ){	
						$li
							.buttonMarkup({
								wrapperEls: "div",
								shadow: false,
								corners: false,
								iconpos: "right",
								icon: $(this).data("icon") || "arrow-r",
								theme: o.theme
							})
							.find( "a" ).eq( 0 )
								.addClass( "ui-link-inherit" );
					}
					else if( role == "list-divider" ){
						$li.addClass( "ui-li-divider ui-btn ui-bar-" + dividertheme ).attr( "role", "heading" );
					}
					else {
						$li.addClass( "ui-li-static ui-btn-up-" + o.theme );
					}	
				})
				.eq(0)
				.attr("tabindex","0");
				
	
		//keyboard events for menu items
		this.element.keydown(function(event){
			//switch logic based on which key was pressed
			switch(event.keyCode){
				//up or left arrow keys
				case 38:
					//if there's a previous option, focus it
					if( $(event.target).closest('li').prev().length  ){
						$(event.target).blur().attr("tabindex","-1").closest('li').prev().find('a').eq(0).focus();
					}	
					//prevent native scroll
					return false;
				break;
				//down or right arrow keys
				case 40:
				
					//if there's a next option, focus it
					if( $(event.target).closest('li').next().length ){
						$(event.target).blur().attr("tabindex","-1").closest('li').next().find('a').eq(0).focus();
					}	
					//prevent native scroll
					return false;
				break;
				case 39:
					if( $(event.target).closest('li').find('a.ui-li-link-alt').length ){
						$(event.target).blur().closest('li').find('a.ui-li-link-alt').eq(0).focus();
					}
					return false;
				break;
				case 37:
					if( $(event.target).closest('li').find('a.ui-link-inherit').length ){
						$(event.target).blur().closest('li').find('a.ui-link-inherit').eq(0).focus();
					}
					return false;
				break;
				//if enter or space is pressed, trigger click
				case 13:
				case 32:
					 $(event.target).trigger('click'); //should trigger select
					 return false;
				break;	
			}
		});	

		if ( o.inset ) {
			this.element
				.addClass( "ui-listview-inset" )
				.controlgroup({ shadow: true });
		}
		
		this.element
			.find( "li" ).each(function() {
				//for split buttons
				var $splitBtn = $( this ).find( "a" ).eq( 1 );
				if( $splitBtn.length ){ $(this).addClass('ui-li-has-alt'); }
				 $splitBtn.each(function() {
					var a = $( this );
					a
						.attr( "title", $( this ).text() )
						.addClass( "ui-li-link-alt" )
						.empty()
						.buttonMarkup({
							shadow: false,
							corners: false,
							theme: o.theme,
							icon: false,
							iconpos: false
						})
						.find( ".ui-btn-inner" )
						.append( $( "<span>" ).buttonMarkup({
							shadow: true,
							corners: true,
							theme: $list.data('splittheme') || a.data('theme') || o.splitTheme,
							iconpos: "notext",
							icon: $list.data('spliticon') || a.data('icon') ||  o.splitIcon
						} ) );
					
					//fix corners
					if ( o.inset ) {
						var closestLi = $( this ).closest( "li" );
						if ( closestLi.is( "li:first-child" ) ) {
							$( this ).addClass( "ui-corner-tr" );
						} else if ( closestLi.is( "li:last-child" ) ) {
							$( this ).addClass( "ui-corner-br" );
						}
					}
				});
			})
			.find( "img")
				.addClass( "ui-li-thumb" );
		
		if ( o.inset ) {
			
			//remove corners before or after dividers
			var sides = ['top','bottom'];
			$.each( sides, function( i ){
				var side = sides[ i ];
				$list.find( ".ui-corner-" + side ).each(function(){
					if( $(this).parents('li')[ i == 0 ? 'prev' : 'next' ]( ".ui-li-divider" ).length ){
						$(this).removeClass( "ui-corner-" + side );
					}
				});
			});			
		
			this.element
				.find( "img" )
					.filter( "li:first-child img" )
						.addClass( "ui-corner-tl" )
					.end()
					.filter( "li:last-child img" )
						.addClass( "ui-corner-bl" )
					.end();
		}
		
		this.element
			.find( ".ui-li-count" )
				.addClass( "ui-btn-up-" + ($list.data( "counttheme" ) || o.countTheme) + " ui-btn-corner-all" )
			.end()
			.find( ":header" )
				.addClass( "ui-li-heading" )
			.end()
			.find( "p,ul,dl" )
				.addClass( "ui-li-desc" );
		
		this._numberItems();
				
		//tapping the whole LI triggers ajaxClick on the first link
		this.element.find( "li:has(a)" ).live( "tap", function(event) {
			if( !$(event.target).closest('a').length ){
				$( this ).find( "a:first" ).trigger('click');
				return false;
			}
		});
	},
	
	_createSubPages: function() {
		var parentId = this.element.closest( ".ui-page" ).attr( "id" ),
			o = this.options,
			parentList = this.element;
		$( this.element.find( "ul,ol" ).get().reverse() ).each(function( i ) {
			var list = $( this ),
				parent = list.parent(),
				title = parent.contents()[ 0 ].nodeValue.split("\n")[0],
				id = parentId + "&" + $.mobile.subPageUrlKey + "=" + $.mobile.idStringEscape(title + " " + i),
				theme = list.data( "theme" ) || o.theme,
				countTheme = list.data( "counttheme" ) || parentList.data( "counttheme" ) || o.countTheme,
				newPage = list.wrap( "<div data-role='page'><div data-role='content'></div></div>" )
							.parent()
								.before( "<div data-role='header' data-theme='" + o.headerTheme + "'><div class='ui-title'>" + title + "</div></div>" )
								.parent()
									.attr({
										id: id,
										"data-theme": theme,
										"data-count-theme": countTheme
									})
									.appendTo( "body" );
									
				newPage.page();		
			
			parent.html( "<a href='#" + id + "'>" + title + "</a>" );
		}).listview();
	},
	
	// JS fallback for auto-numbering for OL elements
	_numberItems: function() {
		if ( $.support.cssPseudoElement || !this.element.is( "ol" ) ) {
			return;
		}
		var counter = 1;
		this.element.find( ".ui-li-dec" ).remove();
		this.element.find( "li:visible" ).each(function() {
			if( $( this ).is( ".ui-li-divider" ) ) {
				//reset counter when a divider heading is encountered
				counter = 1;
			} else { 
				$( this )
					.find( ".ui-link-inherit:first" )
					.addClass( "ui-li-jsnumbering" )
					.prepend( "<span class='ui-li-dec'>" + (counter++) + ". </span>" );
			}
		});
	}
});

})( jQuery );
(function( $ ) {

$.mobile.listview.prototype.options.filter = false;

$( ":mobile-listview" ).live( "listviewcreate", function() {
	var list = $( this ),
		listview = list.data( "listview" );
	if ( !listview.options.filter ) {
		return;
	}

	var wrapper = $( "<form>", { "class": "ui-listview-filter ui-bar-c", "role": "search" } ),
		
		search = $( "<input>", {
				placeholder: "Filter results...",
				"data-type": "search"
			})
			.bind( "keyup change", function() {
				var val = this.value.toLowerCase();;
				list.children().show();
				if ( val ) {
					list.children().filter(function() {
						return $( this ).text().toLowerCase().indexOf( val ) === -1;
					}).hide();
				}
				
				listview._numberItems();
			})
			.appendTo( wrapper )
			.customTextInput();
	
	wrapper.insertBefore( list );
});

})( jQuery );
/*
* jQuery Mobile Framework : prototype for "dialog" plugin.
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.dialog = function(options){
	return $(this).each(function(){		
		$(this)
			//add ARIA role
			.attr("role","dialog")
			.addClass('ui-page ui-dialog ui-body-a')
			.find('[data-role=header]')
			.addClass('ui-corner-top ui-overlay-shadow')
			.end()
			.find('.ui-content,[data-role=footer]')
				.last()
				.addClass('ui-corner-bottom ui-overlay-shadow');
	});
};
})(jQuery);/*
* jQuery Mobile Framework : prototype for "navbar" plugin
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/
(function($){
$.fn.navbar = function(settings){
	return $(this).each(function(){ 

		var o = $.extend({
			iconpos: $(this).data('iconpos') || 'top',
			transition: $(this).data('transition') || 'slideup'
		},settings);
		
		//wrap it with footer classes
		var $navbar = $(this).addClass('ui-navbar'),
			numTabs = $navbar.find('li').length,
			moreIcon = $navbar.find('a[data-icon]').length ? 'arrow-r' : null;
			
			if( moreIcon == null ){ 
				o.iconpos = null; 
				$navbar.add( $navbar.children(0) ).addClass('ui-navbar-noicons');
			}
			
			$navbar
				//add ARIA role
				.attr("role","navigation")
				.find('ul')
				.grid({grid: numTabs > 2 ? 'b' : 'a'});		
		
		$navbar
			.find('ul a')
			.buttonMarkup({corners: false, shadow:false, iconpos: o.iconpos})
			.bind('tap',function(){
				//NOTE: we'll need to find a way to highlight an active tab at load as well
				$navbar.find('.ui-btn-active').removeClass('ui-btn-active');
				$(this).addClass('ui-btn-active');
			});

	});
};	
})(jQuery);/*
* jQuery Mobile Framework : plugin for creating grids
* Copyright (c) jQuery Project
* Dual licensed under the MIT (MIT-LICENSE.txt) and GPL (GPL-LICENSE.txt) licenses.
* Note: Code is in draft form and is subject to change 
*/ 
(function($){
$.fn.grid = function(options){
	return $(this).each(function(){
		var o = $.extend({
			grid: 'a'
		},options);
		
		$(this).addClass('ui-grid-' + o.grid);
			
		var $kids = $(this).children();
			iterator = o.grid == 'a' ? 2 : 3;
		
			$kids.filter(':nth-child(' + iterator + 'n+1)').addClass('ui-block-a');
			$kids.filter(':nth-child(' + iterator + 'n+2)').addClass('ui-block-b');
			
		if(iterator == 3){	
			$kids.filter(':nth-child(3n+3)').addClass('ui-block-c');
		}			
	});	
};
})(jQuery);

/*!
 * jQuery Mobile
 * http://jquerymobile.com/
 *
 * Copyright 2010, jQuery Project
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 */
(function( jQuery, window, undefined ) {
	//some critical feature tests should be placed here.
	//if we're missing support for any of these, then we're a C-grade browser
	//to-do: see if we need more qualifiers here.
	if ( !jQuery.support.mediaquery ) {
		return;
	}	
	
	//these properties should be made easy to override externally
	jQuery.mobile = {};
	
	jQuery.extend(jQuery.mobile, {
		subPageUrlKey: 'ui-page', //define the key used in urls for sub-pages. Defaults to &ui-page=
		degradeInputs: {
			color: true,
			date: true,
			datetime: true,
			"datetime-local": true,
			email: true,
			month: true,
			number: true,
			range: true,
			search: true,
			tel: true,
			time: true,
			url: true,
			week: true
		},
		addBackBtn: true
	});

	var $window = jQuery(window),
		$html = jQuery('html'),
		$head = jQuery('head'),
		$body,
		$loader = jQuery('<div class="ui-loader ui-body-a ui-corner-all"><span class="ui-icon ui-icon-loading spin"></span><h1>loading</h1></div>'),
		startPage,
		startPageId = 'ui-page-start',
		activePageClass = 'ui-page-active',
		pageTransition,
		transitions = 'slide slideup slidedown pop flip fade',
		transitionDuration = 350,
		backBtnText = "Back",
		urlStack = [ {
			url: location.hash.replace( /^#/, "" ),
			transition: "slide"
		} ],
		focusable = "[tabindex],a,button:visible,select:visible,input",
		nextPageRole = null;
	
	// TODO: don't expose (temporary during code reorg)
	$.mobile.urlStack = urlStack;
	
	//consistent string escaping for urls and IDs
	function idStringEscape(str){
		return str.replace(/[^a-zA-Z0-9]/, '-');
	}
	
	$.mobile.idStringEscape = idStringEscape;
	
	// hide address bar
	function hideBrowserChrome() {
		// prevent scrollstart and scrollstop events
		jQuery.event.special.scrollstart.enabled = false;
		setTimeout(function() {
			window.scrollTo( 0, 0 );
		},0);	
		setTimeout(function() {
			jQuery.event.special.scrollstart.enabled = true;
		}, 150 );
	}
	
	function getBaseURL(){
	    var newBaseURL = location.hash.replace(/#/,'').split('/');
		if(newBaseURL.length && /[.|&]/.test(newBaseURL[newBaseURL.length-1]) ){
			newBaseURL.pop();	
		}
		newBaseURL = newBaseURL.join('/');
		if(newBaseURL !== "" && newBaseURL.charAt(newBaseURL.length-1) !== '/'){  newBaseURL += '/'; }
		return newBaseURL;
	}
	
	function setBaseURL(){
		//set base url for new page assets
		$('#ui-base').attr('href', getBaseURL());
	}
	
	function resetBaseURL(){
		$('#ui-base').attr('href', location.pathname);
	}
	
	
	// send a link through hash tracking
	jQuery.fn.ajaxClick = function() {
		var href = jQuery( this ).attr( "href" );
		pageTransition = jQuery( this ).data( "transition" ) || "slide";
		nextPageRole = jQuery( this ).attr( "data-rel" );
		  	
		//find new base for url building
		var newBaseURL = getBaseURL();
		
		//if href is absolute but local, or a local ID, no base needed
		if( /^\//.test(href) || (/https?:\/\//.test(href) && !!(href).match(location.hostname)) || /^#/.test(href) ){
			newBaseURL = '';
		}
		
		// set href to relative path using baseURL and
		if( !/https?:\/\//.test(href) ){
			href = newBaseURL + href;
		}
						
		//if it's a non-local-anchor and Ajax is not supported, or if it's an external link, go to page without ajax
		if ( ( /^[^#]/.test(href) && !jQuery.support.ajax ) || ( /https?:\/\//.test(href) && !!!href.match(location.hostname) ) ) {
			location = href
		}
		else{
			// let the hashchange event handler take care of requesting the page via ajax
			location.hash = href;
		}
		return this;
	};
	
	// ajaxify all navigable links
	jQuery( "a:not([href=#]):not([target]):not([rel=external])" ).live( "click", function(event) {
		jQuery( this ).ajaxClick();
		return false;
	});
	
	// turn on/off page loading message.
	function pageLoading( done ) {
		if ( done ) {
			$html.removeClass( "ui-loading" );
		} else {
			$loader.appendTo('body').css({top: $(window).scrollTop() + 75});
			$html.addClass( "ui-loading" );
		}
	};
	
	//for directing focus to the page title, or otherwise first focusable element
	function reFocus(page){
		var pageTitle = page.find( ".ui-title:eq(0)" );
		if( pageTitle.length ){
			pageTitle.focus();
		}
		else{
			page.find( focusable ).eq(0).focus();
		}
	}
	
	// transition between pages - based on transitions from jQtouch
	function changePage( from, to, transition, back ) {
		jQuery( document.activeElement ).blur();
		
		
		//trigger before show/hide events
		from.trigger("beforepagehide", {nextPage: to});
		to.trigger("beforepageshow", {prevPage: from});
		
		function loadComplete(){
			pageLoading( true );
			//trigger show/hide events, allow preventing focus change through return false		
			if( from.trigger("pagehide", {nextPage: to}) !== false && to.trigger("pageshow", {prevPage: from}) !== false ){
				reFocus( to );
			}
		}
		
		if(transition){		
			// animate in / out
			from.addClass( transition + " out " + ( back ? "reverse" : "" ) );
			to.addClass( activePageClass + " " + transition +
				" in " + ( back ? "reverse" : "" ) );
			
			// callback - remove classes, etc
			to.animationComplete(function() {
				from.add( to ).removeClass(" out in reverse " + transitions );
				from.removeClass( activePageClass );
				loadComplete();
			});
		}
		else{
			from.removeClass( activePageClass );
			to.addClass( activePageClass );
			loadComplete();
		}
	};
	
	jQuery(function() {
		var preventLoad = false;

		$body = jQuery( "body" );
		pageLoading();
		
		// needs to be bound at domready (for IE6)
		// find or load content, make it active
		$window.bind( "hashchange", function(e, extras) {
			if ( preventLoad ) {
				preventLoad = false;
				return;
			}

			var url = location.hash.replace( /^#/, "" ),
				stackLength = urlStack.length,
				// pageTransition only exists if the user clicked a link
				back = !pageTransition && stackLength > 1 &&
					urlStack[ stackLength - 2 ].url === url,
				transition = (extras && extras.manuallyTriggered) ? false : pageTransition || "slide",
				fileUrl = url;
			pageTransition = undefined;
			
			//reset base to pathname for new request
			resetBaseURL();
			
			// if the new href is the same as the previous one
			if ( back ) {
				transition = urlStack.pop().transition;
			} else {
				urlStack.push({ url: url, transition: transition });
			}
			
			//function for setting role of next page
			function setPageRole( newPage ) {
				if ( nextPageRole ) {
					newPage.attr( "data-role", nextPageRole );
					nextPageRole = undefined;
				}
			}
			
			//wrap page and transfer data-attrs if it has an ID
			function wrapNewPage( newPage ){
				var copyAttrs = ['data-role', 'data-theme', 'data-fullscreen'], //TODO: more page-level attrs?
					wrapper = newPage.wrap( "<div>" ).parent();
					
				$.each(copyAttrs,function(i){
					if( newPage.attr( copyAttrs[ i ] ) ){
						wrapper.attr( copyAttrs[ i ], newPage.attr( copyAttrs[ i ] ) );
						newPage.removeAttr( copyAttrs[ i ] );
					}
				});
				return wrapper;
			}
			
			if ( url ) {
				var active = jQuery( ".ui-page-active" );

				// see if content is present already
				var localDiv = jQuery( "[id='" + url + "']" );
				if ( localDiv.length ) {
					if ( localDiv.is( "[data-role]" ) ) {
						setPageRole( localDiv );
					}
					setBaseURL();
					localDiv.page();
					changePage( active, localDiv, transition, back );
					
				} else { //ajax it in
					pageLoading();

					if ( url.match( '&' + jQuery.mobile.subPageUrlKey ) ) {
						fileUrl = url.split( '&' + jQuery.mobile.subPageUrlKey )[0];
					}

					$.ajax({
						url: fileUrl,
						success: function( html ) {
							var page = jQuery("<div>" + html + "</div>").find('[data-role="page"]');

							if ( page.attr('id') ) {
								page = wrapNewPage( page );
							}

							page
								.attr( "id", fileUrl )
								.appendTo( "body" );

							setPageRole( page );
							page.page();
							changePage( active, page, transition, back );
						},
						error: function() {
							pageLoading( true );

							jQuery("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all'><h1>Error Loading Page</h1></div>")
								.css({ "display": "block", "opacity": 0.96 })
								.appendTo("body")
								.delay( 800 )
								.fadeOut( 400, function(){
									$(this).remove();
								});

							preventLoad = true;
							history.back();
						}
					});
						
					setBaseURL();
				}
			} else {
				// either we've backed up to the root page url
				// or it's the first page load with no hash present
				var currentPage = jQuery( ".ui-page-active" );
				if ( currentPage.length && !startPage.is( ".ui-page-active" ) ) {
					changePage( currentPage, startPage, transition, back );
				} else {
					startPage.trigger("beforepageshow", {prevPage: $('')});
					startPage.addClass( activePageClass );
					pageLoading( true );
					
					if( startPage.trigger("pageshow", {prevPage: $('')}) !== false ){
						reFocus(startPage);
					}
				}
			}
		});
	});	
	
	//add orientation class on flip/resize.
	$window.bind( "orientationchange", function( event, data ) {
		$html.removeClass( "portrait landscape" ).addClass( data.orientation );
	});
	
	//add mobile, loading classes to doc
	$html.addClass('ui-mobile');
	
	//insert mobile meta - these will need to be configurable somehow.
	$head.prepend(
		'<meta name="viewport" content="width=device-width, minimum-scale=1, maximum-scale=1" />' +
		'<base  href="" id="ui-base" />'
	);
    
    //set base href to pathname
    resetBaseURL();    
	
	//incomplete fallback to workaround lack of animation callbacks. 
	//should this be extended into a full special event?
	// note: Expects CSS animations use transitionDuration (350ms)
	jQuery.fn.animationComplete = function(callback){
		if(jQuery.support.WebKitAnimationEvent){
			return jQuery(this).one('webkitAnimationEnd', callback); //check out transitionEnd (opera per Paul's request)
		}
		else{
			setTimeout(callback, transitionDuration);
		}
	};	
	
	jQuery.extend({
		pageLoading: pageLoading,
		changePage: changePage,
		hideBrowserChrome: hideBrowserChrome
	});

	//dom-ready
	jQuery(function(){
		
		//set up active page
		startPage = jQuery('[data-role="page"]:first');
		
		//make sure it has an ID - for finding it later
		if(!startPage.attr('id')){ 
			startPage.attr('id', startPageId); 
		}
		
		//initialize all pages present
		jQuery('[data-role="page"]').page();
		
		//trigger a new hashchange, hash or not
		$window.trigger( "hashchange", { manuallyTriggered: true } );
		
		//update orientation 
		$html.addClass( jQuery.event.special.orientationchange.orientation( $window ) );
	});
	
	$window.load(hideBrowserChrome);
	
})( jQuery, this );