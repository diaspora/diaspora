app.views.SinglePostModeration = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-moderation",

  events: function() {
    return _.defaults({
      "click .remove_post": "destroyModel",
    }, app.views.Feedback.prototype.events);
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser(),
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
  }

});
