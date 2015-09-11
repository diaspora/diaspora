// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Contact = app.views.Base.extend({
  templateName: 'contact',

  events: {
    "click .contact_add-to-aspect" : "addContactToAspect",
    "click .contact_remove-from-aspect" : "removeContactFromAspect"
  },

  tooltipSelector: '.contact_add-to-aspect, .contact_remove-from-aspect',

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      person_id : this.model.get('person_id'),
      person : this.model.get('person'),
      in_aspect: (app.aspect && this.model.inAspect(app.aspect.get('id'))) ? 'in_aspect' : '',
    });
  },

  postRenderTemplate: function() {
    var dropdownEl = this.$('.aspect_membership_dropdown.placeholder');
    if( dropdownEl.length === 0 ) {
      return;
    }

    // TODO render me client side!!!
    var href = this.model.person.url() + '/aspect_membership_button?size=small';

    $.get(href, function(resp) {
      dropdownEl.html(resp);
      new app.views.AspectMembership({el: $('.aspect_dropdown',dropdownEl)});
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
