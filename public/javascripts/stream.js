/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  selector: "#main_stream",

  initialize: function() {
    Diaspora.page.timeAgo.updateTimeAgo();
    Diaspora.page.directionDetector.updateBinds();

    //audio links
    Stream.setUpAudioLinks();
    //Stream.setUpImageLinks();

    Diaspora.page.subscribe("stream/scrolled", Stream.collapseText);
    Stream.collapseText('eventID', $(Stream.selector)[0]);
  },
  collapseText: function(){
    elements = $(Array.prototype.slice.call(arguments,1));
    // collapse long posts
    $(".content p", elements).expander({
      slicePoint: 400,
      widow: 12,
      expandText: Diaspora.I18n.t("show_more"),
      userCollapse: false
    });

    // collapse long comments
    $(".comment .content span", elements).expander({
      slicePoint: 200,
      widow: 18,
      expandText: Diaspora.I18n.t("show_more"),
      userCollapse: false
    });
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

    // ajax-loader and hide icon visibility handling for post hide and unhide
    $("a.stream_element_delete.vis_hide").live("click", function(evt){
      $(this).toggleClass("hidden");
      $(this).next("img.hide_loader").toggleClass("hidden");
    });
    $("a.stream_element_hide_undo").live("click", function(evt){
      $(this).closest('.stream_element').find("img.hide_loader").toggleClass("hidden");
    });

//    this.setUpComments();
  },

  setUpComments: function(){
    // comment link form focus
    $(".focus_comment_textarea", this.selector).live('click', function(evt) {
      Stream.focusNewComment($(this), evt);
    });

    $("textarea.comment_box", this.selector).live("focus", function(evt) {
      if (this.value === undefined || this.value ===  ''){
        var commentBox = $(this);
        commentBox
          .parent().parent()
            .addClass("open");
      }
    });
    $("textarea.comment_box", this.selector).live("blur", function(evt) {
      if (this.value === undefined || this.value ===  ''){
        var commentBox = $(this);
        commentBox
          .parent().parent()
            .removeClass("open");
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
  },

  setUpImageLinks: function() {
    $(".stream a[target='_blank']").each(function() {
      var link = $(this);
      if(this.href.match(/\.gif$|\.jpg$|\.png$|\.jpeg$/)) {
        $("<img/>", {
          src: this.href
        }).appendTo(link.parent());

        link.remove();
      }
    });
  },

  focusNewComment: function(toggle, evt) {
    evt.preventDefault();
    var post = toggle.closest(".stream_element");
    var commentBlock = post.find(".new_comment_form_wrapper");
    var textarea = post.find(".new_comment textarea");

    if(commentBlock.hasClass("hidden")) {
      commentBlock.removeClass("hidden");
      textarea.focus();
    } else {
      if(commentBlock.children().length <= 1) {
        commentBlock.addClass("hidden");
      } else {
        textarea.focus();
      }
    }
  }
};

$(document).ready(function() {
  if( $(Stream.selector).length == 0 ) { return }
  Stream.initializeLives();
//  Diaspora.page.subscribe("stream/reloaded", Stream.initialize, Stream);
//  Diaspora.page.publish("stream/reloaded");
});
