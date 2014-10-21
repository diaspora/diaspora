// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.Router = Backbone.Router.extend({
  routes: {
    "help": "help",
    "contacts": "contacts",
    "conversations": "conversations",

    //new hotness
    "posts/:id": "singlePost",
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
    "people/:id/contacts": "profile",

    "people/:id": "profile",
    "u/:name": "profile"
  },

  initialize: function() {
    // To support encoded linefeeds (%0A) we need to specify
    // our own internal router.route call with the correct regexp.
    // see: https://github.com/diaspora/diaspora/issues/4994#issuecomment-46431124
    this.route(/^bookmarklet(?:\?(.*))?/, "bookmarklet");
  },

  help: function() {
    app.help = new app.views.Help();
    $("#help").prepend(app.help.el);
    app.help.render();
  },

  contacts: function() {
    app.contacts = new app.views.Contacts();
  },

  conversations: function() {
    app.conversations = new app.views.Conversations();
  },

  singlePost : function(id) {
    this.renderPage(function(){ return new app.pages.SinglePostViewer({ id: id })});
  },

  renderPage : function(pageConstructor){
    app.page && app.page.unbind && app.page.unbind(); //old page might mutate global events $(document).keypress, so unbind before creating
    app.page = pageConstructor(); //create new page after the world is clean (like that will ever happen)
    app.page.render();

    if( !$.contains(document, app.page.el) ) {
      // view element isn't already attached to the DOM, insert it
      $("#container").empty().append(app.page.el);
    }
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
    this._hideInactiveStreamLists();
  },

  photos : function(guid) {
    this.renderPage(function() {
      return new app.pages.Profile({
        person_id: guid,
        el: $('body > .container-fluid'),
        streamCollection: app.collections.Photos,
        streamView: app.views.Photos
      });
    });
  },

  followed_tags : function(name) {
    this.stream();

    app.tagFollowings = new app.collections.TagFollowings();
    this.followedTagsView = new app.views.TagFollowingList({collection: app.tagFollowings});
    $("#tags_list").replaceWith(this.followedTagsView.render().el);
    this.followedTagsView.setupAutoSuggest();

    app.tagFollowings.reset(gon.preloads.tagFollowings);

    if(name) {
      var followedTagsAction = new app.views.TagFollowingAction(
            {tagText: decodeURIComponent(name).toLowerCase()}
          );
      $("#author_info").prepend(followedTagsAction.render().el)
    }
    this._hideInactiveStreamLists();
  },

  aspects : function(){
    app.aspects = new app.collections.Aspects(app.currentUser.get('aspects'));
    this.aspects_list =  new app.views.AspectsList({ collection: app.aspects });
    this.aspects_list.render();
    this.aspects_stream();
  },

  aspects_stream : function(){
    var ids = app.aspects.selectedAspects('id');
    app.stream = new app.models.StreamAspects([], { aspects_ids: ids });
    app.stream.fetch();

    app.page = new app.views.Stream({model : app.stream});
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});
    app.publisher.setSelectedAspects(ids);

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.items});

    $("#main_stream").html(app.page.render().el);
    $('#selected_aspect_contacts .content').html(streamFacesView.render().el);
    this._hideInactiveStreamLists();
  },

  _hideInactiveStreamLists: function() {
    if(this.aspects_list && Backbone.history.fragment != "aspects")
      this.aspects_list.hideAspectsList();

    if(this.followedTagsView && Backbone.history.fragment != "followed_tags")
      this.followedTagsView.hideFollowedTags();
  },

  bookmarklet: function() {
    var contents = (window.gon) ? gon.preloads.bookmarklet : {}
    app.bookmarklet = new app.views.Bookmarklet(
      _.extend({}, {el: $('#bookmarklet')}, contents)
    ).render();
  },

  profile: function() {
    this.renderPage(function() { return new app.pages.Profile({
      el: $('body > .container-fluid')
    }); });
  }
});
// @license-end

