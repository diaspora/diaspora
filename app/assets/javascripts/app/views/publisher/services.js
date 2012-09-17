/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function(){
  // mixin-object, used in conjunction with the publisher to provide the
  // functionality for selecting services for cross-posting
  app.views.PublisherServices = {

    // visually toggle the icon and kick-off all other actions for cross-posting
    toggleService: function(evt) {
      var el = $(evt.target);
      var provider = el.attr('id');

      el.toggleClass("dim");

      this._createCounter();
      this._toggleServiceField(provider);
    },

    // keep track of character count
    _createCounter: function() {
      // remove obsolete counter
      this.$('.counter').remove();

      // create new counter
      var min = 40000;
      var a = this.$('.service_icon:not(.dim)');
      if(a.length > 0){
        $.each(a, function(index, value){
          var num = parseInt($(value).attr('maxchar'));
          if (min > num) { min = num; }
        });
        this.el_input.charCount({allowed: min, warning: min/10 });
      }
    },

    // add or remove the input containing the selected service
    _toggleServiceField: function(provider) {
      var hidden_field = this.$('input[name="services[]"][value="'+provider+'"]');
      if(hidden_field.length > 0){
        hidden_field.remove();
      } else {
        var uid = _.uniqueId('services_');
        this.$(".content_creation form").append(
        '<input id="'+uid+'" name="services[]" type="hidden" value="'+provider+'">');
      }
    }
  };
})();