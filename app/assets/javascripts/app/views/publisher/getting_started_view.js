// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

// Getting started view for the publisher.
// Provides "getting started" popups around the elements of the publisher
// for describing their use to new users.
app.views.PublisherGettingStarted = Backbone.View.extend({

  initialize: function(opts) {
    this.firstMessage = opts.firstMessageEl;
    this.visibility = opts.visibilityEl;
    this.stream = opts.streamEl;
  },

  // initiate all the popover message boxes
  show: function() {
    this._addPopover(this.firstMessage, {
      trigger: "manual",
      id: "first_message_explain",
      placement: "left",
      html: true,
      container: "body"
    }, 600);
    this._addPopover(this.visibility, {
      trigger: "manual",
      id: "message_visibility_explain",
      placement: "bottom",
      html: true,
      container: "body"
    }, 1000);
    this._addPopover(this.stream, {
      trigger: "manual",
      id: "stream_explain",
      placement: "left",
      html: true,
      container: "body"
    }, 1400);

    // hide some popovers when a post is created
    this.$("#submit").click(function() {
      this.visibility.popover("hide");
      this.firstMessage.popover("hide");
    });
  },

  _addPopover: function(el, opts, timeout) {
    el.popover(opts);
    el.click(function() {
      el.popover("hide");
    });

    // show the popover after the given timeout
    setTimeout(function() {
      el.popover("show");

      // disable 'getting started' when the last popover is closed
      var popup = el.data("bs.popover").$tip[0];
      var close = $(popup).find(".close");

      close.click(function() {
        if( $(".popover").length <= 1 ) {
          $.get("/getting_started_completed", {success: function() {
            $("#welcome-to-diaspora, #welcome-to-diaspora~br").remove();
          }});
        }
        el.popover("hide");
        return false;
      });
    }, timeout);
  }
});
// @license-end
