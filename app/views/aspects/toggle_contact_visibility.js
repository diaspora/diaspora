$(document).ready(function() {

  var padlockImg = $("#contact_visibility_padlock");

  if(padlockImg.hasClass('open')) {
    padlockImg.attr('src', 'images/icons/padlock-closed.png');
  } else {
    padlockImg.attr('src', 'images/icons/padlock-open.png');
  }
  padlockImg.toggleClass('open');

});
