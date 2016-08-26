(function(){
  Diaspora.Mobile = {
    initialize: function(){
      $(".shield a").click(function(){
        $(this).parents(".stream_element").removeClass("shield-active");
        return false;
      });

      // init autosize plugin
      autosize($("textarea"));
    }
  };
})();

$(document).ready(function(){
  Diaspora.Mobile.initialize();
});
