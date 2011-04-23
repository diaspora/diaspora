/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
/* Modified version of https://gitorious.org/statusnet/mainline/blobs/master/plugins/DirectionDetector/jquery.DirectionDetector.js */

Diaspora.widgets.add("directionDetector", function() {

  this.start = function() {
    Diaspora.widgets.directionDetector.updateBinds();
    
    Diaspora.widgets.subscribe("stream/scrolled", function() {
      Diaspora.widgets.directionDetector.updateBinds();
    });
  };

  this.isRTL = function(str) {
    if(typeof str != typeof "" || str.length<1)
      return false;
    var cc = str.charCodeAt(0);
    if(cc>=1536 && cc<=1791) // arabic, persian, ...
      return true;
    if(cc>=65136 && cc<=65279) // arabic peresent 2
      return true;
    if(cc>=64336 && cc<=65023) // arabic peresent 1
      return true;
    if(cc>=1424 && cc<=1535) // hebrew
      return true;
    if(cc>=64256 && cc<=64335) // hebrew peresent
      return true;
    if(cc>=1792 && cc<=1871) // Syriac
      return true;
    if(cc>=1920 && cc<=1983) // Thaana
      return true;
    if(cc>=1984 && cc<=2047) // NKo
      return true;
    if(cc>=11568 && cc<=11647) // Tifinagh
      return true;
    return false;
    };

  this.cleaner = new RegExp('@[^ ]+|^RT[: ]{1}| RT | RT: |[♺♻:]+', 'g');

  this.binds = [];

  this.updateBinds = function() {
    $.each(Diaspora.widgets.directionDetector.binds, function(i, v) {v.unbind('keyup', Diaspora.widgets.directionDetector.updateDirection);});
    Diaspora.widgets.directionDetector.binds = [];

    $("textarea").each(Diaspora.widgets.directionDetector.bind);
    $("input[type='text']").each(Diaspora.widgets.directionDetector.bind);
    $("input[type='search']").each(Diaspora.widgets.directionDetector.bind);
  };

  this.bind = function() {
    $(this).bind('keyup', Diaspora.widgets.directionDetector.updateDirection);
    Diaspora.widgets.directionDetector.binds.push($(this));
  };

  this.updateDirection = function() {
    tArea = $(this);
    var cleaned = tArea.val().replace(Diaspora.widgets.directionDetector.cleaner, '').replace(/^[ ]+/, '');
    if(Diaspora.widgets.directionDetector.isRTL(cleaned))
      tArea.css('direction', 'rtl');
    else
      tArea.css('direction', 'ltr');
  };
});
