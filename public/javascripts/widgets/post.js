/*   Copyright (c) 2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  var Post = function() {
    var self = this;
    //timeago //set up ikes //comments //audio video links //embedder //

    this.start = function() {
      $.extend(self, {
        likes: {
          actions: $(".like_it, .dislike_it"),
          expanders: $("a.expand_likes, a.expand_dislikes"),
        }
      });
      self.setUpLikes();
    },

    this.setUpLikes = function() {
      self.likes.expanders.live("click", self.expandLikes);
      self.likes.actions.live("ajax:loading", function() {
        $(this).parent().fadeOut(100);
      });

      self.likes.actions.live("ajax:failure", function() {
        Diaspora.widgets.alert.alert(Diaspora.widgets.i18n.t("failed_to_like"));
        $(this).parent().fadeIn(100);
      });
    };

    this.expandLikes = function(evt){
      evt.preventDefault();
      var likesList = $(this).siblings(".likes_list");
      if(likesList.children().length == 0){
        likesList.append("<img alt='loading' src='/images/ajax-loader.gif' />");
        $.ajax({
          url: this.href,
          success: function(data){
            likesList.html(data)
                     .fadeToggle(100);
          }
        });
      }
      else {
        likesList.fadeToggle(100);
      }
    };
  };

  Diaspora.widgets.add("post", Post);
})();
