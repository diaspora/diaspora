// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.Contact = Backbone.Model.extend({
  initialize : function() {
    this.aspect_memberships = new app.collections.AspectMemberships(this.get('aspect_memberships'));
    if( this.get('person') ) this.person = new app.models.Person(this.get('person'));
  },

  inAspect : function(id) {
    return this.aspect_memberships.any(function(membership){ return membership.get('aspect').id === id; });
  }
});
// @license-end
