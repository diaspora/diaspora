// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.User = Backbone.Model.extend({
  toggleNsfwState : function() {
    if(!app.currentUser.authenticated()){ return false }
    this.set({showNsfw : !this.get("showNsfw")});
    this.trigger("nsfwChanged");
  },

  authenticated : function() {
    return !!this.id;
  },

  expProfileUrl : function(){
    return "/people/" + app.currentUser.get("guid") + "?ex=true";
  },

  isServiceConfigured : function(providerName) {
    return _.include(this.get("configured_services"), providerName);
  },

  isAuthorOf: function(model) {
    return this.authenticated() && model.get("author").id === this.id;
  }
});
// @license-end

