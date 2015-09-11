(function(){
  Diaspora.Mobile.Drawer = {
    allAspects: $("#all_aspects"),
    followedTags: $("#followed_tags"),
    menuBadge: $("#menu-badge"),

    initialize: function(){
      this.allAspects.bind("tap click", function(evt){
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });

      this.menuBadge.bind("tap click", function(evt){
        evt.preventDefault();
        $("#app").toggleClass("draw");
      });

      this.followedTags.bind("tap click", function(evt){
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });
    }
  };
})();

$(function(){
  Diaspora.Mobile.Drawer.initialize();
});
