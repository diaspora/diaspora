/*
    jQuery `input` special event v1.0

    http://whattheheadsaid.com/projects/input-special-event

    (c) 2010-2011 Andy Earnshaw
    MIT license
    www.opensource.org/licenses/mit-license.php

    Modified by Kenneth Auchenberg
    * Disabled usage of onPropertyChange event in IE, since its a bit delayed, if you type really fast.
*/

(function($) {
  // Handler for propertychange events only
  function propHandler() {
    var $this = $(this);
    if (window.event.propertyName == "value" && !$this.data("triggering.inputEvent")) {
      $this.data("triggering.inputEvent", true).trigger("input");
      window.setTimeout(function () {
        $this.data("triggering.inputEvent", false);
      }, 0);
    }
  }

  $.event.special.input = {
    setup: function(data, namespaces) {
      var timer,
        // Get a reference to the element
        elem = this,
        // Store the current state of the element
        state = elem.value,
        // Create a dummy element that we can use for testing event support
        tester = document.createElement(this.tagName),
        // Check for native oninput
        oninput = "oninput" in tester || checkEvent(tester),
        // Check for onpropertychange
        onprop = "onpropertychange" in tester,
        // Generate a random namespace for event bindings
        ns = "inputEventNS" + ~~(Math.random() * 10000000),
        // Last resort event names
        evts = ["focus", "blur", "paste", "cut", "keydown", "drop", ""].join("." + ns + " ");

      function checkState() {
        var $this = $(elem);
        if (elem.value != state && !$this.data("triggering.inputEvent")) {
          state = elem.value;

          $this.data("triggering.inputEvent", true).trigger("input");
          window.setTimeout(function () {
            $this.data("triggering.inputEvent", false);
          }, 0);
        }
      }

      // Set up a function to handle the different events that may fire
      function handler(e) {
        // When focusing, set a timer that polls for changes to the value
        if (e.type == "focus") {
          checkState();
          clearInterval(timer);
          timer = window.setInterval(checkState, 250);
        } else if (e.type == "blur") {
          // When blurring, cancel the aforeset timer
          window.clearInterval(timer);
        } else {
          // For all other events, queue a timer to check state ASAP
          window.setTimeout(checkState, 0);
        }
      }

      // Bind to native event if available
      if (oninput) {
        return false;
//      } else if (onprop) {
//        // Else fall back to propertychange if available
//        $(this).find("input, textarea").andSelf().filter("input, textarea").bind("propertychange." + ns, propHandler);
      } else {
        // Else clutch at straws!
        $(this).find("input, textarea").andSelf().filter("input, textarea").bind(evts, handler);
      }
      $(this).data("inputEventHandlerNS", ns);
    },
    teardown: function () {
      var elem = $(this);
      elem.find("input, textarea").unbind(elem.data("inputEventHandlerNS"));
      elem.data("inputEventHandlerNS", "");
    }
  };

  // Setup our jQuery shorthand method
  $.fn.input = function (handler) {
    return handler ? this.bind("input", handler) : this.trigger("input");
  };

  /*
   The following function tests the element for oninput support in Firefox.  Many thanks to
   http://blog.danielfriesen.name/2010/02/16/html5-browser-maze-oninput-support/
   */
  function checkEvent(el) {
    // First check, for if Firefox fixes its issue with el.oninput = function
    el.setAttribute("oninput", "return");
    if (typeof el.oninput == "function") {
      return true;
    }
    // Second check, because Firefox doesn't map oninput attribute to oninput property
    try {

      // "* Note * : Disabled focus and dispatch of keypress event due to conflict with DOMready, which resulted in scrolling down to the bottom of the page, possibly because layout wasn't finished rendering.
      var e = document.createEvent("KeyboardEvent"),
        ok = false,
        tester = function(e) {
          ok = true;
          e.preventDefault();
          e.stopPropagation();
      };

      // e.initKeyEvent("keypress", true, true, window, false, false, false, false, 0, "e".charCodeAt(0));

      document.body.appendChild(el);
      el.addEventListener("input", tester, false);
      // el.focus();
      // el.dispatchEvent(e);
      el.removeEventListener("input", tester, false);
      document.body.removeChild(el);
      return ok;

    } catch(error) {

    }
  }
})(jQuery);