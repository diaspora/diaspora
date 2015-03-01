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
    var self = this;
    var dropdownEl = this.$('.aspect_membership_dropdown.placeholder');
    if( dropdownEl.length === 0 ) {
      return;
    }

    // TODO render me client side!!!
    var href = this.model.person.url() + '/aspect_membership_button?size=small';

    $.get(href, function(resp) {
      dropdownEl.html(resp);
      new app.views.AspectMembership({el: $('.aspect_dropdown',dropdownEl)});

      // UGLY (re-)attach the facebox
      self.$('a[rel*=facebox]').facebox();
    });
  },

  addContactToAspect: function(){
    var self = this;
    this.model.aspect_memberships.create({
      'person_id': this.model.get('person_id'),
      'aspect_id': app.aspect.get('id')
    },{
      success: function(){
        self.render();
      },
      error: function(){
        var msg = Diaspora.I18n.t('contacts.error_add', { 'name': self.model.get('person').name });
        Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
      }
    });
  },

  removeContactFromAspect: function(){
    var self = this;
    this.model.aspect_memberships
      .find(function(membership){ return membership.get('aspect').id === app.aspect.id; })
      .destroy({
        success: function(){
          self.render();
        },
        error: function(){
          var msg = Diaspora.I18n.t('contacts.error_remove', { 'name': self.model.get('person').name });
          Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
        }
      });
  }
});
// @license-end
