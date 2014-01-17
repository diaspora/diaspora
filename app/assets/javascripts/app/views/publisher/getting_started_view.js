/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

// Getting started view for the publisher.
// Provides "getting started" popups around the elements of the publisher
// for describing their use to new users.
app.views.PublisherGettingStarted = Backbone.View.extend({

  initialize: function(opts) {
    this.el_first_msg = opts.el_first_msg;
    this.el_visibility = opts.el_visibility;
    this.el_stream = opts.el_stream;
  },

  // initiate all the popover message boxes
  show: function() {
    this._addPopover(this.el_first_msg, {
      trigger: 'manual',
      offset: 30,
      id: 'first_message_explain',
      placement: 'right',
      html: true
    }, 600);
    this._addPopover(this.el_visibility, {
      trigger: 'manual',
      offset: 10,
      id: 'message_visibility_explain',
      placement: 'bottom',
      html: true
    }, 1000);
    this._addPopover(this.el_stream, {
      trigger: 'manual',
      offset: -5,
      id: 'stream_explain',
      placement: 'left',
      html: true
    }, 1400);

    // hide some popovers when a post is created
    this.$('.button.creation').click(function() {
      this.el_visibility.popover('hide');
      this.el_first_msg.popover('hide');
    });
  },

  _addPopover: function(el, opts, timeout) {
    el.popover(opts);
    el.click(function() {
      el.popover('hide');
    });

    // show the popover after the given timeout
    setTimeout(function() {
      el.popover('show');

      // disable 'getting started' when the last popover is closed
      var popup = el.data('popover').$tip[0];
      var close = $(popup).find('.close');

      close.click(function() {
        if( $('.popover').length==1 ) {
          $.get('/getting_started_completed');
        }
        el.popover('hide');
        return false;
      });
    }, timeout);
  }
});
