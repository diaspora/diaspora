jQuery.fn.center = function () {
  this.css("position","absolute");
  this.css("top", ( $(window).height() - this.height() ) / 2+$(window).scrollTop() + "px");
  this.css("left", ( $(window).width() - this.width() ) / 2+$(window).scrollLeft() + "px");
  return this;
}

$(document).ready( function(){
  var username = $("#user_username"),
      password = $("#user_password"),
      forgotPass = $("#forgot_password_link"),
      controls = $("#controls");

  $("#login").center();
  $(window).resize(function(){
    $("#login").center();
  });

  username.focus();
  $("form").submit(function(){
    $('#asterisk').addClass('rideSpinners');
    clearConnectionInfo();
    juser = username.val() + "@" + pod_url;
    localStorage.setItem("user", juser);
    forgotPass.addClass('hidden');
    controls.addClass('hidden');
  });
});

