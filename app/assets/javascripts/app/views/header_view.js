// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Header = app.views.Base.extend({

  templateName: "header",

  className: "dark-header",

  events: {
    "focusin #q": "toggleSearchActive",
    "focusout #q": "toggleSearchActive"
  },

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      podname: gon.appConfig.settings.podname
    });
  },

  postRenderTemplate: function(){
    new app.views.Notifications({ el: "#notification-dropdown" });
    this.notificationDropdown = new app.views.NotificationDropdown({ el: "#notification-dropdown" });
    new app.views.Search({ el: "#header-search-form" });
  },

  menuElement: function(){ return this.$("ul.dropdown"); },

  toggleSearchActive: function(evt){
    // jQuery produces two events for focus/blur (for bubbling)
    // don't rely on which event arrives first, by allowing for both variants
    var isActive = (_.indexOf(["focus","focusin"], evt.type) !== -1);
    $(evt.target).toggleClass("active", isActive);
    return false;
  }
});
// @license-end
