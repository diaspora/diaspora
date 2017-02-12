(function(){
  Diaspora.Mobile.Drawer = {
    initialize: function(){
      $("#all_aspects").bind("tap click", function(evt){
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });

      $("#menu-badge").bind("tap click", function(evt){
        evt.preventDefault();
        $("#app").toggleClass("draw");
      });

      $("#followed_tags").bind("tap click", function(evt){
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });
    }
  };
})();

$(function(){
  Diaspora.Mobile.Drawer.initialize();
});
