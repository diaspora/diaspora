$(document).ready(function(){
  $(".tag_following_action").bind("tap click", function(evt){
    evt.preventDefault();
    var tagFollowing,
        button = $(this),
        tagName = button.data("name");

    if(button.hasClass("btn-success")){
      $.ajax({
        url: Routes.tagFollowings(),
        data: JSON.stringify({"name": tagName}),
        type: "POST",
        dataType: "json",
        headers: {
          "Accept": "application/json, text/javascript, */*; q=0.01"
        },
        contentType: "application/json; charset=UTF-8"
      }).done(function(data) {
        gon.preloads.tagFollowings.push(data);
        button.removeClass("btn-success").addClass("btn-danger");
        button.text(Diaspora.I18n.t("stream.tags.stop_following", {tag: tagName}));
      }).fail(function() {
        alert(Diaspora.I18n.t("stream.tags.follow_error", {tag: tagName}));
      });
    }
    else if(button.hasClass("btn-danger")){
      tagFollowing = _.findWhere(gon.preloads.tagFollowings, {name: tagName});
      if(!tagFollowing) { return; }
      $.ajax({
        url: Routes.tagFollowing(tagFollowing.id),
        dataType: "json",
        type: "DELETE",
        headers: {
          "Accept": "application/json, text/javascript, */*; q=0.01"
        }
      }).done(function() {
        button.removeClass("btn-danger").addClass("btn-success");
        button.text(Diaspora.I18n.t("stream.tags.follow", {tag: tagName}));
      }).fail(function() {
        alert(Diaspora.I18n.t("stream.tags.stop_following_error", {tag: tagName}));
      });
    }
    else if(button.hasClass("only-delete")){
      tagFollowing = _.findWhere(gon.preloads.tagFollowings, {name: tagName});
      if(!tagFollowing ||
        !confirm(Diaspora.I18n.t("stream.tags.stop_following_confirm", {tag: tagName}))) { return; }

      $.ajax({
        url: Routes.tagFollowing(tagFollowing.id),
        dataType: "json",
        type: "DELETE",
        headers: {
          "Accept": "application/json, text/javascript, */*; q=0.01"
        }
      }).done(function() {
        button.closest("li").remove();
        if($("ul.followed_tags li").length === 0){
          $(".well").removeClass("hidden");
        }
      }).fail(function() {
        alert(Diaspora.I18n.t("stream.tags.stop_following_error", {tag: tagName}));
      });
    }
  });
});
