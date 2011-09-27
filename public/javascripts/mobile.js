$(document).ready(function(){
  $(".stream").delegate(".like_action.inactive", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this),
        likeCounter = $(this).closest(".stream_element").find("like_count"),
        postId = link.closest(".stream_element").data("post-guid");

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

        if(likeCounter){
          likeCounter.text(parseInt(likeCounter.text) + 1);
        }
      }
    });
  });

  $(".stream").delegate(".like_action.active", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this);
        likeCounter = $(this).closest(".stream_element").find("like_count");

    $.ajax({
      url: link.attr("href"),
      dataType: 'json',
      type: 'DELETE',
      beforeSend: function(){
        link.removeClass('active')
              .addClass('loading');
      },
      complete: function(data){
        link.removeClass('loading')
              .removeClass('active')
              .addClass('inactive')
              .data('like-id', '');

        if(likeCounter){
          likeCounter.text(parseInt(likeCounter.text) - 1);
        }
      }
    });
  });

  $("a.show_comments").bind("tap click", function(evt){
    evt.preventDefault();
    var link = $(this),
        parent = link.closest(".bottom_bar").first(),
        commentsContainer = parent.find(".comment_container");

    if( link.hasClass('active') ) {
      commentsContainer.first().hide();
      link.removeClass('active');

    } else if( commentsContainer.length > 0) {
      commentsContainer.first().show();

      if(!commentsContainer.hasClass('noComments')) {
        $.ajax({
          url: link.attr('href'),
          success: function(data){
            parent.append($(data).find('.comments_container').html());
            link.addClass('active');
          }
        });
      }

      link.addClass('active');

    } else {
      $.ajax({
        url: link.attr('href'),
        success: function(data){
          parent.append(data);
          link.addClass('active');
        }
      });
    }
  });

  $(".stream").delegate("a.comment_action", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this);

    if(link.hasClass('inactive')) {
      var parent = link.closest(".bottom_bar").first(),
          container = link.closest('.bottom_bar').find('.add_comment_bottom_link_container');

      $.ajax({
        url: link.attr('href'),
        beforeSend: function(){
          link.addClass('loading');
        },
        success: function(data){
          var textarea = parent.find('textarea').first();
              lineHeight = 14;

          link.removeClass('loading')

          if(!link.hasClass("add_comment_bottom_link")){
            link.removeClass('inactive');
          }

          container.first().hide();

          parent.append(data);

          textarea.focus();
          new MBP.autogrow(textarea, lineHeight);
        }
      });
    }
  });

  $(".stream").delegate("a.cancel_new_comment", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this);
        form = link.closest("form"),
        commentActionLink = link.closest(".bottom_bar").find("a.comment_action").first();
        container = link.closest('.bottom_bar').find('.add_comment_bottom_link_container');

    if(container.length > 0 ){
      container.first().show();
    }

    commentActionLink.addClass("inactive");
    form.remove();
  });

  $(".new_comment").live("submit", function(evt){
    evt.preventDefault();
    var form = $(this);

    $.post(form.attr('action')+"?format=mobile", form.serialize(), function(data){
      var bottomBar = form.closest('.bottom_bar').first(),
          container = bottomBar.find('.add_comment_bottom_link_container'),
          commentActionLink = bottomBar.find("a.comment_action").first();
          reactionLink = bottomBar.find(".show_comments"),
          commentCount = bottomBar.find(".comment_count");

      if(container.length > 0) {
        container.before(data);
        form.remove();
        container.show();

      } else {
        var container = $("<div class='comments_container '></div>"),
            comments = $("<ul class='comments'></ul>");

        comments.html(data);
        container.append(comments);
        form.remove();
        container.appendTo(bottomBar)
      }

      console.log(reactionLink.text());

      reactionLink.text(reactionLink.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentCount.text(commentCount.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentActionLink.addClass("inactive");
    }, 'html');
  });

});
