app.views.Post = app.views.Base.extend({
  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser(),
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  authorIsCurrentUser : function() {
    return app.currentUser.authenticated() && this.model.get("author").id == app.user().id
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw")
  },

  report: function(evt) {
    if(evt) { evt.preventDefault(); }
    var report = new app.models.Report();
    var msg = report.getReason();
    if (msg !== null) {
      var id = this.model.id;
      var type = $(evt.currentTarget).data("type");
      report.fetch({
        data: { id: id, type: type, text: msg },
        type: 'POST'
      });
    }
  }

});
