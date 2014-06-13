app.views.Feedback = app.views.Base.extend({
  templateName: "feedback",

  className : "info",

  events: {
    "click .like" : "toggleLike",
    "click .reshare" : "resharePost",
    "click .post_report" : "report"
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

    if (this.model.get("public")) {
      aspect_names = Diaspora.I18n.t("stream.public_long");
    }
    else if (!aspect_ids || aspect_ids.length === 0) {
      aspect_names = Diaspora.I18n.t("stream.nobody");
    }
    else if (aspect_ids === "all_aspects") {
      aspect_names = app.aspects.map(function(aspect){
        return aspect.get("name");
      })
      aspect_names = aspect_names.join(', ');
    }
    else {
      for (var id of aspect_ids) {
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
  }
});
