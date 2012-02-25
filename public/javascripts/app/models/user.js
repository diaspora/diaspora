app.models.User = Backbone.Model.extend({
  toggleNsfwState : function() {
    if(!app.currentUser.authenticated()){ return false }
    this.set({showNsfw : !this.get("showNsfw")});
    this.trigger("nsfwChanged");
  },

  authenticated : function() {
    return !!this.id;
  }
});
