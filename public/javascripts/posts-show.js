$(function(){
  $(document).keypress(function(event){
      $('#text').focus();
      $('#comment').modal();
    });

  $(document).keydown(function(e){
    if (e.keyCode == 37) {
       window.location = $('#back').attr('href');
    }else if(e.keyCode == 39) {
       window.location = $('#forward').attr('href');
    }
  });
});