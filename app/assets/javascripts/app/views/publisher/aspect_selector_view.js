/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

// Aspects view for the publisher.
// Provides the ability to specify the visibility of posted content as public
// or limited to selected aspects
app.views.PublisherAspectSelector  = Backbone.View.extend({

  events: {
    "click .dropdown_list > li": "toggleAspect"
  },

  initialize: function(opts) {
    this.form = opts.form;
  },

  // event handler for aspect selection
  toggleAspect: function(evt) {
    var el = $(evt.target);
    var btn = el.parent('.dropdown').find('.button');

    // visually toggle the aspect selection
    if( el.is('.radio') ) {
      AspectsDropdown.toggleRadio(el);
    } else {
      AspectsDropdown.toggleCheckbox(el);
    }

    // update the selection summary
    this._updateAspectsNumber(el);

    this._updateSelectedAspectIds();
  },

  // select a (list of) aspects in the dropdown selector by the given list of ids
  updateAspectsSelector: function(ids){
    var el = this.$("ul.dropdown_list");
    this.$('.dropdown_list > li').each(function(){
      var el = $(this);
      var aspectId = el.data('aspect_id');
      if (_.contains(ids, aspectId)) {
        el.addClass('selected');
      }
      else {
        el.removeClass('selected');
      }
    });

    this._updateAspectsNumber(el);
    this._updateSelectedAspectIds();
  },

  // take care of the form fields that will indicate the selected aspects
  _updateSelectedAspectIds: function() {
    var self = this;

    // remove previous selection
    this.form.find('input[name="aspect_ids[]"]').remove();

    // create fields for current selection
    this.$('.dropdown_list li.selected').each(function() {
      var el = $(this);
      var aspectId = el.data('aspect_id');

      self._addHiddenAspectInput(aspectId);

      // close the dropdown when a radio item was selected
      if( el.is('.radio') ) {
        el.closest('.dropdown').removeClass('active');
      }
    });
  },

  _updateAspectsNumber: function(el){
    AspectsDropdown.updateNumber(
      el.closest(".dropdown_list"),
      null,
      el.parent().find('li.selected').length,
      ''
    );
  },

  _addHiddenAspectInput: function(id) {
    var uid = _.uniqueId('aspect_ids_');
    this.form.append(
      '<input id="'+uid+'" name="aspect_ids[]" type="hidden" value="'+id+'">'
    );
  }
});
