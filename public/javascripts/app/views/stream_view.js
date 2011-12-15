App.Views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "loadMore"
  },

  initialize: function() {
    _.bindAll(this, "appendPost", "collectionFetched", "loadMore");

    this.collection = this.collection || new App.Collections.Stream;
    this.collection.bind("add", this.appendPost);
  },

  render : function(){
    _.each(this.collection.models, this.appendPost)
    return this;
  },

  appendPost: function(post) {
    var postView = new App.Views.Post({ model: post }).render();
    $(this.el).append(postView.el);
  },

  collectionFetched: function() {
    this.$("#paginate").remove();
    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate",
      "class": "paginate"
    }).text('more'));
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
      src : "/images/ajax-loader.gif"
    }));
  }
});
