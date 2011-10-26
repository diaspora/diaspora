/*!
 * jQuery Expander Plugin v1.3
 *
 * Date: Sat Sep 17 00:37:34 2011 EDT
 * Requires: jQuery v1.3+
 *
 * Copyright 2011, Karl Swedberg
 * Dual licensed under the MIT and GPL licenses (just like jQuery):
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 *
 *
 *
*/

(function($) {
  $.expander = {
    version: '1.3',
    defaults: {
      // the number of characters at which the contents will be sliced into two parts.
      slicePoint: 100,

      // whether to keep the last word of the summary whole (true) or let it slice in the middle of a word (false)
      preserveWords: true,

      // widow: a threshold of sorts for whether to initially hide/collapse part of the element's contents.
      // If after slicing the contents in two there are fewer words in the second part than
      // the value set by widow, we won't bother hiding/collapsing anything.
      widow: 4,

      // text displayed in a link instead of the hidden part of the element.
      // clicking this will expand/show the hidden/collapsed text
      expandText: 'read more',
      expandPrefix: '&hellip; ',

      // class names for summary element and detail element
      summaryClass: 'summary',
      detailClass: 'details',

      // class names for <span> around "read-more" link and "read-less" link
      moreClass: 'read-more',
      lessClass: 'read-less',

      // number of milliseconds after text has been expanded at which to collapse the text again.
      // when 0, no auto-collapsing
      collapseTimer: 0,

      // effects for expanding and collapsing
      expandEffect: 'fadeIn',
      expandSpeed: 250,
      collapseEffect: 'fadeOut',
      collapseSpeed: 200,

      // allow the user to re-collapse the expanded text.
      userCollapse: true,

      // text to use for the link to re-collapse the text
      userCollapseText: 'read less',
      userCollapsePrefix: ' ',


      // all callback functions have the this keyword mapped to the element in the jQuery set when .expander() is called

      onSlice: null, // function() {}
      beforeExpand: null, // function() {},
      afterExpand: null, // function() {},
      onCollapse: null // function(byUser) {}
    }
  };

  $.fn.expander = function(options) {

    var opts = $.extend({}, $.expander.defaults, options),
        rSelfClose = /^<(?:area|br|col|embed|hr|img|input|link|meta|param).*>$/i,
        rAmpWordEnd = /(&(?:[^;]+;)?|\w+)$/,
        rOpenCloseTag = /<\/?(\w+)[^>]*>/g,
        rOpenTag = /<(\w+)[^>]*>/g,
        rCloseTag = /<\/(\w+)>/g,
        rTagPlus = /^<[^>]+>.?/,
        delayedCollapse;

    this.each(function() {
      var i, l, tmp, summTagLess, summOpens, summCloses, lastCloseTag, detailText,
          $thisDetails, $readMore,
          openTagsForDetails = [],
          closeTagsForsummaryText = [],
          defined = {},
          thisEl = this,
          $this = $(this),
          $summEl = $([]),
          o = $.meta ? $.extend({}, opts, $this.data()) : opts,
          hasDetails = !!$this.find('.' + o.detailClass).length,
          hasBlocks = !!$this.find('*').filter(function() {
            var display = $(this).css('display');
            return (/^block|table|list/).test(display);
          }).length,
          el = hasBlocks ? 'div' : 'span',
          detailSelector = el + '.' + o.detailClass,
          moreSelector = 'span.' + o.moreClass,
          expandSpeed = o.expandSpeed || 0,
          allHtml = $.trim( $this.html() ),
          allText = $.trim( $this.text() ),
          summaryText = allHtml.slice(0, o.slicePoint);

      // bail out if we've already set up the expander on this element
      if ( $.data(this, 'expander') ) {
        return;
      }
      $.data(this, 'expander', true);

      // determine which callback functions are defined
      $.each(['onSlice','beforeExpand', 'afterExpand', 'onCollapse'], function(index, val) {
        defined[val] = $.isFunction(o[val]);
      });

      // back up if we're in the middle of a tag or word
      summaryText = backup(summaryText);

      // summary text sans tags length
      summTagless = summaryText.replace(rOpenCloseTag,'').length;

      // add more characters to the summary, one for each character in the tags
      while (summTagless < o.slicePoint) {
        newChar = allHtml.charAt(summaryText.length);
        if (newChar == '<') {
          newChar = allHtml.slice(summaryText.length).match(rTagPlus)[0];
        }
        summaryText += newChar;
        summTagless++;
      }

      summaryText = backup(summaryText, o.preserveWords);

      // separate open tags from close tags and clean up the lists
      summOpens = summaryText.match(rOpenTag) || [];
      summCloses = summaryText.match(rCloseTag) || [];

      // filter out self-closing tags
      tmp = [];
      $.each(summOpens, function(index, val) {
        if ( !rSelfClose.test(val) ) {
          tmp.push(val);
        }
      });
      summOpens = tmp;

      // strip close tags to just the tag name
      l = summCloses.length;
      for (i = 0; i < l; i++) {
        summCloses[i] = summCloses[i].replace(rCloseTag, '$1');
      }

      // tags that start in summary and end in detail need:
      // a). close tag at end of summary
      // b). open tag at beginning of detail
      $.each(summOpens, function(index, val) {
        var thisTagName = val.replace(rOpenTag, '$1');
        var closePosition = $.inArray(thisTagName, summCloses);
        if (closePosition === -1) {
          openTagsForDetails.push(val);
          closeTagsForsummaryText.push('</' + thisTagName + '>');

        } else {
          summCloses.splice(closePosition, 1);
        }
      });

      // reverse the order of the close tags for the summary so they line up right
      closeTagsForsummaryText.reverse();

      // create necessary summary and detail elements if they don't already exist
      if ( !hasDetails ) {

        // end script if detail has fewer words than widow option
        detailText = allHtml.slice(summaryText.length);
        if ( detailText.split(/\s+/).length < o.widow && !hasDetails ) {
          return;
        }

        // otherwise, continue...
        lastCloseTag = closeTagsForsummaryText.pop() || '';
        summaryText += closeTagsForsummaryText.join('');
        detailText = openTagsForDetails.join('') + detailText;

      } else {
        // assume that even if there are details, we still need readMore/readLess/summary elements
        // (we already bailed out earlier when readMore el was found)
        // but we need to create els differently

        // remove the detail from the rest of the content
        detailText = $this.find(detailSelector).remove().html();

        // The summary is what's left
        summaryText = $this.html();

        // allHtml is the summary and detail combined (this is needed when content has block-level elements)
        allHtml = summaryText + detailText;

        lastCloseTag = '';
      }
      o.moreLabel = $this.find(moreSelector).length ? '' : buildMoreLabel(o);

      if (hasBlocks) {
        detailText = allHtml;
      }
      summaryText += lastCloseTag;

      // onSlice callback
      o.summary = summaryText;
      o.details = detailText;
      o.lastCloseTag = lastCloseTag;

      if (defined.onSlice) {
        // user can choose to return a modified options object
        // one last chance for user to change the options. sneaky, huh?
        // but could be tricky so use at your own risk.
        tmp = o.onSlice.call(thisEl, o);

      // so, if the returned value from the onSlice function is an object with a details property, we'll use that!
        o = tmp && tmp.details ? tmp : o;
      }

      // build the html with summary and detail and use it to replace old contents
      var html = buildHTML(o, hasBlocks);
      $this.html( html );

      // set up details and summary for expanding/collapsing
      $thisDetails = $this.find(detailSelector);
      $readMore = $this.find(moreSelector);
      $thisDetails.hide();
      $readMore.find('a').unbind('click.expander').bind('click.expander', expand);

      $summEl = $this.find('div.' + o.summaryClass);

      if ( o.userCollapse && !$this.find('span.' + o.lessClass).length ) {
        $this
        .find(detailSelector)
        .append('<span class="' + o.lessClass + '">' + o.userCollapsePrefix + '<a href="#">' + o.userCollapseText + '</a></span>');
      }

      $this
      .find('span.' + o.lessClass + ' a')
      .unbind('click.expander')
      .bind('click.expander', function(event) {
        event.preventDefault();
        clearTimeout(delayedCollapse);
        var $detailsCollapsed = $(this).closest(detailSelector);
        reCollapse(o, $detailsCollapsed);
        if (defined.onCollapse) {
          o.onCollapse.call(thisEl, true);
        }
      });

      function expand(event) {
        event.preventDefault();
        $readMore.hide();
        $summEl.hide();
        if (defined.beforeExpand) {
          o.beforeExpand.call(thisEl);
        }

        $thisDetails.stop(false, true)[o.expandEffect](expandSpeed, function() {
          $thisDetails.css({zoom: ''});
          if (defined.afterExpand) {o.afterExpand.call(thisEl);}
          delayCollapse(o, $thisDetails, thisEl);
        });
      }

    }); // this.each

    function buildHTML(o, blocks) {
      var el = 'span',
          summary = o.summary;
      if ( blocks ) {
        el = 'div';
        // tuck the moreLabel inside the last close tag
        summary = summary.replace(/(<\/[^>]+>)\s*$/, o.moreLabel + '$1');

        // and wrap it in a div
        summary = '<div class="' + o.summaryClass + '">' + summary + '</div>';
      } else {
        summary += o.moreLabel;
      }

      return [
        summary,
        '<',
          el + ' class="' + o.detailClass + '"',
        '>',
          o.details,
        '</' + el + '>'
        ].join('');
    }

    function buildMoreLabel(o) {
      var ret = '<span class="' + o.moreClass + '">' + o.expandPrefix;
      ret += '<a href="#">' + o.expandText + '</a></span>';
      return ret;
    }

    function backup(txt, preserveWords) {
      if ( txt.lastIndexOf('<') > txt.lastIndexOf('>') ) {
        txt = txt.slice( 0, txt.lastIndexOf('<') );
      }
      if (preserveWords) {
        txt = txt.replace(rAmpWordEnd,'');
      }
      return txt;
    }

    function reCollapse(o, el) {
      el.stop(true, true)[o.collapseEffect](o.collapseSpeed, function() {
        var prevMore = el.prev('span.' + o.moreClass).show();
        if (!prevMore.length) {
          el.parent().children('div.' + o.summaryClass).show()
            .find('span.' + o.moreClass).show();
        }
      });
    }

    function delayCollapse(option, $collapseEl, thisEl) {
      if (option.collapseTimer) {
        delayedCollapse = setTimeout(function() {
          reCollapse(option, $collapseEl);
          if ( $.isFunction(option.onCollapse) ) {
            option.onCollapse.call(thisEl, false);
          }
        }, option.collapseTimer);
      }
    }

    return this;
  };

  // plugin defaults
  $.fn.expander.defaults = $.expander.defaults;
})(jQuery);
