// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

// Services view for the publisher.
// Provides the ability for selecting services for cross-posting
app.views.PublisherServices = Backbone.View.extend({

  events: {
    'click .service_icon': 'toggleService'
  },

  tooltipSelector: '.service_icon',

  initialize: function(opts) {
    this.input = opts.input;
    this.form = opts.form;

    // init tooltip plugin
    this.$(this.tooltipSelector).tooltip();
  },

  // visually toggle the icon and handle all other actions for cross-posting
  toggleService: function(evt) {
    var el = $(evt.target).closest('.service_icon');
    var provider = el.attr('id');

    el.toggleClass("dim");

    this._createCounter();
    this._toggleServiceField(provider);
  },

  // keep track of character count
  _createCounter: function() {
    // remove any obsolete counters
    $("#publisher .counter").remove();

    // create new counter
    var min = 40000;
    var a = this.$('.service_icon:not(.dim)');
    if(a.length > 0){
      $.each(a, function(index, value){
        var num = parseInt($(value).attr('maxchar'));
        if (min > num) { min = num; }
      });
      var counter = $("<div class='counter pull-right'></div>");
      $("#publisher-images").after(counter);
      this.input.charCount({
        allowed: min,
        warning: min / 10,
        counter: counter
      });
    }
  },

  // add or remove the input containing the selected service
  _toggleServiceField: function(provider) {
    var hidden_field = this.form.find('input[name="services[]"][value="'+provider+'"]');
    if(hidden_field.length > 0){
      hidden_field.remove();
    } else {
      var uid = _.uniqueId('services_');
      this.form.append(
      '<input id="'+uid+'" name="services[]" type="hidden" value="'+provider+'">');
    }
  }
});
// @license-end

