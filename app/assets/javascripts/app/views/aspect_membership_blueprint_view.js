/**
 * this view lets the user (de-)select aspect memberships in the context
 * of another users profile or the contact page.
 *
 * updates to the list of aspects are immediately propagated to the server, and
 * the results are dislpayed as flash messages.
 */
app.views.AspectMembershipBlueprint = Backbone.View.extend({

  initialize: function() {
    // attach event handler, removing any previous instances
    var selector = '.dropdown.aspect_membership .dropdown_list > li';
    $('body')
      .off('click', selector)
      .on('click', selector, _.bind(this._clickHandler, this));

    this.list_item = null;
    this.dropdown  = null;
  },

  // decide what to do when clicked
  //   -> addMembership
  //   -> removeMembership
  _clickHandler: function(evt) {
    this.list_item = $(evt.target);
    this.dropdown  = this.list_item.parent();

    this.list_item.addClass('loading');

    if( this.list_item.is('.selected') ) {
      var membership_id = this.list_item.data('membership_id');
      this.removeMembership(membership_id);
    } else {
      var aspect_id = this.list_item.data('aspect_id');
      var person_id = this.dropdown.data('person_id');
      this.addMembership(person_id, aspect_id);
    }

    return false; // stop the event
  },

  // return the (short) name of the person associated with the current dropdown
  _name: function() {
    return this.dropdown.data('person-short-name');
  },

  // create a membership for the given person in the given aspect
  addMembership: function(person_id, aspect_id) {
    var aspect_membership = new app.models.AspectMembership({
      'person_id': person_id,
      'aspect_id': aspect_id
    });

    aspect_membership.on('sync', this._successSaveCb, this);
    aspect_membership.on('error', function() {
      this._displayError('aspect_dropdown.error');
    }, this);

    aspect_membership.save();
  },

  _successSaveCb: function(aspect_membership) {
    var aspect_id = aspect_membership.get('aspect_id');
    var membership_id = aspect_membership.get('id');
    var li = this.dropdown.find('li[data-aspect_id="'+aspect_id+'"]');

    // the user didn't have this person in any aspects before, congratulate them
    // on their newly found friendship ;)
    if( this.dropdown.find('li.selected').length == 0 ) {
      var msg = Diaspora.I18n.t('aspect_dropdown.started_sharing_with', { 'name': this._name() });
      Diaspora.page.flashMessages.render({ 'success':true, 'notice':msg });
    }

    li.attr('data-membership_id', membership_id) // just to be sure...
      .data('membership_id', membership_id)
      .addClass('selected');

    this.updateSummary();
    this._done();
  },

  // show an error flash msg
  _displayError: function(msg_id) {
    this._done();
    this.dropdown.removeClass('active'); // close the dropdown

    var msg = Diaspora.I18n.t(msg_id, { 'name': this._name() });
    Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
  },

  // remove the membership with the given id
  removeMembership: function(membership_id) {
    var aspect_membership = new app.models.AspectMembership({
      'id': membership_id
    });

    aspect_membership.on('sync', this._successDestroyCb, this);
    aspect_membership.on('error', function() {
      this._displayError('aspect_dropdown.error_remove');
    }, this);

    aspect_membership.destroy();
  },

  _successDestroyCb: function(aspect_membership) {
    var membership_id = aspect_membership.get('id');
    var li = this.dropdown.find('li[data-membership_id="'+membership_id+'"]');

    li.removeAttr('data-membership_id')
      .removeData('membership_id')
      .removeClass('selected');

    // we just removed the last aspect, inform the user with a flash message
    // that he is no longer sharing with that person
    if( this.dropdown.find('li.selected').length == 0 ) {
      var msg = Diaspora.I18n.t('aspect_dropdown.stopped_sharing_with', { 'name': this._name() });
      Diaspora.page.flashMessages.render({ 'success':true, 'notice':msg });
    }

    this.updateSummary();
    this._done();
  },

  // cleanup tasks after aspect selection
  _done: function() {
    if( this.list_item ) {
      this.list_item.removeClass('loading');
    }
  },

  // refresh the button text to reflect the current aspect selection status
  updateSummary: function() {
    var btn = this.dropdown.parents('div.aspect_membership').find('.button.toggle');
    var aspects_cnt = this.dropdown.find('li.selected').length;
    var txt;

    if( aspects_cnt == 0 ) {
      btn.removeClass('in_aspects');
      txt = Diaspora.I18n.t('aspect_dropdown.toggle.zero');
    } else {
      btn.addClass('in_aspects');
      txt = this._pluralSummaryTxt(aspects_cnt);
    }

    btn.text(txt + ' ▼');
  },

  _pluralSummaryTxt: function(cnt) {
    var all_aspects_cnt = this.dropdown.find('li').length;

    if( cnt == 1 ) {
      return this.dropdown.find('li.selected').first().text();
    }

    if( cnt == all_aspects_cnt ) {
      return Diaspora.I18n.t('aspect_dropdown.all_aspects');
    }

    return Diaspora.I18n.t('aspect_dropdown.toggle', { 'count':cnt.toString() });
  }
});
