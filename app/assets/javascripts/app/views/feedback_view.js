// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Feedback = app.views.Base.extend({
  templateName: "feedback",

  className : "info",

  events: {
    "click .like" : "toggleLike",
    "click .reshare" : "resharePost",

    "click .post_report" : "report",
    "click .block_user" : "blockUser",
    "click .hide_post" : "hidePost",
  },

  tooltipSelector : ".label",

  initialize : function() {
    this.model.interactions.on('change', this.render, this);
    this.initViews && this.initViews() // I don't know why this was failing with $.noop... :(
  },

  presenter : function() {
    var interactions = this.model.interactions;

    return _.extend(this.defaultPresenter(),{
      aspectNames : this.aspectNames(),
      commentsCount : interactions.commentsCount(),
      likesCount : interactions.likesCount(),
      resharesCount : interactions.resharesCount(),
      userCanReshare : interactions.userCanReshare(),
      userLike : interactions.userLike(),
      userReshare : interactions.userReshare()
    });
  },

  aspectNames: function() {
    var aspect_ids = this.model.get("aspect_ids");
    var aspect_names = [];

    if (this.model.get("public") || !aspect_ids || aspect_ids.length === 0) {
      return []; 
    }
    else if (aspect_ids === "all_aspects" || aspect_ids.length === app.aspects.length) {
      aspect_names = Diaspora.I18n.t("aspect_dropdown.all_aspects");
    }
    else {
      for (var i=0; i<aspect_ids.length; i++) {
        var id = aspect_ids[i];
        var aspect = app.aspects.get(id);

        aspect_names.push(aspect.get("name"));
      }
      aspect_names = aspect_names.join(', ');
    }

    return aspect_names;
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.interactions.toggleLike();
  },

  resharePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!window.confirm(Diaspora.I18n.t("reshares.post", {name: this.model.reshareAuthor().name}))) { return }
    this.model.interactions.reshare();
  },

  blockUser: function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('ignore_user'))) { return; }

    this.model.blockAuthor()
      .done(function() {
        // return to stream
        document.location.href = "/stream";
      })
      .fail(function() {
        Diaspora.page.flashMessages.render({
          success: false,
          notice: Diaspora.I18n.t('hide_post_failed')
        });
      });
  },

  hidePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('hide_post'))) { return; }

    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    }).done(function() {
        // return to stream
        document.location.href = "/stream";
      })
      .fail(function() {
        Diaspora.page.flashMessages.render({
          success: false,
          notice: Diaspora.I18n.t('ignore_post_failed')
        });
      });
  },
});
// @license-end

