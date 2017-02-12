// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.TagFollowingAction = app.views.Base.extend({

  templateName: "tag_following_action",

  events : {
    "mouseenter .btn.followed": "mouseIn",
    "mouseleave .btn.followed": "mouseOut",
    "click .btn": "tagAction"
  },

  initialize : function(options){
    this.tagText = options.tagText;
    this.getTagFollowing();
    app.tagFollowings.bind("remove add", this.getTagFollowing, this);
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      tag_is_followed : this.tag_is_followed(),
      followString : this.followString()
    });
  },

  followString : function() {
    if(this.tag_is_followed()) {
      return Diaspora.I18n.t("stream.tags.following", {"tag" : this.model.attributes.name});
    } else {
      return Diaspora.I18n.t("stream.tags.follow", {"tag" : this.model.attributes.name});
    }
  },

  tag_is_followed : function() {
    return !this.model.isNew();
  },

  getTagFollowing : function() {
    this.model = app.tagFollowings.where({"name":this.tagText})[0] ||
        new app.models.TagFollowing({"name":this.tagText});
    this.model.bind("change", this.render, this);
    this.render();
  },

  mouseIn : function(){
    this.$("input").removeClass("btn-success").addClass("btn-danger");
    this.$("input").val( Diaspora.I18n.t('stream.tags.stop_following', {tag: this.model.attributes.name} ) );
  },

  mouseOut : function() {
    this.$("input").removeClass("btn-danger").addClass("btn-success");
    this.$("input").val( Diaspora.I18n.t('stream.tags.following', {"tag" : this.model.attributes.name} ) );
  },

  tagAction : function(evt){
    if(evt){ evt.preventDefault(); }

    if(this.tag_is_followed()) {
      this.model.destroy();
    } else {
      app.tagFollowings.create(this.model);
    }
  }
});
// @license-end
