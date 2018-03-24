// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.BackToTop = Backbone.View.extend({
  events: {
    "click #back-to-top": "backToTop"
  },

  initialize: function() {
    var throttledScroll = _.throttle(this.toggleVisibility, 250);
    $(window).scroll(throttledScroll);
  },

  backToTop: function(evt) {
    evt.preventDefault();
    $("html, body").animate({scrollTop: 0}, this.toggleVisibility);
  },

  toggleVisibility: function() {
    if($(document).scrollTop() > 1000) {
      $("#back-to-top").addClass("visible");
    } else {
      $("#back-to-top").removeClass("visible");
    }
  }
});
// @license-end
