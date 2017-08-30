// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Contact = app.views.Base.extend({
  templateName: 'contact',

  subviews: {
    ".aspect-membership-dropdown": "AspectMembershipView"
  },

  events: {
    "click .contact_add-to-aspect" : "addContactToAspect",
    "click .contact_remove-from-aspect" : "removeContactFromAspect"
  },

  tooltipSelector: '.contact_add-to-aspect, .contact_remove-from-aspect',

  initialize: function() {
    this.AspectMembershipView = new app.views.AspectMembership(
      {person: _.extend(this.model.get("person"), {contact: this.model})}
    );
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      person_id : this.model.get('person_id'),
      person : this.model.get('person'),
      in_aspect: (app.aspect && this.model.inAspect(app.aspect.get('id'))) ? 'in_aspect' : '',
    });
  },

  addContactToAspect: function(){
    var self = this;
    // do we create the first aspect membership for this person?
    var startSharing = this.model.aspectMemberships.length === 0;
    this.model.aspectMemberships.create({
      "person_id": this.model.get("person_id"),
      "aspect_id": app.aspect.get("id")
    },{
      success: function(){
        app.events.trigger("aspect_membership:create", {
          membership: {
            aspectId: app.aspect.get("id"),
            personId: self.model.get("person_id")
          },
          startSharing: startSharing
        });
        self.render();
      },
      error: function(){
        var msg = Diaspora.I18n.t("contacts.error_add", { "name": self.model.get("person").name });
        app.flashMessages.error(msg);
      }
    });
  },

  removeContactFromAspect: function(){
    var self = this;
    // do we destroy the last aspect membership for this person?
    var stopSharing = this.model.aspectMemberships.length <= 1;
    this.model.aspectMemberships
      .find(function(membership){ return membership.get("aspect").id === app.aspect.id; })
      .destroy({
        success: function(){
          app.events.trigger("aspect_membership:destroy", {
            membership: {
              aspectId: app.aspect.get("id"),
              personId: self.model.get("person_id")
            },
            stopSharing: stopSharing
          });
          self.render();
        },
        error: function(){
          var msg = Diaspora.I18n.t("contacts.error_remove", { "name": self.model.get("person").name });
          app.flashMessages.error(msg);
        }
      });
  }
});
// @license-end
