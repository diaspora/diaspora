// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.NotificationDropdown = app.views.Base.extend({
  events:{
    "click #notifications-badge": "toggleDropdown"
  },

  initialize: function(){
    $(document.body).click($.proxy(this.hideDropdown, this));

    this.notifications = [];
    this.perPage = 5;
    this.hasMoreNotifs = true;
    this.badge = this.$el;
    this.dropdown = $('#notification_dropdown');
    this.dropdownNotifications = this.dropdown.find('.notifications');
    this.ajaxLoader = this.dropdown.find('.ajax_loader');
  },

  toggleDropdown: function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    if(this.dropdownShowing()){ this.hideDropdown(evt); }
    else{ this.showDropdown(); }
  },

  dropdownShowing: function(){
    return this.dropdown.css('display') === 'block';
  },

  showDropdown: function(){
    this.resetParams();
    this.ajaxLoader.show();
    this.badge.addClass('active');
    this.dropdown.css('display', 'block');
    this.dropdownNotifications.addClass('loading');
    this.getNotifications();
  },

  hideDropdown: function(evt){
    var inDropdown = $(evt.target).parents().is(this.dropdown);
    var inHovercard = $.contains(app.hovercard.el, evt.target);
    if(!inDropdown && !inHovercard && this.dropdownShowing()){
      this.badge.removeClass('active');
      this.dropdown.css('display', 'none');
      this.dropdownNotifications.perfectScrollbar('destroy');
    }
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
    this.ajaxLoader.find('img').fadeTo(200, 0, function(){
      self.ajaxLoader.hide(300, function(){
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
