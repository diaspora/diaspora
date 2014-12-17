// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Header = app.views.Base.extend({

  templateName: "header",

  className: "dark-header",

  events:{
    "focusin #q": "toggleSearchActive",
    "focusout #q": "toggleSearchActive"
  },

  initialize: function() {
    return this;
  },

  postRenderTemplate: function(){
    new app.views.Notifications({ el: '#notifications-dropdown' });
    new app.views.NotificationDropdown({ el: '#notification-badge' });
    new app.views.Search({ el: '#header-search-form' });
  },

  toggleSearchActive: function(ev){
    // jQuery produces two events for focus/blur (for bubbling)
    // don't rely on which event arrives first, by allowing for both variants
    var is_active = (_.indexOf(['focus','focusin'], ev.type) !== -1);
    $(ev.target).toggleClass('active', is_active);
    return false;
  }
});
// @license-end
