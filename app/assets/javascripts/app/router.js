// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.Router = Backbone.Router.extend({
  routes: {
    "activity(/)": "stream",
    "admin/pods(/)": "adminPods",
    "admins/dashboard(/)": "adminDashboard",
    "aspects(/)": "aspects",
    "commented(/)": "stream",
    "community_spotlight(/)": "spotlight",
    "contacts(/)": "contacts",
    "conversations(/)(:id)(?conversation_id=:conversation_id)(/)": "conversations",
    "followed_tags(/)": "followed_tags",
    "getting_started(/)": "gettingStarted",
    "help(/)": "help",
    "help/:section(/)": "help",
    "liked(/)": "stream",
    "mentions(/)": "stream",
    "notifications(/)": "notifications",
    "p/:id(/)": "singlePost",
    "people(/)": "peopleSearch",
    "people/:id(/)": "profile",
    "people/:id/photos(/)": "photos",
    "posts/:id(/)": "singlePost",
    "profile/edit(/)": "settings",
    "public(/)": "stream",
    "local_public(/)": "stream",
    "stream(/)": "stream",
    "tags/:name(/)": "followed_tags",
    "u/:name(/)": "profile",
    "user/edit(/)": "settings",
    "users/sign_up(/)": "registration"
  },

  initialize: function() {
    // To support encoded linefeeds (%0A) we need to specify
    // our own internal router.route call with the correct regexp.
    // see: https://github.com/diaspora/diaspora/issues/4994#issuecomment-46431124
    this.route(/^bookmarklet(?:\?(.*))?/, "bookmarklet");
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

  aspects: function() {
    app.aspectSelections = app.aspectSelections ||
      new app.collections.AspectSelections(app.currentUser.get("aspects"));
    this.aspectsList = this.aspectsList || new app.views.AspectsList({collection: app.aspectSelections});
    this.aspectsList.render();
    /* eslint-disable camelcase */
    this.aspects_stream();
    /* eslint-enable camelcase */
  },

  /* eslint-disable camelcase */
  aspects_stream: function() {
    /* eslint-enable camelcase */
    var ids = app.aspectSelections.selectedGetAttribute("id");
    /* eslint-disable camelcase */
    app.stream = new app.models.StreamAspects([], {aspects_ids: ids});
    /* eslint-enable camelcase */
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

  contacts: function(params) {
    app.aspect = new app.models.Aspect(gon.preloads.aspect);
    this._loadContacts();

    var stream = new app.views.ContactStream({
      collection: app.contacts,
      el: $(".stream.contacts #contact_stream"),
      urlParams: params
    });

    app.page = new app.pages.Contacts({stream: stream});
  },

  conversations: function(id, conversationId) {
    app.conversations = app.conversations || new app.views.ConversationsInbox(conversationId);
    if (parseInt("" + id, 10)) {
      app.conversations.renderConversation(id);
    }
  },

  /* eslint-disable camelcase */
  followed_tags: function(name) {
    /* eslint-enable camelcase */
    this.stream();

    app.tagFollowings = new app.collections.TagFollowings();
    this.followedTagsView = new app.views.TagFollowingList({collection: app.tagFollowings});
    $("#tags_list").replaceWith(this.followedTagsView.render().el);
    this.followedTagsView.setupAutoSuggest();

    app.tagFollowings.reset(gon.preloads.tagFollowings);

    if (name) {
      if (app.currentUser.authenticated()) {
        var followedTagsAction = new app.views.TagFollowingAction(
            {tagText: decodeURIComponent(name).toLowerCase()}
        );
        $("#author_info").prepend(followedTagsAction.render().el);
      }
      app.tags = new app.views.Tags({hashtagName: name});
    }
    this._hideInactiveStreamLists();
  },

  gettingStarted: function() {
    this.renderPage(function() {
      return new app.pages.GettingStarted({inviter: new app.models.Person(app.parsePreload("inviter"))});
    });
  },

  help: function(section) {
    app.help = new app.views.Help();
    $("#help").prepend(app.help.el);
    app.help.render(section);
  },

  notifications: function() {
    this._loadContacts();
    this.renderAspectMembershipDropdowns($(document));
    new app.views.Notifications({el: "#notifications_container", collection: app.notificationsCollection});
  },

  peopleSearch: function() {
    this._loadContacts();
    this.renderAspectMembershipDropdowns($(document));
    $(".invitations-link").click(function() {
      app.helpers.showModal("#invitationsModal");
    });
  },

  photos: function(guid) {
    this._loadContacts();
    this.renderPage(function() {
      return new app.pages.Profile({
        /* eslint-disable camelcase */
        person_id: guid,
        /* eslint-enable camelcase */
        el: $("body > #profile_container"),
        streamCollection: app.collections.Photos,
        streamView: app.views.Photos
      });
    });
  },

  profile: function() {
    this._loadContacts();
    this.renderPage(function() {
      return new app.pages.Profile({
        el: $("body > #profile_container")
      });
    });
  },

  settings: function() {
    app.page = new app.pages.Settings();
  },

  singlePost: function(id) {
    this.renderPage(function() { return new app.pages.SinglePostViewer({id: id, el: $("#container")}); });
  },

  spotlight: function() {
    $(".invitations-button").click(function() {
      app.helpers.showModal("#invitationsModal");
    });
  },

  stream: function() {
    app.stream = new app.models.Stream();
    app.stream.fetch();
    this._initializeStreamView();
  },

  _hideInactiveStreamLists: function() {
    if (this.aspectsList && Backbone.history.fragment !== "aspects") {
      this.aspectsList.hideAspectsList();
    }

    if (this.followedTagsView && Backbone.history.fragment !== "followed_tags") {
      this.followedTagsView.hideFollowedTags();
    }
  },

  _initializeStreamView: function() {
    if (app.page) {
      app.page.unbindInfScroll();
      app.page.remove();
    }

    app.page = new app.views.Stream({model: app.stream});
    app.shortcuts = app.shortcuts || new app.views.StreamShortcuts({el: $(document)});
    if ($("#publisher").length !== 0) {
      app.publisher = app.publisher || new app.views.Publisher({collection: app.stream.items});
      app.page.setupAvatarFallback($(".main-stream-publisher"));
    }

    $("#main-stream").html(app.page.render().el);
    this._hideInactiveStreamLists();
  },

  _loadContacts: function() {
    app.contacts = new app.collections.Contacts(app.parsePreload("contacts"));
  },

  renderAspectMembershipDropdowns: function($context) {
    $context.find(".aspect-membership-dropdown.placeholder").each(function() {
      var personId = $(this).data("personId");
      var view = new app.views.AspectMembership({person: app.contacts.findWhere({"person_id": personId}).person});
      $(this).html(view.render().$el);
    });
  },

  renderPage: function(pageConstructor) {
    // old page might mutate global events $(document).keypress, so unbind before creating
    app.page && app.page.unbind && app.page.unbind();
    // create new page after the world is clean (like that will ever happen)
    app.page = pageConstructor();
    app.page.render();

    if (!$.contains(document, app.page.el)) {
      // view element isn"t already attached to the DOM, insert it
      $("#container").empty().append(app.page.el);
    }
  }
});
// @license-end
