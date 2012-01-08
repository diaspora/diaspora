/**
 *    @name                            Elastic
 *    @descripton                        Elastic is jQuery plugin that grow and shrink your textareas automatically
 *    @version                        1.6.10
 *    @requires                        jQuery 1.2.6+
 *
 *    @author                            Jan Jarfalk
 *    @author-email                    jan.jarfalk@unwrongest.com
 *    @author-website                    http://www.unwrongest.com
 *
 *    @licence                        MIT License - http://www.opensource.org/licenses/mit-license.php
 */

  (function(jQuery) {
  jQuery.fn.extend({
    elastic: function() {

      //	We will create a div clone of the textarea
      //	by copying these attributes from the textarea to the div.
      var mimics = [
        'paddingTop',
        'paddingRight',
        'paddingBottom',
        'paddingLeft',
        'marginTop',
        'marginRight',
        'marginBottom',
        'marginLeft',
        'fontSize',
        'lineHeight',
        'fontFamily',
        'width',
        'fontWeight',
        'border-top-width',
        'border-right-width',
        'border-bottom-width',
        'border-left-width',
        'borderTopStyle',
        'borderTopColor',
        'borderRightStyle',
        'borderRightColor',
        'borderBottomStyle',
        'borderBottomColor',
        'borderLeftStyle',
        'borderLeftColor',
        'box-sizing',
        '-moz-box-sizing',
        '-webkit-box-sizing'
      ];

      return this.each(function() {

        // Elastic only works on textareas
        if (this.type !== 'textarea') {
          return false;
        }

        var $textarea = jQuery(this),
          $twin = jQuery('<div />').css({'position': 'absolute','display':'none','word-wrap':'break-word'}),
          lineHeight = parseInt($textarea.css('line-height'), 10) || parseInt($textarea.css('font-size'), '10'),
          minheight = parseInt($textarea.css('height'), 10) || lineHeight * 3,
          maxheight = parseInt($textarea.css('max-height'), 10) || Number.MAX_VALUE,
          goalheight = 0;

        // Opera returns max-height of -1 if not set
        if (maxheight < 0) {
          maxheight = Number.MAX_VALUE;
        }

        // Append the twin to the DOM
        // We are going to meassure the height of this, not the textarea.
        $twin.appendTo($textarea.parent());

        // Copy the essential styles (mimics) from the textarea to the twin
        var i = mimics.length;
        while (i--) {

          if (mimics[i].toString() === 'width' && $textarea.css(mimics[i].toString()) === '0px') {
            setTwinWidth();
          } else {
            $twin.css(mimics[i].toString(), $textarea.css(mimics[i].toString()));
          }
        }

        update(true);

        // Updates the width of the twin. (solution for textareas with widths in percent)
        function setTwinWidth() {
          curatedWidth = Math.floor(parseInt($textarea.width(), 10));
          if ($twin.width() !== curatedWidth) {
            $twin.css({'width': curatedWidth + 'px'});

            // Update height of textarea
            update(true);
          }
        }

        // Sets a given height and overflow state on the textarea
        function setHeightAndOverflow(height, overflow) {

          var curratedHeight = Math.floor(parseInt(height, 10));
          if ($textarea.height() !== curratedHeight) {
            $textarea.css({'height': curratedHeight + 'px','overflow':overflow});

            // Fire the custom event resize
            $textarea.triggerHandler('resize');

          }
        }

        // This function will update the height of the textarea if necessary
        function update(forced) {

          // Get curated content from the textarea.
          var textareaContent = $textarea.val().replace(/&/g, '&amp;').replace(/ {2}/g, '&nbsp;').replace(/<|>/g, '&gt;').replace(/\n/g, '<br />');

          // Compare curated content with curated twin.
          var twinContent = $twin.html().replace(/<br>/ig, '<br />');

          if (forced || textareaContent + '&nbsp;' !== twinContent) {

            // Add an extra white space so new rows are added when you are at the end of a row.
            $twin.html(textareaContent + '&nbsp;');

            // Change textarea height if twin plus the height of one line differs more than 3 pixel from textarea height
            if (Math.abs($twin.outerHeight() + lineHeight - $textarea.outerHeight()) > 3) {

              var goalheight = $twin.outerHeight();
              if (goalheight >= maxheight) {
                setHeightAndOverflow(maxheight, 'auto');
              } else if (goalheight <= minheight) {
                setHeightAndOverflow(minheight, 'hidden');
              } else {
                setHeightAndOverflow(goalheight, 'hidden');
              }

            }

          }

        }

        // Update textarea size on keyup, change, cut and paste
        $textarea.bind('input', update);
        $textarea.bind('change', update);
        $(window).bind('resize', setTwinWidth);
      });

    }
  });
})(jQuery);