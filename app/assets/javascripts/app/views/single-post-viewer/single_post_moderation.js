app.views.SinglePostModeration = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-moderation",

  className: 'control-icons',

  events: function() {
    return _.defaults({
      "click .remove_post": "destroyModel",
      "click .create_participation": "createParticipation",
      "click .destroy_participation": "destroyParticipation"
    }, app.views.Feedback.prototype.events);
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser()
    });
  },

  renderPluginWidgets : function() {
    app.views.Base.prototype.renderPluginWidgets.apply(this);
    this.$('a').tooltip({placement: 'bottom'});
  },

  authorIsCurrentUser: function() {
    return app.currentUser.authenticated() && this.model.get("author").id === app.user().id;
  },

  destroyModel: function(evt) {
    if(evt) { evt.preventDefault(); }
    var url = this.model.urlRoot + '/' + this.model.id;

    if (confirm(Diaspora.I18n.t("remove_post"))) {
      this.model.destroy({ url: url })
        .done(function() {
          // return to stream
          document.location.href = "/stream";
        })
        .fail(function() {
          var flash = new Diaspora.Widgets.FlashMessages();
          flash.render({
            success: false,
            notice: Diaspora.I18n.t('failed_to_remove')
          });
        });
    }
  },

  createParticipation: function (evt) {
    if(evt) { evt.preventDefault(); }
    var self = this;
    $.post(Routes.post_participation_path(this.model.get("id")), {}, function () {
      self.model.set({participation: true});
      self.render();
    });
  },

  destroyParticipation: function (evt) {
    if(evt) { evt.preventDefault(); }
    var self = this;
    $.post(Routes.post_participation_path(this.model.get("id")), { _method: "delete" }, function () {
      self.model.set({participation: false});
      self.render();
    });
  },

  participation: function(){ return this.model.get("participation"); }
});
