// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/**
 * this model represents the assignment of an aspect to a person.
 * (only valid for the context of the current user)
 */
app.models.AspectMembership = Backbone.Model.extend({
  urlRoot: "/aspect_memberships",

  belongsToAspect: function(aspectId) {
    var aspect = this.get("aspect");
    return aspect && aspect.id === aspectId;
  }
});
// @license-end
