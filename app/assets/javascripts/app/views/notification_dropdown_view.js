// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.NotificationDropdown = app.views.Base.extend({
  events: {
    "click #notifications-link": "toggleDropdown"
  },

  initialize: function(){
    $(document.body).click($.proxy(this.hideDropdown, this));

    this.notifications = [];
    this.perPage = 5;
    this.hasMoreNotifs = true;
    this.badge = this.$el;
    this.dropdown = $("#notification-dropdown");
    this.dropdownNotifications = this.dropdown.find(".notifications");
    this.ajaxLoader = this.dropdown.find(".ajax-loader");
    this.perfectScrollbarInitialized = false;
    this.updateHeaderCounts();
    setInterval(this.updateHeaderCounts, 30000);
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
    this.resetParams();
    this.ajaxLoader.show();
    this.dropdown.addClass("dropdown-open");
    this.updateScrollbar();
    this.dropdownNotifications.addClass("loading");
    this.getNotifications();
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
    if (this.isBottom() && this.hasMoreNotifs && !isLoading){
      this.dropdownNotifications.addClass("loading");
      this.getNotifications();
    }
  },

  getParams: function(){
    if(this.notifications.length === 0){ return{ per_page: 10, page: 1 }; }
    else{ return{ per_page: this.perPage, page: this.nextPage }; }
  },

  resetParams: function(){
    this.notifications.length = 0;
    this.hasMoreNotifs = true;
    delete this.nextPage;
  },

  isBottom: function(){
    var bottom = this.dropdownNotifications.prop("scrollHeight") - this.dropdownNotifications.height();
    var currentPosition = this.dropdownNotifications.scrollTop();
    return currentPosition + 50 >= bottom;
  },

  getNotifications: function(){
    var self = this;
    $.getJSON(Routes.notifications(this.getParams()), function(notifications){
      $.each(notifications, function(){ self.notifications.push(this); });
      self.hasMoreNotifs = notifications.length >= self.perPage;
      if(self.nextPage){ self.nextPage++; }
      else { self.nextPage = 3; }
      self.renderNotifications();
    });
  },

  hideAjaxLoader: function(){
    var self = this;
    this.ajaxLoader.find(".spinner").fadeTo(200, 0, function(){
      self.ajaxLoader.hide(200, function(){
        self.ajaxLoader.find(".spinner").css("opacity", 1);
      });
    });
  },

  renderNotifications: function(){
    var self = this;
    this.dropdownNotifications.find(".media.stream_element").remove();
    $.each(self.notifications, function(index, notifications){
      $.each(notifications, function(index, notification){
        if($.inArray(notification, notifications) === -1){
          var node = self.dropdownNotifications.append(notification.note_html);
          $(node).find(".unread-toggle .entypo-eye").tooltip("destroy").tooltip();
          $(node).find(self.avatars.selector).error(self.avatars.fallback);
        }
      });
    });
    this.updateHeaderCounts();

    this.hideAjaxLoader();

    app.helpers.timeago(this.dropdownNotifications);

    this.updateScrollbar();
    this.dropdownNotifications.removeClass("loading");
    this.dropdownNotifications.scroll(function(){
      self.dropdownScroll();
    });
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
  },

  updateHeaderCounts: function() {
    $.getJSON(Routes.notificationsCounts(), function(data) {
      var headerBadge = $(".notifications-link .badge"),
        markAllReadLink = $("a#mark_all_read_link");
      if (data.notifications > 0) {
        headerBadge.html(parseInt(data.notifications));
        headerBadge.removeClass("hidden");
        markAllReadLink.removeClass("enabled");
      } else {
        headerBadge.addClass("hidden");
        headerBadge.html(0);
        markAllReadLink.removeClass("disabled");
      }
    });
  }
});
// @license-end
