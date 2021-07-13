(function(){
  Diaspora.Mobile.PostActions = {
    initialize: function() {
      $(".like-action", ".stream").bind("tap click", this.onLike);
      $(".reshare-action", ".stream").bind("tap click", this.onReshare);
      // Add handler to newly loaded comments
      var self = this;
      $(".stream").bind("comments.loaded", function() {
        $(".like-action", ".stream").bind("tap click", self.onLike);
      });
    },

    showLoader: function(link) {
      link.addClass("loading");
    },

    hideLoader: function(link) {
      link.removeClass("loading");
    },

    toggleActive: function(link) {
      link.toggleClass("active").toggleClass("inactive");
    },

    like: function(likeCounter, link){
      var url = link.data("url");
      var onSuccess = function(data){
        Diaspora.Mobile.PostActions.toggleActive(link);
        link.data("url", url + "/" + data.id);
        if(likeCounter){
          likeCounter.text(parseInt(likeCounter.text(), 10) + 1);
        }
      };

      $.ajax({
        url: url,
        dataType: "json",
        type: "POST",
        beforeSend: function() {
          Diaspora.Mobile.PostActions.showLoader(link);
        },
        success: onSuccess,
        error: function(response) {
          Diaspora.Mobile.Alert.handleAjaxError(response);
        },
        complete: function() {
          Diaspora.Mobile.PostActions.hideLoader(link);
        }
      });
    },

    unlike: function(likeCounter, link){
      var url = link.data("url");
      var onSuccess = function(){
        Diaspora.Mobile.PostActions.toggleActive(link);
        link.data("url", url.replace(/\/\d+$/, ""));

        if(likeCounter){
          var newValue = parseInt(likeCounter.text(), 10) - 1;
          likeCounter.text(Math.max(newValue, 0));
        }
      };

      $.ajax({
        url: url,
        dataType: "json",
        type: "DELETE",
        beforeSend: function() {
          Diaspora.Mobile.PostActions.showLoader(link);
        },
        success: onSuccess,
        error: function(response) {
          Diaspora.Mobile.Alert.handleAjaxError(response);
        },
        complete: function() {
          Diaspora.Mobile.PostActions.hideLoader(link);
        }
      });
    },

    onLike: function(evt){
      evt.preventDefault();
      var link = $(evt.target).closest(".like-action").first(),
          likeCounter = $(evt.target).find(".like-count").first();

      if(!link.hasClass("loading") && link.hasClass("inactive")) {
        Diaspora.Mobile.PostActions.like(likeCounter, link);
      }
      else if(!link.hasClass("loading") && link.hasClass("active")) {
        Diaspora.Mobile.PostActions.unlike(likeCounter, link);
      }
    },

    onReshare: function(evt) {
      evt.preventDefault();

      var link = $(this).closest(".reshare-action"),
          href = link.attr("href"),
          confirmText = link.attr("title");

      if(!link.hasClass("loading") && link.hasClass("inactive") && confirm(confirmText)) {
        $.ajax({
          url: href + "&provider_display_name=mobile",
          dataType: "json",
          type: "POST",
          beforeSend: function() {
            Diaspora.Mobile.PostActions.showLoader(link);
          },
          success: function() {
            Diaspora.Mobile.PostActions.toggleActive(link);
            var reshareCounter = $(evt.target).closest(".stream-element").find(".reshare-count");
            if (reshareCounter) {
              reshareCounter.text(parseInt(reshareCounter.text(), 10) + 1);
            }
          },
          error: function(response) {
            Diaspora.Mobile.Alert.handleAjaxError(response);
          },
          complete: function() {
            Diaspora.Mobile.PostActions.hideLoader(link);
          }
        });
      }
    }
  };
})();

$(function(){
  Diaspora.Mobile.PostActions.initialize();
});
