// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.Router = Backbone.Router.extend({
  routes: {
    "help/:section": "help",
    "help/": "help",
    "help": "help",
    "getting_started": "gettingStarted",
    "contacts": "contacts",
    "conversations": "conversations",
    "user/edit": "settings",
    "users/sign_up": "registration",
    "profile/edit": "settings",
    "admins/dashboard": "adminDashboard",
    "admin/pods": "adminPods",

    "posts/:id": "singlePost",
    "p/:id": "singlePost",

    "activity": "stream",
    "stream": "stream",
    "aspects": "aspects",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "public": "stream",
    "followed_tags": "followed_tags",
    "tags/:name": "followed_tags",
    "people/:id/photos": "photos",
    "people/:id/contacts": "profile",
    "people": "pageWithAspectMembershipDropdowns",
    "notifications": "pageWithAspectMembershipDropdowns",

    "people/:id": "profile",
    "u/:name": "profile"
  },

  initialize: function() {
    // To support encoded linefeeds (%0A) we need to specify
    // our own internal router.route call with the correct regexp.
    // see: https://github.com/diaspora/diaspora/issues/4994#issuecomment-46431124
    this.route(/^bookmarklet(?:\?(.*))?/, "bookmarklet");
  },

  help: function(section) {
    app.help = new app.views.Help();
    $("#help").prepend(app.help.el);
    app.help.render(section);
  },

  adminDashboard: function() {
    app.page = new app.pages.AdminDashboard();
  },

  adminPods: function() {
    this.renderPage(function() {
      return new app.pages.AdminPods({
        el: $("#pod-list")
      });
    });
  },

  contacts: function() {
    app.aspect = new app.models.Aspect(gon.preloads.aspect);
    this._loadRelationshipsPreloads();

    var stream = new app.views.ContactStream({
      collection: app.contacts,
      el: $(".stream.contacts #contact_stream"),
    });

    app.page = new app.pages.Contacts({stream: stream});
  },

  gettingStarted: function() {
    this._loadAspects();
    this.renderPage(function() {
      return new app.pages.GettingStarted({inviter: new app.models.Person(app.parsePreload("inviter"))});
    });
  },

  conversations: function() {
    app.conversations = new app.views.Conversations();
  },

  registration: function() {
    app.page = new app.pages.Registration();
  },

  settings: function() {
    app.page = new app.pages.Settings();
  },

  singlePost : function(id) {
    this.renderPage(function(){ return new app.pages.SinglePostViewer({ id: id })});
  },

  renderPage : function(pageConstructor){
    app.page && app.page.unbind && app.page.unbind(); //old page might mutate global events $(document).keypress, so unbind before creating
    app.page = pageConstructor(); //create new page after the world is clean (like that will ever happen)
    app.page.render();

    if( !$.contains(document, app.page.el) ) {
      // view element isn"t already attached to the DOM, insert it
      $("#container").empty().append(app.page.el);
    }
  },

  stream : function() {
    this._loadAspects();
    app.stream = new app.models.Stream();
    app.stream.fetch();
    this._initializeStreamView();
  },

  photos : function(guid) {
    this.renderPage(function() {
      return new app.pages.Profile({
        person_id: guid,
        el: $("body > #profile_container"),
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
      $("#author_info").prepend(followedTagsAction.render().el);
      app.tags = new app.views.Tags({hashtagName: name});
    }
    this._hideInactiveStreamLists();
  },

  aspects: function() {
    this._loadAspects();
    app.aspectSelections = app.aspectSelections ||
      new app.collections.AspectSelections(app.currentUser.get("aspects"));
    this.aspectsList = this.aspectsList || new app.views.AspectsList({collection: app.aspectSelections});
    this.aspectsList.render();
    this.aspects_stream();
  },

  aspects_stream : function(){
    var ids = app.aspectSelections.selectedGetAttribute("id");
    app.stream = new app.models.StreamAspects([], { aspects_ids: ids });
    app.stream.fetch();
    this._initializeStreamView();
    app.publisher.setSelectedAspects(ids);
  },

  bookmarklet: function() {
    var contents = (window.gon) ? gon.preloads.bookmarklet : {};
    app.bookmarklet = new app.views.Bookmarklet(
      _.extend({}, {el: $("#bookmarklet")}, contents)
    ).render();
  },

  profile: function() {
    this._loadRelationshipsPreloads();
    this.renderPage(function() {
      return new app.pages.Profile({
        el: $("body > #profile_container")
      });
    });
  },

  pageWithAspectMembershipDropdowns: function() {
    this._loadRelationshipsPreloads();
    this.renderAspectMembershipDropdowns($(document));
  },

  _loadAspects: function() {
    app.aspects = new app.collections.Aspects(app.currentUser.get("aspects"));
  },

  _loadContacts: function() {
    app.contacts = new app.collections.Contacts(app.parsePreload("contacts"));
  },

  _loadRelationshipsPreloads: function() {
    this._loadContacts();
    this._loadAspects();
  },

  renderAspectMembershipDropdowns: function($context) {
    $context.find(".aspect_membership_dropdown.placeholder").each(function() {
      var personId = $(this).data("personId");
      var view = new app.views.AspectMembership({person: app.contacts.findWhere({"person_id": personId}).person});
      $(this).html(view.render().$el);
    });
  },

  _hideInactiveStreamLists: function() {
    if(this.aspectsList && Backbone.history.fragment !== "aspects") {
      this.aspectsList.hideAspectsList();
    }

    if(this.followedTagsView && Backbone.history.fragment !== "followed_tags") {
      this.followedTagsView.hideFollowedTags();
    }
  },

  _initializeStreamView: function() {
    if(app.page) {
      app.page.unbindInfScroll();
      app.page.remove();
    }

    app.page = new app.views.Stream({model : app.stream});
    app.shortcuts = app.shortcuts || new app.views.StreamShortcuts({el: $(document)});
    if($("#publisher").length !== 0) {
      app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});
    }

    $("#main_stream").html(app.page.render().el);
    this._hideInactiveStreamLists();
  }
});
// @license-end
