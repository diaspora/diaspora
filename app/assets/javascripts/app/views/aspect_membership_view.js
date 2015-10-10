// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require ./aspects_dropdown_view

/**
 * this view lets the user (de-)select aspect memberships in the context
 * of another users profile or the contact page.
 *
 * updates to the list of aspects are immediately propagated to the server, and
 * the results are dislpayed as flash messages.
 */
app.views.AspectMembership = app.views.AspectsDropdown.extend({

  events: {
    "click ul.aspect_membership.dropdown-menu > li.aspect_selector"
        : "_clickHandler",
    "keypress ul.aspect_membership.dropdown-menu > li.aspect_selector"
        : "_clickHandler"
  },

  initialize: function() {
    this.list_item = null;
    this.dropdown  = null;
    if (this.$(".newAspectContainer").length > 0) {
      this.aspectCreateView = new app.views.AspectCreate({
        el:       this.$(".newAspectContainer"),
        personId: this.$("ul.dropdown-menu").data("person_id")
      });
      this.aspectCreateView.render();
    }
  },

  // decide what to do when clicked
  //   -> addMembership
  //   -> removeMembership
  _clickHandler: function(evt) {
    var promise = null;
    this.list_item = $(evt.target).closest('li.aspect_selector');
    this.dropdown  = this.list_item.parent();

    this.list_item.addClass('loading');

    if( this.list_item.is('.selected') ) {
      var membership_id = this.list_item.data('membership_id');
      promise = this.removeMembership(membership_id);
    } else {
      var aspect_id = this.list_item.data('aspect_id');
      var person_id = this.dropdown.data('person_id');
      promise = this.addMembership(person_id, aspect_id);
    }

    promise && promise.always(function() {
      // trigger a global event
      app.events.trigger('aspect_membership:update');
    });

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

    return aspect_membership.save();
  },

  _successSaveCb: function(aspectMembership) {
    var aspectId = aspectMembership.get("aspect_id"),
        membershipId = aspectMembership.get("id"),
        li = this.dropdown.find("li[data-aspect_id='" + aspectId + "']"),
        personId = li.closest("ul.dropdown-menu").data("person_id"),
        startSharing = false;

    // the user didn't have this person in any aspects before, congratulate them
    // on their newly found friendship ;)
    if( this.dropdown.find("li.selected").length === 0 ) {
      var msg = Diaspora.I18n.t("aspect_dropdown.started_sharing_with", { "name": this._name() });
      startSharing = true;
      app.flashMessages.success(msg);
    }

    app.events.trigger("aspect_membership:create", {
      membership: { aspectId: aspectId, personId: personId },
      startSharing: startSharing
    });

    li.attr("data-membership_id", membershipId) // just to be sure...
      .data("membership_id", membershipId);

    this.updateSummary(li);
    this._done();
  },

  // show an error flash msg
  _displayError: function(msg_id) {
    this._done();
    this.dropdown.closest('.aspect_membership_dropdown').removeClass('open'); // close the dropdown

    var msg = Diaspora.I18n.t(msg_id, { 'name': this._name() });
    app.flashMessages.error(msg);
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

    return aspect_membership.destroy();
  },

  _successDestroyCb: function(aspectMembership) {
    var membershipId = aspectMembership.get("id"),
        li = this.dropdown.find("li[data-membership_id='" + membershipId + "']"),
        aspectId = li.data("aspect_id"),
        personId = li.closest("ul.dropdown-menu").data("person_id"),
        stopSharing = false;

    li.removeAttr("data-membership_id")
      .removeData("membership_id");
    this.updateSummary(li);

    // we just removed the last aspect, inform the user with a flash message
    // that he is no longer sharing with that person
    if( this.dropdown.find("li.selected").length === 0 ) {
      var msg = Diaspora.I18n.t("aspect_dropdown.stopped_sharing_with", { "name": this._name() });
      stopSharing = true;
      app.flashMessages.success(msg);
    }

    app.events.trigger("aspect_membership:destroy", {
      membership: { aspectId: aspectId, personId: personId },
      stopSharing: stopSharing
    });

    this._done();
  },

  // cleanup tasks after aspect selection
  _done: function() {
    if( this.list_item ) {
      this.list_item.removeClass('loading');
    }
  },

  // refresh the button text to reflect the current aspect selection status
  updateSummary: function(target) {
    this._toggleCheckbox(target);
    this._updateButton("btn-success");
  }
});
// @license-end
