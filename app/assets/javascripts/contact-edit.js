//   Copyright (c) 2010-2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

/**
 * TEMPORARY SOLUTION
 * TODO remove me, when the contacts section is done with Backbone.js ...
 * (this is about as much covered by tests as the old code ... not at all)
 *
 * see also 'aspect-edit-pane.js'
 */

app.tmp || (app.tmp = {});

// on the contacts page, viewing the list of people in a single aspect
app.tmp.ContactAspects = function() {
  $('#people_stream').on('click', '.contact_remove-from-aspect', _.bind(this.removeFromAspect, this));
};
_.extend(app.tmp.ContactAspects.prototype, {
  removeFromAspect: function(evt) {
    evt.stopImmediatePropagation();
    evt.preventDefault();

    var el = $(evt.currentTarget);
    var id = el.data('membership_id');

    var aspect_membership = new app.models.AspectMembership({'id':id});
    aspect_membership.on('sync', this._successDestroyCb, this);
    aspect_membership.on('error', function(aspect_membership) {
      this._displayError('aspect_dropdown.error_remove', aspect_membership.get('id'));
    }, this);

    aspect_membership.destroy();

    return false;
  },

  _successDestroyCb: function(aspect_membership) {
    var membership_id = aspect_membership.get('id');

    $('.stream_element').has('[data-membership_id="'+membership_id+'"]')
      .fadeOut(300, function() { $(this).remove() });
  },

  _displayError: function(msg_id, membership_id) {
    var name = $('.stream_element')
      .has('[data-membership_id="'+membership_id+'"]')
      .find('div.bd > a')
      .text();
    var msg = Diaspora.I18n.t(msg_id, { 'name': name });
    Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
  }
});


$(function() {
  var contact_aspects = new app.tmp.ContactAspects();
});
