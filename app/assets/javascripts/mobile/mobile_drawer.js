(function() {
  Diaspora.Mobile.Drawer = {
    initialize: function() {
      $("#menu-badge").bind("tap click", function(evt) {
        evt.preventDefault();
        $("#app").toggleClass("draw");
      });
      $("#all_aspects, #followed_tags, #admin").bind("tap click", function(evt) {
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });
    }
  };
})();

$(function(){
  Diaspora.Mobile.Drawer.initialize();
});
