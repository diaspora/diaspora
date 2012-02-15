app.models.User = Backbone.Model.extend({
  toggleNsfwState : function() {
    this.set({showNsfw : !this.get("showNsfw")});
    this.trigger("nsfwChanged");
  }
});
