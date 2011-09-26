$(document).ready(function(){
  $(".like_action.inactive").live('tap click', function(evt){
    evt.preventDefault();
    var link = $(this);

    $.ajax({
      url: link.attr("href"),
      dataType: 'json',
      type: 'POST',
      beforeSend: function(){
        link.removeClass('inactive')
              .addClass('loading');
      },
      complete: function(data){
        link.removeClass('loading')
              .removeClass('inactive')
              .addClass('active')
              .data('post-id', postId);
      }
    });
  });

  $(".like_action.active").live('tap click', function(evt){
    evt.preventDefault();
    var link = $(this);

    $.ajax({
      url: link.attr("href"),
      dataType: 'json',
      type: 'DELETE',
      beforeSend: function(){
        link.removeClass('active')
              .addClass('loading')
              .fadeIn(50);
      },
      complete: function(data){
        link.removeClass('loading')
              .removeClass('active')
              .addClass('inactive')
              .data('like-id', '');
      }
    });
  });


  $("a.show_comments").live('tap click', function(evt){
    evt.preventDefault();
    var postId = $(this).data('post-id');
        parent = $(this).closest(".bottom_bar").first();
    var link = $(this);

    $.ajax({
      url: link.attr('href'),
      success: function(data){
        parent.append(data);
      }
    });
  });
});
