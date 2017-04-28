(function(){
  Diaspora.Mobile = {
    initialize: function(){
      $(".shield a").click(function(){
        $(this).parents(".stream-element").removeClass("shield-active");
        return false;
      });

      // init autosize plugin
      autosize($("textarea"));
    },

    changeLocation: function(href) {
      window.location.assign(href);
    }
  };
})();

$(document).ready(function(){
  Diaspora.Mobile.initialize();
});
