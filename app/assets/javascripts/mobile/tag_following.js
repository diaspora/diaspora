$(document).ready(function(){
  $(".tag_following_action").bind("tap click", function(evt){
    evt.preventDefault();
    var button = $(this),
        tagName = button.data("name");

    if(button.hasClass("btn-success")){
      $.ajax({
        url: Routes.tag_followings_path(),
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
        alert(Diaspora.I18n.t("stream.tags.follow_error", {name: "#" + tagName}));
      });
    }
    else if(button.hasClass("btn-danger")){
      var tagFollowing = _.findWhere(gon.preloads.tagFollowings,{name: tagName});
      if(!tagFollowing) { return; }
      $.ajax({
        url: Routes.tag_following_path(tagFollowing.id),
        dataType: "json",
        type: "DELETE",
        headers: {
          "Accept": "application/json, text/javascript, */*; q=0.01"
        }
      }).done(function() {
        button.removeClass("btn-danger").addClass("btn-success");
        button.text(Diaspora.I18n.t("stream.tags.follow", {tag: tagName}));
      }).fail(function() {
        alert(Diaspora.I18n.t("stream.tags.stop_following_error", {name: "#" + tagName}));
      });
    }
  });
});
