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

  var contentFilled = function(){
    return($('#user_username').val() != "" && $('#user_password').val() != "");
  }

  $("#login").center();
  $(window).resize(function(){
    $("#login").center();
  });

  username.focus();
  $("form").submit(function(){
    $('#asterisk').addClass('rideSpinners');
    forgotPass.addClass('hidden');
    controls.addClass('hidden');
  });

  $(document).keydown(function(){
    if(contentFilled()){
      controls.removeClass('hidden');
    }else{
      controls.addClass('hidden');
    }
  });

  if(contentFilled()){
    controls.removeClass('hidden');
  }

  password
    .focus(function(){
      forgotPass.removeClass('hidden');
    })
    .blur(function(){
      forgotPass.addClass('hidden');
    });
});

