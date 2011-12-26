App.Views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "loadMore"
  },

  initialize: function() {
    _.bindAll(this, "collectionFetched");

    this.collection = this.collection || new App.Collections.Stream;
    this.collection.bind("add", this.appendPost, this);
  },

  render : function(){
    _.each(this.collection.models, this.appendPost, this)
    return this;
  },

  appendPost: function(post) {
    var postView = new App.Views.Post({ model: post });
    $(this.el).append(postView.render().el);
  },

  collectionFetched: function() {
    this.$("#paginate").remove();
    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate"
    }).text('Load more posts'));
  },

  loadMore: function(evt) {
    if(evt) { evt.preventDefault(); }

    this.addLoader();
    this.collection.fetch({
      add: true,
      success: this.collectionFetched
    });
  },

  addLoader: function(){
    this.$("#paginate").html($("<img>", {
      src : "/images/static-loader.png",
      "class" : 'loader'
    }));
  }
});
