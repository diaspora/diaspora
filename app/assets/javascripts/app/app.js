// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require_self
//= require_tree ./helpers

//= require ./router
//= require ./models

//= require ./views
//= require ./views/infinite_stream_view

//= require_tree ./models
//= require_tree ./pages
//= require_tree ./collections
//= require_tree ./views

//= require utatti-perfect-scrollbar/dist/perfect-scrollbar

var app = {
  collections: {},
  models: {},
  helpers: {},
  views: {},
  pages: {},
  forms: {},

  // global event broker - use event names in the form of "object:action:data"
  //   [object]: the class of the acting object
  //   [action]: infinitive verb naming the performed action
  //   [data]:   (optional) unique name or ID of the specific instance
  // e.g. "person:ignore:123"
  // if your event has to pass more than one datum (singular) - or in case you
  // need structured data - specify them as arguments to the `#trigger` call
  // e.g. `app.events.trigger('example:event', {more: 'data'})`
  events: _.extend({}, Backbone.Events),

  user: function(userAttrs) {
    if(userAttrs) {
      this._user = new app.models.User(userAttrs);
      return this._user;
    }
    return this._user || false;
  },

  initialize: function() {
    app.router = new app.Router();

    this.setupDummyPreloads();
    this.setupUser();
    this.setupAspects();
    this.setupHeader();
    this.setupBackboneLinks();
    this.setupGlobalViews();
    this.setupDisabledLinks();
    this.setupForms();
    this.setupAjaxErrorRedirect();
  },

  hasPreload : function(prop) {
    return !!(window.gon.preloads && window.gon.preloads[prop]); //returning boolean variable so that parsePreloads, which cleans up properly is used instead
  },

  parsePreload : function(prop) {
      if(!app.hasPreload(prop)) { return; }

      var preload = window.gon.preloads[prop];
      delete window.gon.preloads[prop]; //prevent dirty state across navigates

      return(preload);
  },

  setupDummyPreloads: function() {
    if (window.gon === undefined) {
      window.gon = {preloads:{}};
    }
  },

  setupUser: function() {
    app.currentUser = app.user(window.gon.user) || new app.models.User();
  },

  setupAspects: function() {
    app.aspects = new app.collections.Aspects(app.currentUser.get("aspects"));
  },

  setupHeader: function() {
    if(app.currentUser.authenticated()) {
      app.notificationsCollection = new app.collections.Notifications();
      app.header = new app.views.Header();
      $("header").prepend(app.header.el);
      app.header.render();
    }
  },

  setupBackboneLinks: function() {
    Backbone.history.start({pushState: true});

    // there's probably a better way to do this...
    $(document).on("click", "a[rel=backbone]", function(evt){
      if (!(app.stream && /^\/(?:stream|activity|aspects|public|mentions|likes)/.test(app.stream.basePath()))) {
        // We aren't on a regular stream page
        return;
      }

      evt.preventDefault();
      var link = $(this);
      $("html, body").animate({scrollTop: 0});

      // app.router.navigate doesn't tell us if it changed the page,
      // so we use Backbone.history.navigate instead.
      var change = Backbone.history.navigate(link.attr("href").substring(1) ,true);
      if(change === undefined) { Backbone.history.loadUrl(link.attr("href").substring(1)); }
      app.notificationsCollection.fetch();
    });
  },

  setupGlobalViews: function() {
    app.hovercard = new app.views.Hovercard();
    app.sidebar = new app.views.Sidebar();
    app.backToTop = new app.views.BackToTop({el: $(document)});
    app.flashMessages = new app.views.FlashMessages({el: $("#flash-container")});
  },

  setupDisabledLinks: function() {
    $("a.disabled").click(function(event) {
      event.preventDefault();
    });
  },

  setupForms: function() {
    // add placeholder support for old browsers
    $("input, textarea").placeholder();

    // init autosize plugin
    autosize($("textarea"));

    // setup remote forms
    $(document).on("ajax:success", "form[data-remote]", function() {
      $(this).clearForm();
      $(this).focusout();
    });
  },

  setupAjaxErrorRedirect: function() {
    var self = this;
    // Binds the global ajax event. To prevent this, add
    // preventGlobalErrorHandling: true
    // to the settings of your ajax calls
    $(document).ajaxError(function(evt, jqxhr, settings) {
      if(jqxhr.status === 401 && !settings.preventGlobalErrorHandling) {
        self._changeLocation(Routes.newUserSession());
      }
    });
  },

  _changeLocation: function(href) {
    window.location.assign(href);
  }
};

$(function() {
  app.initialize();
});
// @license-end
