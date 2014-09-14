/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

function toggleAspectTitle(){
  $("#aspect_name_title").toggleClass('hidden');
  $("#aspect_name_edit").toggleClass('hidden');
}

function updateAspectName(new_name) {
  $('#aspect_name_title .name').text(new_name);
  $('input#aspect_name').val(new_name);
}
function updatePageAspectName( an_id, new_name) {
  $('ul#aspect_nav [data-aspect-id="'+an_id+'"] .selectable').text(new_name);
}

$(document).ready(function() {
  $(document).on('click', '#rename_aspect_link', function(){
    toggleAspectTitle();
  });

  $(document).on('ajax:success', 'form.edit_aspect', function(evt, data, status, xhr) {
    updateAspectName(data['name']);
    updatePageAspectName( data['id'], data['name'] );
    toggleAspectTitle();
  });
});


/**
 * TEMPORARY SOLUTION
 * TODO remove me, when the contacts section is done with Backbone.js ...
 * (this is about as much covered by tests as the old code ... not at all)
 *
 * see also 'contact-edit.js'
 */

app.tmp || (app.tmp = {});

// on the contacts page, viewing the facebox for single aspect
app.tmp.ContactAspectsBox = function() {
  $('body').on('click', '#aspect_edit_pane a.add.btn', _.bind(this.addToAspect, this));
  $('body').on('click', '#aspect_edit_pane a.added.btn', _.bind(this.removeFromAspect, this));
};
_.extend(app.tmp.ContactAspectsBox.prototype, {
  addToAspect: function(evt) {
    var el = $(evt.currentTarget);
    var aspect_membership = new app.models.AspectMembership({
      'person_id': el.data('person_id'),
      'aspect_id': el.data('aspect_id')
    });

    aspect_membership.on('sync', this._successSaveCb, this);
    aspect_membership.on('error', function() {
      this._displayError('aspect_dropdown.error', el);
    }, this);

    aspect_membership.save();

    return false;
  },

  _successSaveCb: function(aspect_membership) {
    var membership_id = aspect_membership.get('id');
    var person_id = aspect_membership.get('person_id');
    var el = $('li.contact').find('a.add[data-person_id="'+person_id+'"]');

    el.removeClass('add')
      .addClass('added')
      .attr('data-membership_id', membership_id) // just to be sure...
      .data('membership_id', membership_id);

    el.find('div').removeClass('icons-monotone_plus_add_round')
      .addClass('icons-monotone_check_yes');
  },

  removeFromAspect: function(evt) {
    var el = $(evt.currentTarget);

    var aspect_membership = new app.models.AspectMembership({
      'id': el.data('membership_id')
    });
    aspect_membership.on('sync', this._successDestroyCb, this);
    aspect_membership.on('error', function(aspect_membership) {
      this._displayError('aspect_dropdown.error_remove', el);
    }, this);

    aspect_membership.destroy();

    return false;
  },

  _successDestroyCb: function(aspect_membership) {
    var membership_id = aspect_membership.get('id');
    var el = $('li.contact').find('a.added[data-membership_id="'+membership_id+'"]');

    el.removeClass('added')
      .addClass('add')
      .removeAttr('data-membership_id')
      .removeData('membership_id');
      
    el.find('div').removeClass('icons-monotone_check_yes')
      .addClass('icons-monotone_plus_add_round');
  },

  _displayError: function(msg_id, contact_el) {
    var name = $('li.contact')
                 .has(contact_el)
                 .find('h4.name')
                 .text();
    var msg = Diaspora.I18n.t(msg_id, { 'name': name });
    Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
  }
});

$(function() {
  var contact_aspects_box = new app.tmp.ContactAspectsBox();
});
