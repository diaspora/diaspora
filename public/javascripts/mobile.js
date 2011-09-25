$(document).ready(function(){
  $(".like_action.inactive").live('tap click', function(evt){
    evt.preventDefault();
    var target = $(this),
        postId = target.data('post-id');

    $.ajax({
      url: '/posts/'+postId+'/likes.json',
      type: 'POST',
      beforeSend: function(){
        target.removeClass('inactive')
              .addClass('loading');
      },
      complete: function(data){
        target.removeClass('loading')
              .removeClass('inactive')
              .addClass('active')
              .data('post-id', postId);
      }
    });
  });

  $(".like_action.active").live('tap click', function(evt){
    evt.preventDefault();
    var target = $(this),
        postId = $(this).data('post-id'),
        likeId = $(this).data('like-id');


    $.ajax({
      url: '/posts/'+postId+'/likes/'+likeId+'.json',
      type: 'DELETE',
      beforeSend: function(){
        target.removeClass('active')
              .addClass('loading')
              .fadeIn(50);
      },
      complete: function(data){
        target.removeClass('loading')
              .removeClass('active')
              .addClass('inactive')
              .data('like-id', '');
      }
    });
  });
});
