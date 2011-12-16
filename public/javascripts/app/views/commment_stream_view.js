App.Views.CommentStream = Backbone.View.extend({
  events: {
    "submit form": "createComment",
    "focus .comment_box": "commentTextareaFocused",
    "click .toggle_post_comments": "expandComments"
  },

  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#comment-stream-template").html());

    _.bindAll(this, "appendComment");
    this.model.comments.bind('add', this.appendComment, this);
  },

  render: function() {
    $(this.el).html(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    this.$("label").inFieldLabels();

    this.model.comments.each(this.appendComment);

    return this;
  },

  createComment: function(evt) {
    evt.preventDefault();

    this.model.comments.create({
      "text" : this.$(".comment_box").val(),
      "post_id" : this.model.id
    });

    this.$(".comment_box").val("");
    return this;
  },

  appendComment: function(comment) {
    this.$("ul.comments").append(new App.Views.Comment({
      model: comment
    }).render().el);
  },

  commentTextareaFocused: function(evt){
    this.$("form").removeClass('hidden').addClass("open");
  },

  expandComments: function(evt){
    if(evt){ evt.preventDefault(); }

    var self = this;
    this.model.comments.fetch({
      success : function(){
        self.model.set({all_comments_loaded : true});
        self.render();
      }
    });
  }

});
