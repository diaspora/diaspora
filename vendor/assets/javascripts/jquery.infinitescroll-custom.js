/*!
// Infinite Scroll jQuery plugin
// copyright Paul Irish, licensed GPL & MIT
// version 2.0b1.110420

// home and docs: http://www.infinite-scroll.com
// Modified by Diaspora:
// A few callbacks were made options and generateInstanceID was make jquery 162 compatible
*/

; (function ($) {

    /* Define 'infinitescroll' function
    ---------------------------------------------------*/

    $.fn.infinitescroll = function infscr(options, callback) {

        // grab each selector option and see if any fail.
        function areSelectorsValid(opts) {
            var debug = $.fn.infinitescroll._debug;
            for (var key in opts) {
                if (key.indexOf && key.indexOf('Selector') > -1 && $(opts[key]).length === 0) {
                    debug('Your ' + key + ' found no elements.');
                    return false;
                }
                return true;
            }
        }


        // find the number to increment in the path.
        function determinePath(path) {

        	if ($.isFunction(opts.pathParse)) {

        		debug('pathParse');
        		return [path];

        	} else if (path.match(/^(.*?)\b2\b(.*?$)/)) {
        		path = path.match(/^(.*?)\b2\b(.*?$)/).slice(1);

        	// if there is any 2 in the url at all.
        	} else if (path.match(/^(.*?)2(.*?$)/)) {

	        	// page= is used in django:
	        	// http://www.infinite-scroll.com/changelog/comment-page-1/#comment-127
	        	if (path.match(/^(.*?page=)2(\/.*|$)/)) {
	        		path = path.match(/^(.*?page=)2(\/.*|$)/).slice(1);
	        		return path;
	        	}

	        	path = path.match(/^(.*?)2(.*?$)/).slice(1);

	        } else {

	        	// page= is used in drupal too but second page is page=1 not page=2:
	        	// thx Jerod Fritz, vladikoff
	        	if (path.match(/^(.*?page=)1(\/.*|$)/)) {
	        		path = path.match(/^(.*?page=)1(\/.*|$)/).slice(1);
	        		return path;
	        	} else {
	        		debug('Sorry, we couldn\'t parse your Next (Previous Posts) URL. Verify your the css selector points to the correct A tag. If you still get this error: yell, scream, and kindly ask for help at infinite-scroll.com.');
	        		props.isInvalidPage = true;  //prevent it from running on this page.
	        	}
	        }
	        debug('determinePath',path);
	        return path;
		}


        // Calculate internal height (used for local scroll)
        function hiddenHeight(element) {
            var height = 0;
            $(element).children().each(function () {
                height = height + $(this).outerHeight(false);
            });
            return height;
        }


        //Generate InstanceID based on random data (to give consistent but different ID's)
        function generateInstanceID(element) {
            var $element = $(element)
            var number = $element.length + $element.html().length
            if($element.attr("class") !== undefined){
              number += $element.attr("class").length
            }
            if($element.attr("id") !== undefined){
              number += $element.attr("id").length
            }
            opts.infid = number;
        }


        // if options is a string, use as a command
        if (typeof options=='string') {

        	var command = options,
        		argument = callback,
        		validCommand = (command == 'pause' || command == 'destroy' || command == 'retrieve' || command == 'binding'),
        		debug = $.fn.infinitescroll._debug;

        	argument = argument || null;
        	command = (validCommand) ? $.fn.infinitescroll[command](argument) : debug('Invalid command');

        	return false;
        }


        // lets get started.
        var opts = $.infinitescroll.opts = $.extend({}, $.infinitescroll.defaults, options),
        	props = $.infinitescroll, // shorthand
        	innerContainerHeight, box, frag, desturl, pause, error, errorStatus, method, result;
        	callback = $.fn.infinitescroll._callback = callback || function () { },
        	debug = $.fn.infinitescroll._debug,
        	error = $.fn.infinitescroll._error,
        	pause = $.fn.infinitescroll.pause,
        	destroy = $.fn.infinitescroll.destroy,
        	binding = $.fn.infinitescroll.binding;


        // if selectors from opts aren't valid, return false
        if (!areSelectorsValid(opts)) { return false; }


        opts.container = opts.container || document.documentElement;


        // contentSelector we'll use for our ajax call
        opts.contentSelector = opts.contentSelector || this;

        // Generate unique instance ID
        opts.infid = (opts.infid == 0) ? generateInstanceID(opts.contentSelector) : opts.infid;

        // loadMsgSelector - if we want to place the load message in a specific selector, defaulted to the contentSelector
        opts.loadMsgSelector = opts.loadMsgSelector || opts.contentSelector;


        // get the relative URL - everything past the domain name.
        var relurl = /(.*?\/\/).*?(\/.*)/,
        	path = $(opts.nextSelector).attr('href');

        if (!path) { debug('Navigation selector not found'); return; }

        // set the path to be a relative URL from root.
        opts.path = determinePath(path);


        // define loading msg
        props.loadingMsg = $('<div id="infscr-loading" style="text-align: center;"><img alt="Loading..." src="' +

                                  opts.loadingImg + '" /><div>' + opts.loadingText + '</div></div>');
        // preload the image
        (new Image()).src = opts.loadingImg;


        //Check if its HTML (window scroll) and set innerContainerHeight
        opts.binder = (opts.container.nodeName == "HTML") ? $(window) : $(opts.container);
        innerContainerHeight = (opts.container.nodeName == "HTML") ? $(document).height() : innerContainerHeight = hiddenHeight(opts.container);
        debug('Scrolling in: ',(opts.container.nodeName == "HTML") ? 'window' : opts.container);

        // distance from nav links to bottom
        // computed as: height of the document + top offset of container - top offset of nav link
        opts.pixelsFromNavToBottom = innerContainerHeight +
                                     (opts.container == document.documentElement ? 0 : $(opts.container).offset().top) -
                                     $(opts.navSelector).offset().top;


        // set up our bindings
        // bind scroll handler to element (if its a local scroll) or window
        binding('bind');
        opts.binder.trigger('smartscroll.infscr.' + opts.infid); // trigger the event, in case it's a short page

        return this;

    }  // end of $.fn.infinitescroll()


    /* Defaults and read-only properties object
    ---------------------------------------------------*/

    $.infinitescroll = {
        defaults: {
            debug: false,
            binder: $(window),
            preload: false,
            nextSelector: "div.navigation a:first",
            loadingImg: "http://www.infinite-scroll.com/loading.gif",
            loadingText: "<em>Loading the next set of posts...</em>",
            donetext: "<em>Congratulations, you've reached the end of the internet.</em>",
            navSelector: "div.navigation",
            contentSelector: null,           // not really a selector. :) it's whatever the method was called on..
            loadMsgSelector: null,
            loadingMsgRevealSpeed: 'fast', // controls how fast you want the loading message to come in, ex: 'fast', 'slow', 200 (milliseconds)
            extraScrollPx: 150,
            itemSelector: "div.post",
            animate: false,
            pathParse: undefined,
            dataType: 'html',
            appendCallback: true,
            bufferPx: 40,
            orientation: 'height',
            errorCallback: function () { },
            currPage: 1,
            infid: 0, //Instance ID (Generated at setup)
            isDuringAjax: false,
            isInvalidPage: false,
            isDestroyed: false,
            isDone: false,  // for when it goes all the way through the archive.
            isPaused: false,
            container: undefined, //If left undefined uses window scroll, set as container for local scroll
            pixelsFromNavToBottom: undefined,
            path: undefined
        },
        loadingImg: undefined,
        loadingMsg: undefined,
        currDOMChunk: null  // defined in setup()'s load()
    };


    /* Methods + Commands
    ---------------------------------------------------*/

    // Console log wrapper.
    $.fn.infinitescroll._debug = function infscr_debug() {
        if ($.infinitescroll.opts.debug) {
        	return window.console && console.log.call(console, arguments);
        }
    }


    // shortcut function for...getting shortcuts
    $.fn.infinitescroll._shorthand = function infscr_shorthand() {

    	// someone should write this, and it would rule

    };


    // Near Bottom (isNearBottom)
    $.fn.infinitescroll._nearbottom = function infscr_nearbottom() {

        // replace with shorthand function
        var opts = $.infinitescroll.opts,
        	debug = $.fn.infinitescroll._debug,
        	hiddenHeight = $.fn.infinitescroll._hiddenheight;

        // distance remaining in the scroll
        // computed as: document height - distance already scroll - viewport height - buffer

        if (opts.container.nodeName == "HTML") {
            var pixelsFromWindowBottomToBottom = 0
            + $(document).height()
            // have to do this bs because safari doesnt report a scrollTop on the html element
            - ($(opts.container).scrollTop() || $(opts.container.ownerDocument.body).scrollTop())
            - $(window).height();
        }
        else {
            var pixelsFromWindowBottomToBottom = 0
            + hiddenHeight(opts.container) - $(opts.container).scrollTop() - $(opts.container).height();

        }

        debug('math:', pixelsFromWindowBottomToBottom, opts.pixelsFromNavToBottom);

        // if distance remaining in the scroll (including buffer) is less than the orignal nav to bottom....
        return (pixelsFromWindowBottomToBottom - opts.bufferPx < opts.pixelsFromNavToBottom);

    }


    // Setup function (infscrSetup)
    $.fn.infinitescroll._setup = function infscr_setup() {

    	// replace with shorthand function
    	var props = $.infinitescroll,
    		opts = $.infinitescroll.opts,
    		isNearBottom = $.fn.infinitescroll._nearbottom,
    		kickOffAjax = $.fn.infinitescroll.retrieve;

    	if (opts.isDuringAjax || opts.isInvalidPage || opts.isDone || opts.isDestroyed || opts.isPaused) return;

    	if (!isNearBottom(opts, props)) return;

    	kickOffAjax();

    };


    // Ajax function (kickOffAjax)
    $.fn.infinitescroll.retrieve = function infscr_retrieve() {

    	// replace with shorthand function
    	var props = $.infinitescroll,
    		opts = props.opts,
    		debug = $.fn.infinitescroll._debug,
    		loadCallback = $.fn.infinitescroll._loadcallback,
    		error = $.fn.infinitescroll._error,
    		path = opts.path, // get this
    		box, frag, desturl, method, condition;


    	// we dont want to fire the ajax multiple times
        opts.isDuringAjax = true;


        // show the loading message quickly
        // then hide the previous/next links after we're
        // sure the loading message was visible
        props.loadingMsg.appendTo(opts.loadMsgSelector).show();

          $(opts.navSelector).hide();

          // increment the URL bit. e.g. /page/3/
          opts.currPage++;

          debug('heading into ajax', path);

          // if we're dealing with a table we can't use DIVs
          box = $(opts.contentSelector).is('table') ? $('<tbody/>') : $('<div/>');


          // INSERT DEBUG ERROR FOR invalid desturl
          desturl = ($.isFunction(opts.pathParse)) ? opts.pathParse(path.join('2'), opts.currPage) : desturl = path.join(opts.currPage);
          // desturl = path.join(opts.currPage);

          // create switch parameter for append / callback
          // MAKE SURE CALLBACK EXISTS???
          method = (opts.dataType == 'html' || opts.dataType == 'json') ? opts.dataType : 'html+callback';
          if (opts.appendCallback && opts.dataType == 'html') method += '+callback';

          switch (method) {

            case 'html+callback':

              debug('Using HTML via .load() method');
              box.load(desturl + ' ' + opts.itemSelector, null, function(jqXHR,textStatus) {
                loadCallback(box,jqXHR.responseText);
              });

            break;

            case 'html':
            case 'json':

              debug('Using '+(method.toUpperCase())+' via $.ajax() method');
              $.ajax({
                // params
                url: desturl,
                dataType: opts.dataType,
                complete: function _infscrAjax(jqXHR,textStatus) {
                  condition = (typeof(jqXHR.isResolved) !== 'undefined') ? (jqXHR.isResolved()) : (textStatus === "success" || textStatus === "notmodified");
                  (condition) ? loadCallback(box,jqXHR.responseText) : error([404]);
                }
              });

            break;

          }
    };


    // Load callback
    $.fn.infinitescroll._loadcallback = function infscr_loadcallback(box,data) {

    	// replace with shorthand function
    	var props = $.infinitescroll,
    		opts = $.infinitescroll.opts,
    		error = $.fn.infinitescroll._error,
    		showDoneMsg = $.fn.infinitescroll._donemsg,
    		callback = $.fn.infinitescroll._callback, // GLOBAL OBJECT FOR CALLBACK
    		result, frag;

    	result = (opts.isDone) ? 'done' : (!opts.appendCallback) ? 'no-append' : 'append';

        switch (result) {

        	case 'done':

            	showDoneMsg();
                return false;

            break;

            case 'no-append':

            	if (opts.dataType == 'html') {
            		data = '<div>'+data+'</div>';
            		data = $(data).find(opts.itemSelector);
            	};

            break;

            case 'append':

            	var children = box.children();

            	// if it didn't return anything
                if (children.length == 0 || children.hasClass('error404')) {
                    // trigger a 404 error so we can quit.
                    return error([404]);
                }


                // use a documentFragment because it works when content is going into a table or UL
                frag = document.createDocumentFragment();
                while (box[0].firstChild) {
                    frag.appendChild(box[0].firstChild);
                }

                $(opts.contentSelector)[0].appendChild(frag);
                // previously, we would pass in the new DOM element as context for the callback
                // however we're now using a documentfragment, which doesnt havent parents or children,
                // so the context is the contentContainer guy, and we pass in an array
                //   of the elements collected as the first argument.

                data = children.get();


            break;

        }

        // fadeout currently makes the <em>'d text ugly in IE6
        props.loadingMsg.hide();


        // smooth scroll to ease in the new content
        if (opts.animate) {
            var scrollTo = $(window).scrollTop() + $('#infscr-loading').height() + opts.extraScrollPx + 'px';
            $('html,body').animate({ scrollTop: scrollTo }, 800, function () { opts.isDuringAjax = false; });
        }

        if (!opts.animate) opts.isDuringAjax = false; // once the call is done, we can allow it again.

        callback.call($(opts.contentSelector)[0], data);

    };


    // Show done message.
    $.fn.infinitescroll._donemsg = function infscr_donemsg() {

    	// replace with shorthand function
    	var props = $.infinitescroll,
    		opts = $.infinitescroll.opts;

    	props.loadingMsg
    		.find('img')
    		.hide()
    		.parent()
    		.find('div').html(opts.donetext).animate({ opacity: 1 }, 2000, function () {
	    		$(this).parent().fadeOut('normal');
	    	});

        // user provided callback when done
        opts.errorCallback();
    }


    // Pause function
    $.fn.infinitescroll.pause = function infscr_pause(pause) {

        // if pauseValue is not 'pause' or 'resume', toggle it's value
        var debug = $.fn.infinitescroll._debug,
        	opts = $.infinitescroll.opts;

        if (pause !== 'pause' && pause !== 'resume' && pause !== 'toggle' && pause !== null) {
        	debug('Invalid argument. Toggling pause value instead');
        };

        pause = (pause && (pause == 'pause' || pause == 'resume')) ? pause : 'toggle';

        switch (pause) {
            case 'pause':
                opts.isPaused = true;
            break;

            case 'resume':
                opts.isPaused = false;
            break;

            case 'toggle':
                opts.isPaused = !opts.isPaused;
            break;
        }

        debug('Paused',opts.isPaused);
        return false;
    }


    // Error function
    $.fn.infinitescroll._error = function infscr_error(xhr) {

        // replace with shorthand function
        var opts = $.infinitescroll.opts,
        	binder = (opts.container.nodeName == "HTML") ? $(window) : $(opts.container),
        	debug = $.fn.infinitescroll._debug,
        	showDoneMsg = $.fn.infinitescroll._donemsg,
        	error = (!opts.isDone && xhr == 404) ? 'end' : (opts.isDestroyed && xhr == 302) ? 'destroy' : 'unknown';

        switch (error) {

        	case 'end':

        		// die if we're out of pages.
                debug('Page not found. Self-destructing...');
                showDoneMsg();
                opts.isDone = true;
                opts.currPage = 1; // if you need to go back to this instance
                opts.isPaused = false;
                binder.unbind('smartscroll.infscr.' + opts.infid);

        	break;

        	case 'destroy':

        		// die if destroyed.
                debug('Destroyed. Going to next instance...');
                opts.isDone = true;
                opts.currPage = 1; // if you need to go back to this instance
                opts.isPaused = false;
                binder.unbind('smartscroll.infscr.' + opts.infid);

        	break;

        	case 'unknown':

        		// unknown error.
                debug('Unknown Error. WHAT DID YOU DO?!...');
                showDoneMsg();
                opts.isDone = true;
                opts.currPage = 1; // if you need to go back to this instance
                binder.unbind('smartscroll.infscr.' + opts.infid);

        	break;

        }

    }


    // Destroy current instance of the plugin
    $.fn.infinitescroll.destroy = function infscr_destroy() {

        // replace with shorthand function
        var opts = $.infinitescroll.opts,
        	error = $.fn.infinitescroll._error;

        opts.isDestroyed = true;
        return error([302]);

    }


    // Scroll binding + unbinding
    $.fn.infinitescroll.binding = function infscr_binding(binding) {

        // replace with shorthand function
        var opts = $.infinitescroll.opts,
        	setup = $.fn.infinitescroll._setup,
        	error = $.fn.infinitescroll._error,
        	debug = $.fn.infinitescroll._debug;

        switch(binding) {

        	case 'bind':
        		opts.binder.bind('smartscroll.infscr.'+opts.infid, setup);
        	break;

        	case 'unbind':
        		opts.binder.unbind('smartscroll.infscr.'+opts.infid);
        	break;

        }

        debug('Binding',binding);
        return false;

    }


    /*
	* smartscroll: debounced scroll event for jQuery *
	* https://github.com/lukeshumard/smartscroll
	* Based on smartresize by @louis_remi: https://github.com/lrbabe/jquery.smartresize.js *
	* Copyright 2011 Louis-Remi & Luke Shumard * Licensed under the MIT license. *
	*/

	var event = $.event,
		scrollTimeout;

	event.special.smartscroll = {
		setup: function() {
		  $(this).bind( "scroll", event.special.smartscroll.handler );
		},
		teardown: function() {
		  $(this).unbind( "scroll", event.special.smartscroll.handler );
		},
		handler: function( event, execAsap ) {
		  // Save the context
		  var context = this,
		      args = arguments;

		  // set correct event type
		  event.type = "smartscroll";

		  if (scrollTimeout) { clearTimeout(scrollTimeout); }
		  scrollTimeout = setTimeout(function() {
		    jQuery.event.dispatch.apply( context, args );
		  }, execAsap === "execAsap"? 0 : 100);
		}
	};

	$.fn.smartscroll = function( fn ) {
		return fn ? this.bind( "smartscroll", fn ) : this.trigger( "smartscroll", ["execAsap"] );
	};


})(jQuery);
