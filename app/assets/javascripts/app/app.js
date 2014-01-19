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
//= require_tree ./forms

var app = {
  collections: {},
  models: {},
  helpers: {},
  views: {},
  pages: {},
  forms: {},

  user: function(userAttrs) {
    if(userAttrs) { return this._user = new app.models.User(userAttrs) }
    return this._user || false
  },

  baseImageUrl: function(baseUrl){
    if(baseUrl) { return this._baseImageUrl = baseUrl }
    return this._baseImageUrl || "assets/"
  },

  initialize: function() {
    app.router = new app.Router();

    this.setupDummyPreloads();
    this.setupFacebox();
    this.setupUser();
    this.setupHeader();
    this.setupBackboneLinks();
    this.setupGlobalViews();
    this.setupDisabledLinks();
  },

  hasPreload : function(prop) {
    return !!(window.gon.preloads && window.gon.preloads[prop]) //returning boolean variable so that parsePreloads, which cleans up properly is used instead
  },

  setPreload : function(prop, val) {
    window.gon.preloads = window.gon.preloads || {}
    window.gon.preloads[prop] = val
  },

  parsePreload : function(prop) {
      if(!app.hasPreload(prop)) { return }

      var preload = window.gon.preloads[prop]
      delete window.gon.preloads[prop] //prevent dirty state across navigates

      return(preload)
  },

  setupDummyPreloads: function() {
    if (window.gon == undefined) {
      window.gon = {preloads:{}};
    }
  },

  setupUser: function() {
    app.currentUser = app.user(window.gon.user) || new app.models.User();
  },

  setupHeader: function() {
    if(app.currentUser.authenticated()) {
      app.header = new app.views.Header();
      $("header").prepend(app.header.el);
      app.header.render();
    }
  },

  setupFacebox: function() {
    $.facebox.settings.closeImage = app.baseImageUrl()+'facebox/closelabel.png';
    $.facebox.settings.loadingImage = app.baseImageUrl()+'facebox/loading.gif';
    $.facebox.settings.opacity = 0.75;
  },

  setupBackboneLinks: function() {
    Backbone.history.start({pushState: true});

    // there's probably a better way to do this...
    $("a[rel=backbone]").live("click", function(evt){
      evt.preventDefault();
      var link = $(this);

      $(".stream_title").text(link.text())
      app.router.navigate(link.attr("href").substring(1) ,true)
    });
  },

  setupGlobalViews: function() {
    app.hovercard = new app.views.Hovercard();
    app.aspectMemberships = new app.views.AspectMembership();
    app.sidebar = new app.views.Sidebar();
  },

  /* mixpanel wrapper function */
  instrument : function(type, name, object, callback) {
    if(!window.mixpanel) { return }
    window.mixpanel[type](name, object, callback)
  },

  setupDisabledLinks: function() {
    $("a.disabled").click(function(event) {
      event.preventDefault();
    });
  },
};

$(function() {
  app.initialize();
});
