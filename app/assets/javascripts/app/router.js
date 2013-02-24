app.Router = Backbone.Router.extend({
  routes: {
    //new hotness
    "posts/:id": "singlePost",
    "posts/:id/next": "siblingPost",
    "posts/:id/previous": "siblingPost",
    "p/:id": "singlePost",

    //oldness
    "activity": "stream",
    "stream": "stream",
    "participate": "stream",
    "explore": "stream",
    "aspects": "aspects",
    "aspects/stream": "aspects_stream",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "followed_tags": "followed_tags",
    "tags/:name": "followed_tags",
    "people/:id/photos": "photos",

    "people/:id": "stream",
    "u/:name": "stream"
  },

  singlePost : function(id) {
    this.renderPage(function(){ return new app.pages.PostViewer({ id: id })});
  },

  siblingPost : function(){ //next or previous
    var post = new app.models.Post();
    post.bind("change", setPreloadAttributesAndNavigate)
    post.fetch({url : window.location})

    function setPreloadAttributesAndNavigate(){
      window.preloads.post = post.attributes
      app.router.navigate(post.url(), {trigger:true, replace: true})
    }
  },

  renderPage : function(pageConstructor){
    app.page && app.page.unbind && app.page.unbind() //old page might mutate global events $(document).keypress, so unbind before creating
    app.page = pageConstructor() //create new page after the world is clean (like that will ever happen)
    $("#container").html(app.page.render().el)
  },

  //below here is oldness

  stream : function(page) {
    app.stream = new app.models.Stream();
    app.stream.fetch();
    app.page = new app.views.Stream({model : app.stream});
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.items});

    $("#main_stream").html(app.page.render().el);
    $('#selected_aspect_contacts .content').html(streamFacesView.render().el);
  },

  photos : function() {
    app.photos = new app.models.Stream([], {collection: app.collections.Photos});
    app.page = new app.views.Photos({model : app.photos});
    $("#main_stream").html(app.page.render().el);
  },

  followed_tags : function(name) {
    this.stream();

    app.tagFollowings = new app.collections.TagFollowings();
    var followedTagsView = new app.views.TagFollowingList({collection: app.tagFollowings});
    $("#tags_list").replaceWith(followedTagsView.render().el);
    followedTagsView.setupAutoSuggest();

    app.tagFollowings.reset(preloads.tagFollowings);

    if(name) {
      var followedTagsAction = new app.views.TagFollowingAction(
            {tagText: name}
          );
      $("#author_info").prepend(followedTagsAction.render().el)
    }
  },

  aspects : function(){
    app.aspects = new app.collections.Aspects(app.currentUser.get('aspects'));
    var aspects_list =  new app.views.AspectsList({ collection: app.aspects });
    aspects_list.render();
    this.aspects_stream();
  },

  aspects_stream : function(){

    var ids = app.aspects.selectedAspects('id');
    app.stream = new app.models.StreamAspects([], { aspects_ids: ids });
    app.stream.fetch();

    app.page = new app.views.Stream({model : app.stream});
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});
    app.publisher.updateAspectsSelector(ids);

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.items});

    $("#main_stream").html(app.page.render().el);
    $('#selected_aspect_contacts .content').html(streamFacesView.render().el);
  }
});

