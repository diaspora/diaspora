app.views.Header = app.views.Base.extend({

  templateName : "header",

  className : "dark-header",

  events : {
    "click ul.dropdown li:first-child" : "toggleDropdown",
    "focusin #q": "toggleSearchActive",
    "focusout #q": "toggleSearchActive"
  },

  initialize : function(options) {
    $(document.body).click($.proxy(this.hideDropdown, this));
    return this;
  },

  menuElement : function() {
    return this.$("ul.dropdown");
  },

  toggleDropdown : function(evt) {
    if(evt){ evt.preventDefault(); }

    this.menuElement().toggleClass("active");

    if($.browser.msie) {
      this.$("header").toggleClass('ie-user-menu-active');
    }
  },

  hideDropdown : function(evt) {
    if(this.menuElement().hasClass("active") && !$(evt.target).parents("#user_menu").length) {
      this.menuElement().removeClass("active");
    }
  },

  toggleSearchActive: function(ev) {
    // jQuery produces two events for focus/blur (for bubbling)
    // don't rely on which event arrives first, by allowing for both variants
    var is_active = (_.indexOf(['focus','focusin'], ev.type) != -1);
    $(ev.target).toggleClass('active', is_active);
    return false;
  }
});
