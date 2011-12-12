App.Views.PostContent = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($(this.template_name).html());
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    return this;
  }
});


App.Views.StatusMessage = App.Views.PostContent.extend({
  template_name : "#status-message-template"
});

App.Views.Reshare = App.Views.PostContent.extend({
  template_name : "#reshare-template"
});

App.Views.ActivityStreams__Photo = App.Views.PostContent.extend({
  template_name : "#activity-streams-photo-template"
});
