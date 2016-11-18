// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Header = app.views.Base.extend({

  templateName: "header",

  className: "dark-header",

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      podname: gon.appConfig.settings.podname
    });
  },

  postRenderTemplate: function() {
    new app.views.Notifications({el: "#notification-dropdown", collection: app.notificationsCollection});
    new app.views.NotificationDropdown({el: "#notification-dropdown", collection: app.notificationsCollection});
    new app.views.Search({el: "#header-search-form"});
  },

  menuElement: function() { return this.$("ul.dropdown"); }
});
// @license-end
