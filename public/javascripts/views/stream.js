App.Views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "loadMore"
  },

  initialize: function(){
    this.el = $("#main_stream");
    _.bindAll(this, "appendPost", "collectionFetched");

    this.collection = new App.Collections.Stream;
    this.collection.bind("add", this.appendPost);

    this.loadMore();
  },

  appendPost: function(post) {
    $(this.el).append(new App.Views.Post({
      model: post
    }).render());
  },

  collectionFetched: function() {
    this.$("#paginate").remove();
    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate"
    }).text('more'));
  },

  loadMore: function(evt) {
    if(evt) { evt.preventDefault(); }

    this.collection.fetch({
      add: true,
      success: this.collectionFetched
    });
  }
});
