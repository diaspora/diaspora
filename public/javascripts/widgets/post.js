/*   Copyright (c) 2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  var Post = function() {
    this.likesSelector = ".like_it, .dislike_it";
    this.expandLikesSelector = "a.expand_likes, a.expand_dislikes";
    this.start = function() {
      //timeago
      //set up ikes
      //comments
      //audio video links
      //embedder
      //


      this.setUpLikes();
    };

    this.setUpLikes = function() {
      $(this.expandLikesSelector).live("click", function(evt) {
        evt.preventDefault();
        $(this).siblings(".likes_list")
          .fadeToggle("fast");
      });

      var likeIt = $(this.likesSelector);

      likeIt.live("ajax:loading", function() {
        $(this).parent().fadeOut("fast");
      });

      likeIt.live("ajax:failure", function() {
        Diaspora.widgets.alert.alert(Diaspora.widgets.i18n.t("failed_to_like"));
        $(this).parent().fadeIn("fast");
      });
    };
  };

  Diaspora.widgets.add("post", Post);
})();