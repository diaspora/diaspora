// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//require ../post

app.models.Post.Interactions = Backbone.Model.extend({
  url : function(){
    return this.post.url() + "/interactions"
  },

  initialize : function(options){
    this.post = options.post
    this.comments = new app.collections.Comments(this.get("comments"), {post : this.post})
    this.likes = new app.collections.Likes(this.get("likes"), {post : this.post});
    this.reshares = new app.collections.Reshares(this.get("reshares"), {post : this.post});
  },

  parse : function(resp){
    this.comments.reset(resp.comments)
    this.likes.reset(resp.likes)
    this.reshares.reset(resp.reshares)

    var comments = this.comments
      , likes = this.likes
      , reshares = this.reshares

    return {
      comments : comments,
      likes : likes,
      reshares : reshares,
      fetched : true
    }
  },

  likesCount : function(){
    return (this.get("fetched") ? this.likes.models.length : this.get("likes_count") )
  },

  resharesCount : function(){
    return this.get("fetched") ? this.reshares.models.length : this.get("reshares_count")
  },

  commentsCount : function(){
    return this.get("fetched") ? this.comments.models.length : this.get("comments_count")
  },

  userLike : function(){
    return this.likes.select(function(like){ return like.get("author").guid == app.currentUser.get("guid")})[0]
  },

  userReshare : function(){
    return this.reshares.select(function(reshare){
      return reshare.get("author") &&  reshare.get("author").guid == app.currentUser.get("guid")})[0]
  },

  toggleLike : function() {
    if(this.userLike()) {
      this.unlike()
    } else {
      this.like()
    }
  },

  like : function() {
    var self = this;
    this.likes.create({}, {success : function(){
      self.trigger("change")
      self.set({"likes_count" : self.get("likes_count") + 1})
    }})

    app.instrument("track", "Like")
  },

  unlike : function() {
    var self = this;
    this.userLike().destroy({success : function(model, resp) {
      self.trigger('change')
      self.set({"likes_count" : self.get("likes_count") - 1})
    }});

    app.instrument("track", "Unlike")
  },

  comment : function (text) {
    var self = this;

    this.comments.make(text).fail(function () {
      flash = new Diaspora.Widgets.FlashMessages;
      flash.render({
        success: false,
        notice: Diaspora.I18n.t("failed_to_post_message")
      });
    }).done(function() {
      self.trigger('change') //updates after sync
    });

    this.trigger("change") //updates count in an eager manner

    app.instrument("track", "Comment")
  },

  reshare : function(){
    var interactions = this
      , reshare = this.post.reshare()
      , flash = new Diaspora.Widgets.FlashMessages;

    reshare.save({}, {
      success : function(resp){
        flash.render({
          success: true,
          notice: Diaspora.I18n.t("reshares.successful")
        });
      },
      error: function(resp){
        flash.render({
          success: false,
          notice: Diaspora.I18n.t("reshares.duplicate")
        });
      }
    }).done(function(){
        interactions.reshares.add(reshare)
      }).done(function(){
        interactions.trigger("change")
      });

    app.instrument("track", "Reshare")
  },

  userCanReshare : function(){
    var isReshare = this.post.get("post_type") == "Reshare"
      , rootExists = (isReshare ? this.post.get("root") : true)
      , publicPost = this.post.get("public")
      , userIsNotAuthor = this.post.get("author").diaspora_id != app.currentUser.get("diaspora_id")
      , userIsNotRootAuthor = rootExists && (isReshare ? this.post.get("root").author.diaspora_id != app.currentUser.get("diaspora_id") : true)
      , notReshared = !this.userReshare();

    return publicPost && app.currentUser.authenticated() && userIsNotAuthor && userIsNotRootAuthor && notReshared;
  }
});
// @license-end

