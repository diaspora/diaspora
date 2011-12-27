/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  selector: "#main_stream",

  initialize: function() {
    Diaspora.page.directionDetector.updateBinds();
    Stream.setUpAudioLinks();
  },

  initializeLives: function(){
    // reshare button action
    $(".reshare_button", this.selector).live("click", function(evt) {
      evt.preventDefault();
      var button = $(this),
        box = button.siblings(".reshare_box");

      if (box.length > 0) {
        button.toggleClass("active");
        box.toggle();
      }
    });
  },

  setUpAudioLinks: function() {
    $(".stream a[target='_blank']").each(function(r){
      var link = $(this);
      if(this.href.match(/\.mp3$|\.ogg$/)) {
        $("<audio/>", {
          preload: "none",
          src: this.href,
          controls: "controls"
        }).appendTo(link.parent());

        link.remove();
      }
    });
  }
};

$(document).ready(function() {
  if( Diaspora.backboneEnabled() ){ return }

  if( $(Stream.selector).length == 0 ) { return }
  Stream.initializeLives();
});
