(function() {
  var Likes = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, element) {
      $.extend(self, {
        loadingImage: $("<img/>", { src: "/images/ajax-loader.gif" }),
        expander: element.find("a.expand_likes")
      });

      self.expander.click(self.expandLikes);
    });

    this.expandLikes = function(evt) {
      evt.preventDefault();
      var likesList = $(this).siblings(".likes_list");
      if(likesList.children().length == 0) {
        self.loadingImage.appendTo(likesList.parent());
        $.get(this.href, function(data) {
          self.loadingImage.fadeOut(100, function() {
            likesList.html(data)
              .fadeToggle(100);
          });
        });
      }
      else {
        likesList.fadeToggle(100);
      }
    };
  };

  Diaspora.Widgets.Likes = Likes;
})();