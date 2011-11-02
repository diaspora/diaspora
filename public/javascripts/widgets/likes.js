(function() {
  var Likes = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, likesContainer) {
      $.extend(self, {
        likesContainer: likesContainer,
        likesList: likesContainer.find(".likes_list"),
        loadingImage: $("<img/>", { src: "/images/ajax-loader.gif" }),
        expander: likesContainer.find("a.expand_likes")
      });

      self.expander.click(self.expandLikes);
    });

    this.expandLikes = function(evt) {
      evt.preventDefault();

      if(self.likesList.children().length == 0) {
        self.loadingImage.appendTo(self.likesContainer);

        $.get(self.expander.attr('href'), function(data) {
          self.loadingImage.fadeOut(100, function() {
            self.expander.fadeOut(100, function(){
              self.likesList.html(data)
                .fadeToggle(100);
            });
          });
        });
      }
      else {
        self.likesList.fadeToggle(100);
      }
    };
  };

  Diaspora.Widgets.Likes = Likes;
})();
