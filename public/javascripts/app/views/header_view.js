App.Views.Header = Backbone.View.extend({

  events : {
    "click ul.dropdown li:first-child" : "toggleDropdown"
  },

  initialize : function(options) {
    this.menuElement = this.$("ul.dropdown");

    _.bindAll(this, "toggleDropdown", "hideDropdown");
    this.menuElement.find("li a").slice(1).click(function(evt) { evt.stopPropagation(); });
    $(document.body).click(this.hideDropdown);

    return this;
  },

  render : function(){
    this.template = _.template($("#header-template").html());
    $(this.el).html(this.template(App.user()));
    return this;
  },

  toggleDropdown : function(evt) {
    evt.preventDefault();
    evt.stopPropagation();

    this.$("ul.dropdown").toggleClass("active");

    if ( $.browser.msie ) {
      this.$('header').toggleClass('ie-user-menu-active');
    }
  },

  hideDropdown : function(evt) {
    if(this.$("ul.dropdown").hasClass("active") && !$(evt.target).parents("#user_menu").length) {
      this.$("ul.dropdown").removeClass("active");
    }
  }
});
