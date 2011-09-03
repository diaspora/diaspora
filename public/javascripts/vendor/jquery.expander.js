/*!
 * jQuery Expander Plugin v0.7
 *
 * Date: Wed Aug 31 20:53:59 2011 EDT
 * Requires: jQuery v1.3+
 *
 * Copyright 2011, Karl Swedberg
 * Dual licensed under the MIT and GPL licenses (just like jQuery):
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 * source: https://github.com/kswedberg/jquery-expander/
*/

(function($) {

  $.fn.expander = function(options) {

    var opts = $.extend({}, $.fn.expander.defaults, options),
        rSlash = /\//,
        delayedCollapse;

    this.each(function() {
      var cleanedTag, startTags, endTags,
          thisEl = this,
          $this = $(this),
          o = $.meta ? $.extend({}, opts, $this.data()) : opts,
          expandSpeed = o.expandSpeed || 0,
          allText = $this.html(),
          startText = allText.slice(0, o.slicePoint).replace(/(&([^;]+;)?|\w+)$/,'');

      startTags = startText.match(/<\w[^>]*>/g);

      if (startTags) {
        startText = allText.slice(0,o.slicePoint + startTags.join('').length).replace(/(&([^;]+;)?|\w+)$/,'');
      }

      if (startText.lastIndexOf('<') > startText.lastIndexOf('>') ) {
        startText = startText.slice(0,startText.lastIndexOf('<'));
      }

      var defined = {};
      $.each(['onSlice','beforeExpand', 'afterExpand', 'onCollapse'], function(index, val) {
        defined[val] = $.isFunction(o[val]);
      });

      var endText = allText.slice(startText.length);
      // create necessary expand/collapse elements if they don't already exist
      if (!$(this).find('span.details').length) {
        // end script if text length isn't long enough.
        if ( endText.replace(/\s+$/,'').split(' ').length < o.widow || allText.length < o.slicePoint ) { return; }
        // otherwise, continue...
        if (defined.onSlice) { o.onSlice.call(thisEl); }
        if (endText.indexOf('</') > -1) {
          endTags = endText.match(/<(\/)?[^>]*>/g);
          for (var i=0; i < endTags.length; i++) {

            if (endTags[i].indexOf('</') > -1) {
              var startTag, startTagExists = false;
              for (var j=0; j < i; j++) {
                startTag = endTags[j].slice(0, endTags[j].indexOf(' ')).replace(/\w$/,'$1>');
                if (startTag == endTags[i].replace(rSlash,'')) {
                  startTagExists = true;
                }
              }
              if (!startTagExists) {
                startText = startText + endTags[i];
                var matched = false;
                for (var s=startTags.length - 1; s >= 0; s--) {
                  if (startTags[s].slice(0, startTags[s].indexOf(' ')).replace(/(\w)$/,'$1>') == endTags[i].replace(rSlash,'') &&
                  !matched ) {
                    cleanedTag = cleanedTag ? startTags[s] + cleanedTag : startTags[s];
                    matched = true;
                  }
                }
              }
            }
          }

          endText = cleanedTag && cleanedTag + endText || endText;
        }
        $this.html([
          startText,
          '<span class="read-more">',
            o.expandPrefix,
            '<a href="#">',
              o.expandText,
            '</a>',
          '</span>',
          '<span class="details">',
            endText,
          '</span>'
          ].join('')
        );
      }

      var $thisDetails = $(this).find('span.details'),
          $readMore = $(this).find('span.read-more');

      $thisDetails.hide();
      $readMore.find('a').bind('click.expander', function(event) {
        event.preventDefault();
        $readMore.hide();
        if (defined.beforeExpand) {
          o.beforeExpand.call(thisEl);
        }

        $thisDetails[o.expandEffect](expandSpeed, function() {
          $thisDetails.css({zoom: ''});
          if (defined.afterExpand) {o.afterExpand.call(thisEl);}
          delayCollapse(o, $thisDetails, thisEl);
        });
      });

      if ( o.userCollapse && !$this.find('span.re-collapse').length ) {
        $this
        .find('span.details')
        .append('<span class="re-collapse">' + o.userCollapsePrefix + '<a href="#">' + o.userCollapseText + '</a></span>');
        $this.find('span.re-collapse a').bind('click.expander', function(event) {
          event.preventDefault();
          clearTimeout(delayedCollapse);
          var $detailsCollapsed = $(this).parents('span.details');
          reCollapse($detailsCollapsed);
          if (defined.onCollapse) {
            o.onCollapse.call(thisEl, true);
          }
        });
      }
    });

    function reCollapse(el) {
       el.hide()
        .prev('span.read-more').show();
    }
    function delayCollapse(option, $collapseEl, thisEl) {
      if (option.collapseTimer) {
        delayedCollapse = setTimeout(function() {
          reCollapse($collapseEl);
          if ( $.isFunction(option.onCollapse) ) {
            option.onCollapse.call(thisEl, false);
          }
        }, option.collapseTimer);
      }
    }

    return this;
  };

  // plugin defaults
  $.fn.expander.defaults = {
    // slicePoint: the number of characters at which the contents will be sliced into two parts.
    // Note: any tag names in the HTML that appear inside the sliced element before
    // the slicePoint will be counted along with the text characters.
    slicePoint: 100,

    // widow: a threshold of sorts for whether to initially hide/collapse part of the element's contents.
    // If after slicing the contents in two there are fewer words in the second part than
    // the value set by widow, we won't bother hiding/collapsing anything.
    widow: 4,

    // text displayed in a link instead of the hidden part of the element.
    // clicking this will expand/show the hidden/collapsed text
    expandText: 'read more',
    expandPrefix: '&hellip; ',

    // number of milliseconds after text has been expanded at which to collapse the text again
    collapseTimer: 0,
    expandEffect: 'fadeIn',
    expandSpeed: 250,

    // allow the user to re-collapse the expanded text.
    userCollapse: true,

    // text to use for the link to re-collapse the text
    userCollapseText: '[collapse expanded text]',
    userCollapsePrefix: ' ',


    // all callback functions have the this keyword mapped to the element in the jQuery set when .expander() is called

    onSlice: null, // function() {}
    beforeExpand: null, // function() {},
    afterExpand: null, // function() {},
    onCollapse: null // function(byUser) {}
  };
})(jQuery);
