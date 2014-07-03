/*
 * 
 * flexime.js
 * Flexible font-size for huge text (pod name) in login page.
 * 
 */

jQuery.fn.flexime = function (refine, options) {

  var opt = $.extend({
    responsive: false
  }, options);

  var $this = $(this);
  var r = refine || 1;
  var max_size = 200;  // #huge-text default size
    
  var resize = function () {
    var clone = $this.clone();
    clone.css({'font-size':'10px','display':'inline-block','visibility':'hidden'}).appendTo('body');
    var size = Math.floor(($this.width() / clone.width()) * 10 / r);
    if (size < max_size) $this.css({'font-size':size+'px', 'line-height':Math.floor(size*.2)+'px'});

    clone.remove();
  };

  resize();
    
  if (opt.responsive)
    $(window).on('resize', resize);

  return this;
}
