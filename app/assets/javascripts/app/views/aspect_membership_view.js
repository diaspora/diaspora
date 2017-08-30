// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/**
 * this view lets the user (de-)select aspect memberships in the context
 * of another users profile or the contact page.
 *
 * updates to the list of aspects are immediately propagated to the server, and
 * the results are dislpayed as flash messages.
 */
app.views.AspectMembership = app.views.Base.extend({
  templateName: "aspect_membership_dropdown",
  className: "btn-group aspect-dropdown aspect-membership-dropdown",

  subviews: {
    ".newAspectContainer": "aspectCreateView"
  },

  events: {
    "click ul.aspect_membership.dropdown-menu > li.aspect_selector"
        : "_clickHandler",
    "keypress ul.aspect_membership.dropdown-menu > li.aspect_selector"
        : "_clickHandler"
  },

  initialize: function(opts) {
    _.extend(this, opts);
    this.list_item = null;
    this.dropdown  = null;
  },

  presenter: function() {
    var aspectMembershipsLength = this.person.contact ? this.person.contact.aspectMemberships.length : 0;

    return _.extend(this.defaultPresenter(), {
      aspects: this.aspectsPresenter(),
      dropdownMayCreateNewAspect: this.dropdownMayCreateNewAspect
    }, aspectMembershipsLength === 0 ? {
      extraButtonClass: "btn-default",
      noAspectIsSelected: true
    } : { // this.contact.aspectMemberships.length > 0
      aspectMembershipsLength: aspectMembershipsLength,
      allAspectsAreSelected: aspectMembershipsLength === app.aspects.length,
      onlyOneAspectIsSelected: aspectMembershipsLength === 1,
      firstMembershipName: this.person.contact.aspectMemberships.at(0).get("aspect").name,
      extraButtonClass: "btn-success"
    });
  },

  aspectsPresenter: function() {
    return _.map(app.aspects.models, function(aspect) {
      return _.extend(
        this.person.contact ?
          {membership: this.person.contact.aspectMemberships.findByAspectId(aspect.attributes.id)} : {},
        aspect.attributes // id, name
      );
    }, this);
  },

  aspectCreateView: function() {
    return new app.views.AspectCreate({
      person: this.person
    });
  },

  // decide what to do when clicked
  //   -> addMembership
  //   -> removeMembership
  _clickHandler: function(evt) {
    this.list_item = $(evt.target).closest('li.aspect_selector');
    this.dropdown  = this.list_item.parent();

    this.list_item.addClass('loading');

    if (this.list_item.is(".selected")) {
      this.removeMembership(this.list_item.data("membership_id"));
    } else {
      this.addMembership(this.list_item.data("aspect_id"));
    }

    return false; // stop the event
  },

  // return the (short) name of the person associated with the current dropdown
  _name: function() {
    return this.person.name || this.person.get("name");
  },

  _personId: function() {
    return this.person.id;
  },

  // create a membership for the given person in the given aspect
  addMembership: function(aspectId) {
    if (!this.person.contact) {
      this.person.contact = new app.models.Contact();
    }

    this.listenToOnce(this.person.contact.aspectMemberships, "sync", this._successSaveCb);
    this.listenToOnce(this.person.contact.aspectMemberships, "error", this._displayError);

    return this.person.contact.aspectMemberships.create({"aspect_id": aspectId, "person_id": this._personId()});
  },

  _successSaveCb: function(aspectMembership) {
    var aspectId = aspectMembership.get("aspect_id"),
        startSharing = false;

    // the user didn't have this person in any aspects before, congratulate them
    // on their newly found friendship ;)
    if( this.dropdown.find("li.selected").length === 0 ) {
      var msg = Diaspora.I18n.t("aspect_dropdown.started_sharing_with", { "name": this._name() });
      startSharing = true;
      app.flashMessages.success(msg);
    }

    app.events.trigger("aspect_membership:create", {
      membership: {aspectId: aspectId, personId: this._personId()},
      startSharing: startSharing
    });
    this.render();
    app.events.trigger("aspect_membership:update");
  },

  // show an error flash msg
  _displayError: function(model, resp) {
    this._done();
    this.dropdown.closest(".aspect-membership-dropdown").removeClass("open"); // close the dropdown
    app.flashMessages.handleAjaxError(resp);
  },

  // remove the membership with the given id
  removeMembership: function(membershipId) {
    var membership = this.person.contact.aspectMemberships.get(membershipId);
    this.listenToOnce(membership, "sync", this._successDestroyCb);
    this.listenToOnce(membership, "error", this._displayError);

    return membership.destroy({wait: true});
  },

  _successDestroyCb: function(aspectMembership) {
    var membershipId = aspectMembership.get("id"),
        aspectId = aspectMembership.get("aspect").id,
        stopSharing = false;

    this.render();
    // we just removed the last aspect, inform the user with a flash message
    // that they are no longer sharing with that person
    if (this.$el.find("li.selected").length === 0) {
      var msg = Diaspora.I18n.t("aspect_dropdown.stopped_sharing_with", { "name": this._name() });
      stopSharing = true;
      app.flashMessages.success(msg);
    }

    app.events.trigger("aspect_membership:destroy", {
      membership: {aspectId: aspectId, personId: this._personId()},
      stopSharing: stopSharing
    });
    app.events.trigger("aspect_membership:update");
  },

  // cleanup tasks after aspect selection
  _done: function() {
    if( this.list_item ) {
      this.list_item.removeClass('loading');
    }
  },
});
// @license-end
