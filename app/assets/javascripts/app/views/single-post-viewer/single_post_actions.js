app.views.SinglePostActions = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-actions",

  events: function() {
    return _.defaults({
      "click .focus-comment" : "focusComment",
      "click .delete-post" : "deletePost",
      "click .hide-post" : "hidePost",
      "click .ignore-user" : "ignoreUser",
    }, app.views.Feedback.prototype.events);
  },

  presenter: function() {
    //still need to keep presenter variables from app.views.Feedback.
    return _.extend(app.views.Feedback.prototype.presenter.apply(this), {
      authorIsCurrentUser: this.authorIsCurrentUser(),
    });
  },

  renderPluginWidgets : function() {
    app.views.Base.prototype.renderPluginWidgets.apply(this);
    this.$('a').tooltip({placement: 'bottom'});
  },

  focusComment: function() {
    $('.comment_stream .comment_box').focus();
    $('html,body').animate({scrollTop: $('.comment_stream .comment_box').offset().top - ($('.comment_stream .comment_box').height() + 20)});
    return false;
  },

  deletePost: function(evt) {
    //can't use standard destroyModel here because its callbacks don't make sense
    //for spv. Creating custom one here.
    var self = this;

    if(evt) { evt.preventDefault(); }
    if (confirm(Diaspora.I18n.t("confirm_dialog"))) {
      this.model.destroy()
        .done(function() {
          self.redirectToStream();
        })
        .fail(function() {
          var flash = new Diaspora.Widgets.FlashMessages;
          flash.render({
            success: false,
            notice: Diaspora.I18n.t('failed_to_remove')
          });
        });
    }
  },

  hidePost: function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('confirm_dialog'))) { return; }

    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    });

    this.redirectToStream();
  },

  ignoreUser: function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('ignore_user'))) { return; }

    var personId = this.model.get("author").id;
    var block = new app.models.Block();

    var self = this;

    block.save({block : {person_id : personId}}, {
      success : function(){
        self.redirectToStream();
      }
    })
  },

  redirectToStream : function () {
    //IE8 does not support window.location.origin so
    //using window.location.protocol + "//" + window.location.host instead.
    window.location.href = window.location.protocol + "//" + window.location.host + "/stream";
  },

  authorIsCurrentUser : function () {
    return app.currentUser.authenticated() && this.model.get("author").id == app.user().id;
  },

});
