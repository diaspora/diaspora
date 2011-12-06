App.Views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "loadMore"
  },

  initialize: function(){
    this.el = $("#main_stream");
    this.template = _.template($("#stream-element-template").html());

    _.bindAll(this, "appendPost", "collectionFetched");

    this.collection = new App.Collections.Stream;
    this.collection.bind("add", this.appendPost);
    this.loadMore();
  },

  appendPost: function(model) {
    var post = $(this.template($.extend(
      model.toJSON(),
      App.user()
    )));
    $(this.el).append(post);
    Diaspora.BaseWidget.instantiate("StreamElement", post);
  },

  collectionFetched: function() {
    this.$(".details time").timeago();
    this.$("label").inFieldLabels();

    this.$("#paginate").remove();
    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate"
    }).text('more'));
  },

  loadMore: function(evt) {
    if(evt) {
      evt.preventDefault();
    }

    this.collection.fetch({
      add: true,
      success: this.collectionFetched
    });
  }
});
