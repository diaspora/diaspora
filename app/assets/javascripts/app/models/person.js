// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.Person = Backbone.Model.extend({
  url: function() {
    return Routes.person(this.get("guid"));
  },

  initialize: function() {
    if (this.get("profile")) {
      this.profile = new app.models.Profile(this.get("profile"));
    }
    if (this.get("contact")) {
      this.contact = new app.models.Contact(this.get("contact"));
      this.contact.person = this;
    }
  },

  isSharing: function() {
    var rel = this.get('relationship');
    return (rel === 'mutual' || rel === 'sharing');
  },

  isReceiving: function() {
    var rel = this.get('relationship');
    return (rel === 'mutual' || rel === 'receiving');
  },

  isMutual: function() {
    return (this.get('relationship') === 'mutual');
  },

  isBlocked: function() {
    return (this.get("block") !== false);
  },

  block: function() {
    var self = this;
    var block = new app.models.Block({block: {person_id: this.id}});

    // return the jqXHR with Promise interface
    return block.save()
      .done(function() { app.events.trigger('person:block:'+self.id); });
  },

  unblock: function() {
    var self = this;
    if( !this.get('block') ) {
      var def = $.Deferred();
      return def.reject();
    }

    var block = new app.models.Block({id: this.get('block').id});
    return block.destroy()
      .done(function() { app.events.trigger('person:unblock:'+self.id); });
  }
});
// @license-end

