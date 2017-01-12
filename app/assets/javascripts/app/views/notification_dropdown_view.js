// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.NotificationDropdown = app.views.Base.extend({
  events: {
    "click #notifications-link": "toggleDropdown"
  },

  initialize: function(){
    $(document.body).click(this.hideDropdown.bind(this));

    this.badge = this.$el;
    this.dropdown = $("#notification-dropdown");
    this.dropdownNotifications = this.dropdown.find(".notifications");
    this.ajaxLoader = this.dropdown.find(".ajax-loader");
    this.perfectScrollbarInitialized = false;
    this.dropdownNotifications.scroll(this.dropdownScroll.bind(this));
    this.bindCollectionEvents();
  },

  bindCollectionEvents: function() {
    this.collection.on("pushFront", this.onPushFront.bind(this));
    this.collection.on("pushBack", this.onPushBack.bind(this));
    this.collection.on("finishedLoading", this.finishLoading.bind(this));
    this.collection.on("change:note_html", this.onNotificationChange.bind(this));
  },

  toggleDropdown: function(evt){
    evt.stopPropagation();
    if (!$("#notifications-link .entypo-bell:visible").length) { return true; }
    evt.preventDefault();
    if(this.dropdownShowing()){ this.hideDropdown(evt); }
    else{ this.showDropdown(); }
  },

  dropdownShowing: function(){
    return this.dropdown.hasClass("dropdown-open");
  },

  showDropdown: function(){
    this.ajaxLoader.show();
    this.dropdown.addClass("dropdown-open");
    this.updateScrollbar();
    this.dropdownNotifications.addClass("loading");
    this.collection.fetch();
  },

  hideDropdown: function(evt){
    var inDropdown = $(evt.target).parents().is($(".dropdown-menu", this.dropdown));
    var inHovercard = $.contains(app.hovercard.el, evt.target);
    if(!inDropdown && !inHovercard && this.dropdownShowing()){
      this.dropdown.removeClass("dropdown-open");
      this.destroyScrollbar();
    }
  },

  dropdownScroll: function(){
    var isLoading = ($(".loading").length === 1);
    if (this.isBottom() && !isLoading) {
      this.dropdownNotifications.addClass("loading");
      this.collection.fetchMore();
    }
  },

  isBottom: function(){
    var bottom = this.dropdownNotifications.prop("scrollHeight") - this.dropdownNotifications.height();
    var currentPosition = this.dropdownNotifications.scrollTop();
    return currentPosition + 50 >= bottom;
  },

  hideAjaxLoader: function(){
    var self = this;
    this.ajaxLoader.find(".spinner").fadeTo(200, 0, function(){
      self.ajaxLoader.hide(200, function(){
        self.ajaxLoader.find(".spinner").css("opacity", 1);
      });
    });
  },

  onPushBack: function(notification) {
    var node = $(notification.get("note_html"));
    this.dropdownNotifications.append(node);
    this.afterNotificationChanges(node);
  },

  onPushFront: function(notification) {
    var node = $(notification.get("note_html"));
    this.dropdownNotifications.prepend(node);
    this.afterNotificationChanges(node);
  },

  onNotificationChange: function(notification) {
    var node = $(notification.get("note_html"));
    this.dropdownNotifications.find("[data-guid=" + notification.get("id") + "]").replaceWith(node);
    this.afterNotificationChanges(node);
  },

  afterNotificationChanges: function(node) {
    node.find(".unread-toggle .entypo-eye").tooltip("destroy").tooltip();
    node.find(this.avatars.selector).error(this.avatars.fallback);
  },

  finishLoading: function() {
    app.helpers.timeago(this.dropdownNotifications);
    this.updateScrollbar();
    this.hideAjaxLoader();
    this.dropdownNotifications.removeClass("loading");
  },

  updateScrollbar: function() {
    if(this.perfectScrollbarInitialized) {
      this.dropdownNotifications.perfectScrollbar("update");
    } else {
      this.dropdownNotifications.perfectScrollbar();
      this.perfectScrollbarInitialized = true;
    }
  },

  destroyScrollbar: function() {
    if(this.perfectScrollbarInitialized) {
      this.dropdownNotifications.perfectScrollbar("destroy");
      this.perfectScrollbarInitialized = false;
    }
  }
});
// @license-end
