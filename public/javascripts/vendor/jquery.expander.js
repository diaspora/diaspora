/*
 * jQuery Expander plugin
 * Version 0.4  (12/09/2008)
 * @requires jQuery v1.1.1+
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */


(function($) {

  $.fn.expander = function(options) {

    var opts = $.extend({}, $.fn.expander.defaults, options);
    var delayedCollapse;
    return this.each(function() {
      var $this = $(this);
      var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
     	var cleanedTag, startTags, endTags;	
     	var allText = $this.html();
     	var startText = allText.slice(0, o.slicePoint).replace(/\w+$/,'');
     	startTags = startText.match(/<\w[^>]*>/g);
   	  if (startTags) {startText = allText.slice(0,o.slicePoint + startTags.join('').length).replace(/\w+$/,'');}
   	  
     	if (startText.lastIndexOf('<') > startText.lastIndexOf('>') ) {
     	  startText = startText.slice(0,startText.lastIndexOf('<'));
     	}
     	var endText = allText.slice(startText.length);    	  
     	// create necessary expand/collapse elements if they don't already exist
   	  if (!$('span.details', this).length) {
        // end script if text length isn't long enough.
       	if ( endText.replace(/\s+$/,'').split(' ').length < o.widow ) { return; }
       	// otherwise, continue...    
       	if (endText.indexOf('</') > -1) {
         	endTags = endText.match(/<(\/)?[^>]*>/g);
          for (var i=0; i < endTags.length; i++) {

            if (endTags[i].indexOf('</') > -1) {
              var startTag, startTagExists = false;
              for (var j=0; j < i; j++) {
                startTag = endTags[j].slice(0, endTags[j].indexOf(' ')).replace(/(\w)$/,'$1>');
                if (startTag == rSlash(endTags[i])) {
                  startTagExists = true;
                }
              }              
              if (!startTagExists) {
                startText = startText + endTags[i];
                var matched = false;
                for (var s=startTags.length - 1; s >= 0; s--) {
                  if (startTags[s].slice(0, startTags[s].indexOf(' ')).replace(/(\w)$/,'$1>') == rSlash(endTags[i]) 
                  && matched == false) {
                    cleanedTag = cleanedTag ? startTags[s] + cleanedTag : startTags[s];
                    matched = true;
                  }
                };
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
      var $thisDetails = $('span.details', this),
        $readMore = $('span.read-more', this);
   	  $thisDetails.hide();
 	    $readMore.find('a').click(function() {
 	      $readMore.hide();

 	      if (o.expandEffect === 'show' && !o.expandSpeed) {
          o.beforeExpand($this);
 	        $thisDetails.show();
          o.afterExpand($this);
          delayCollapse(o, $thisDetails);
 	      } else {
          o.beforeExpand($this);
 	        $thisDetails[o.expandEffect](o.expandSpeed, function() {
            $thisDetails.css({zoom: ''});
            o.afterExpand($this);
            delayCollapse(o, $thisDetails);
 	        });
 	      }
        return false;
 	    });
      if (o.userCollapse) {
        $this
        .find('span.details').append('<span class="re-collapse">' + o.userCollapsePrefix + '<a href="#">' + o.userCollapseText + '</a></span>');
        $this.find('span.re-collapse a').click(function() {

          clearTimeout(delayedCollapse);
          var $detailsCollapsed = $(this).parents('span.details');
          reCollapse($detailsCollapsed);
          o.onCollapse($this, true);
          return false;
        });
      }
    });
    function reCollapse(el) {
       el.hide()
        .prev('span.read-more').show();
    }
    function delayCollapse(option, $collapseEl) {
      if (option.collapseTimer) {
        delayedCollapse = setTimeout(function() {  
          reCollapse($collapseEl);
          option.onCollapse($collapseEl.parent(), false);
          },
          option.collapseTimer
        );
      }
    }
    function rSlash(rString) {
      return rString.replace(/\//,'');
    }    
  };
    // plugin defaults
  $.fn.expander.defaults = {
    slicePoint:       100,  // the number of characters at which the contents will be sliced into two parts. 
                            // Note: any tag names in the HTML that appear inside the sliced element before 
                            // the slicePoint will be counted along with the text characters.
    widow:            4,  // a threshold of sorts for whether to initially hide/collapse part of the element's contents. 
                          // If after slicing the contents in two there are fewer words in the second part than 
                          // the value set by widow, we won't bother hiding/collapsing anything.
    expandText:       'read more', // text displayed in a link instead of the hidden part of the element. 
                                      // clicking this will expand/show the hidden/collapsed text
    expandPrefix:     '&hellip; ',
    collapseTimer:    0, // number of milliseconds after text has been expanded at which to collapse the text again
    expandEffect:     'fadeIn',
    expandSpeed:      '',   // speed in milliseconds of the animation effect for expanding the text
    userCollapse:     true, // allow the user to re-collapse the expanded text.
    userCollapseText: '[collapse expanded text]',  // text to use for the link to re-collapse the text
    userCollapsePrefix: ' ',
    beforeExpand: function($thisEl) {},
    afterExpand: function($thisEl) {},
    onCollapse: function($thisEl, byUser) {}
  };
})(jQuery);
