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

  $(".stream").delegate(".show_comments", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this),
        parent = link.closest(".bottom_bar").first(),
        commentsContainer = function(){ return parent.find(".comment_container").first(); }
        existingCommentsContainer = commentsContainer();

    if( link.hasClass('active') ) {
      existingCommentsContainer.hide();
      if(!link.hasClass('bottom_collapse')){
        link.removeClass('active');
      } else {
        parent.find(".show_comments").first().removeClass('active');
      }

      $('html,body').scrollTop(parent.offset().top - parent.closest(".stream_element").height() - 8);

    } else if( existingCommentsContainer.length > 0) {

      if(!existingCommentsContainer.hasClass('noComments')) {
        $.ajax({
          url: link.attr('href'),
          success: function(data){
            parent.append($(data).find('.comments_container').html());
            link.addClass('active');
            existingCommentsContainer.show();
            scrollToOffset(parent, commentsContainer());
          }
        });
      } else {
        existingCommentsContainer.show();
      }

      link.addClass('active');

    } else {
      $.ajax({
        url: link.attr('href'),
        success: function(data){
          parent.append(data);
          link.addClass('active');
          scrollToOffset(parent, commentsContainer());
        }
      });
    }

  });

  var scrollToOffset = function(parent, commentsContainer){
    var commentCount = commentsContainer.find("li.comment").length;
    if( commentCount > 3 ) {
      var lastComment = commentsContainer.find("li:nth-child("+(commentCount-4)+")");
      $('html,body').animate({
        scrollTop: lastComment.offset().top
      }, 1000);
    }
  };

  $(".stream").delegate("a.comment_action", "tap click", function(evt){
    evt.preventDefault();
    var link = $(this);

    if(link.hasClass('inactive')) {
      var parent = link.closest(".bottom_bar").first(),
          container = link.closest('.bottom_bar').find('.add_comment_bottom_link_container').first();

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

          container.hide();
          parent.append(data);
          new MBP.autogrow(textarea);
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
          reactionLink = bottomBar.find("a.show_comments").first(),
          commentCount = bottomBar.find(".comment_count");

      if(container.length > 0) {
        container.before(data);
        form.remove();
        container.show();

      } else {
        var container = $("<div class='comments_container not_all_present'></div>"),
            comments = $("<ul class='comments'></ul>");

        comments.html(data);
        container.append(comments);
        form.remove();
        container.appendTo(bottomBar)
      }

      reactionLink.text(reactionLink.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentCount.text(commentCount.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentActionLink.addClass("inactive");
    }, 'html');
  });

  $("#submit_new_message").bind("tap click", function(evt){
    evt.preventDefault();
    $("#new_status_message").submit();
  });

});
