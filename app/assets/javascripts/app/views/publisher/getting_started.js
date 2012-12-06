/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function(){
  // mixin-object, used in conjunction with the publisher to provide the
  // functionality for displaying 'getting-started' information
  app.views.PublisherGettingStarted = {

    // initiate all the popover message boxes
    triggerGettingStarted: function() {
      this._addPopover(this.el_input, {
        trigger: 'manual',
        offset: 30,
        id: 'first_message_explain',
        placement: 'right',
        html: true
      }, 600);
      this._addPopover(this.$('.dropdown'), {
        trigger: 'manual',
        offset: 10,
        id: 'message_visibility_explain',
        placement: 'bottom',
        html: true
      }, 1000);
      this._addPopover($('#gs-shim'), {
        trigger: 'manual',
        offset: -5,
        id: 'stream_explain',
        placement: 'left',
        html: true
      }, 1400);

      // hide some popovers when a post is created
      this.$('.button.creation').click(function() {
        this.$('.dropdown').popover('hide');
        this.el_input.popover('hide');
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
        });
      }, timeout);
    }
  };
})();