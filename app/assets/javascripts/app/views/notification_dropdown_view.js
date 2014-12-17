// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.NotificationDropdown = app.views.Base.extend({
  events:{
    'click #notifications-button': 'toggleDropdown'
  },

  initialize: function(){
    this.notifications = [];
    this.perPage = 5;
    this.hasMoreNotifs = true;
    this.badge = this.$el;
    this.dropdown = this.$('#notifications-dropdown');
    this.dropdownNotifications = this.dropdown.find('#notifications-list');
    this.ajaxLoader = this.dropdown.find('.ajax-loader');

    this.dropdown.on('click', function(evt){ evt.stopPropagation(); });
  },

  toggleDropdown: function(evt){
    if(this.dropdownShowing()){ this.hideDropdown(evt); }
    else{ this.showDropdown(); }
  },

  dropdownShowing: function(){
    return this.badge.hasClass('open');
  },

  showDropdown: function(){
    this.resetParams();
    this.ajaxLoader.show();
    this.dropdownNotifications.addClass('loading');
    this.getNotifications();
  },

  hideDropdown: function(evt){
    this.dropdownNotifications.perfectScrollbar('destroy');
  },

  dropdownScroll: function(){
    var isLoading = ($('.loading').length === 1);
    if (this.isBottom() && this.hasMoreNotifs && !isLoading){
      this.dropdownNotifications.addClass('loading');
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
    var bottom = this.dropdownNotifications.prop('scrollHeight') - this.dropdownNotifications.height();
    var currentPosition = this.dropdownNotifications.scrollTop();
    return currentPosition + 50 >= bottom;
  },

  getNotifications: function(){
    var self = this;
    $.getJSON(Routes.notifications_path(this.getParams()), function(notifications){
      $.each(notifications, function(){ self.notifications.push(this); });
      self.hasMoreNotifs = notifications.length >= self.perPage;
      if(self.nextPage){ self.nextPage++; }
      else { self.nextPage = 3; }
      self.renderNotifications();
    });
  },

  hideAjaxLoader: function(){
    var self = this;
    this.ajaxLoader.find('img').fadeTo(150, 0, function(){
      self.ajaxLoader.hide(200, function(){
        self.ajaxLoader.find('img').css('opacity', 1);
      });
    });
  },

  renderNotifications: function(){
    var self = this;
    this.dropdownNotifications.find('.media.stream_element').remove();
    $.each(self.notifications, function(index, notifications){
      $.each(notifications, function(index, notification){
        if($.inArray(notification, notifications) === -1){
          var node = self.dropdownNotifications.append(notification.note_html);
          $(node).find('.unread-toggle .entypo').tooltip('destroy').tooltip();
        }
      });
    });

    this.hideAjaxLoader();

    app.helpers.timeago(this.dropdownNotifications);

    this.dropdownNotifications.perfectScrollbar('destroy').perfectScrollbar();
    this.dropdownNotifications.removeClass('loading');
    this.dropdownNotifications.scroll(function(){
      self.dropdownScroll();
    });
  }
});
// @license-end
