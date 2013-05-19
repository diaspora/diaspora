/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require jquery.charcount
//= require mbp-modernizr-custom
//= require mbp-respond.min
//= require mbp-helper
//= require jquery.autoSuggest.custom
//= require fileuploader-custom

$(document).ready(function(){

  $('.shield a').click(function(){
    $(this).parents('.shield_wrapper').remove();
    return false;
  });
  var showLoader = function(link){
    link.addClass('loading');
  };

  var removeLoader = function(link){
    link.removeClass('loading')
         .toggleClass('active')
         .toggleClass('inactive');
  };

  /* Heart toggle */
  $(".like_action", ".stream").bind("tap click", function(evt){
    evt.preventDefault();
    var link = $(this),
        likeCounter = $(this).closest(".stream_element").find("like_count"),
        href = link.attr("href");

    if(!link.hasClass("loading")){
      if(link.hasClass('inactive')) {
        $.ajax({
          url: href,
          dataType: 'json',
          type: 'POST',
          beforeSend: showLoader(link),
          success: function(data){
            removeLoader(link);
            link.attr("href", href + "/" + data["id"]);

            if(likeCounter){
              likeCounter.text(parseInt(likeCounter.text) + 1);
            }
          }
        });
      }
      else if(link.hasClass("active")){
        $.ajax({
          url: link.attr("href"),
          dataType: 'json',
          type: 'DELETE',
          beforeSend: showLoader(link),
          complete: function(data){
            removeLoader(link);
            link.attr("href", href.replace(/\/\d+$/, ''));

            if(likeCounter){
              likeCounter.text(parseInt(likeCounter.text) - 1);
            }
          }
        });
      }
    }
  });

  /* Reshare */
  $(".reshare_action", ".stream").bind("tap click", function(evt){
    evt.preventDefault();

    var link = $(this),
        href = link.attr("href"),
        confirmText = link.attr('title');

    if(!link.hasClass("loading")) {
      if(link.hasClass('inactive')) {
        if(confirm(confirmText)) {
          $.ajax({
            url: href + "&provider_display_name=mobile",
            dataType: 'json',
            type: 'POST',
            beforeSend: showLoader(link),
            success: function(data){
              removeLoader(link);
            },
            error: function(data){
              removeLoader(link);
              alert("Failed to reshare!");
            }
          });
        }
      }
    }
  });

  /* Show comments */
  $("a.show_comments", ".stream").bind("tap click", function(evt){
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
        context: link,
        success: function(data){
          var textarea = function(target) { return target.closest(".stream_element").find('textarea.comment_box').first()[0] };
          link.removeClass('loading')

          if(!link.hasClass("add_comment_bottom_link")){
            link.removeClass('inactive');
          }

          container.hide();
          parent.append(data);

          MBP.autogrow(textarea($(this)));
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
          reactionLink = bottomBar.find(".show_comments").first(),
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


  $(".service_icon").bind("tap click", function(evt) {
    var service = $(this).toggleClass("dim"),
      selectedServices = $("#new_status_message .service_icon:not(.dim)"),
      provider = service.attr("id"),
      hiddenField = $("#new_status_message input[name='services[]'][value='" + provider + "']"),
      publisherMaxChars = 40000,
      serviceMaxChars;


    $("#new_status_message .counter").remove();

    $.each(selectedServices, function() {
      serviceMaxChars = parseInt($(this).attr("maxchar"));
      if(publisherMaxChars > serviceMaxChars) {
        publisherMaxChars = serviceMaxChars;
      }
    });

    $('#status_message_text').charCount({allowed: publisherMaxChars, warning: publisherMaxChars/10 });

    if(hiddenField.length > 0) { hiddenField.remove(); }
    else {
      $("#new_status_message").append(
        $("<input/>", {
          name: "services[]",
          type: "hidden",
          value: provider
        })
      );
    }
  });
  
  $("#submit_new_message").bind("tap click", function(evt){
    evt.preventDefault();
    $("#new_status_message").submit();
  });

});

function createUploader(){

   var aspectIds = gon.aspect_ids;

   var uploader = new qq.FileUploaderBasic({
       element: document.getElementById('file-upload-publisher'),
       params: {'photo' : {'pending' : 'true', 'aspect_ids' : aspectIds},},
       allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'tiff'],
       action: "/photos",
       debug: true,
       button: document.getElementById('file-upload-publisher'),
       sizeLimit: 4194304,

       onProgress: function(id, fileName, loaded, total){
        var progress = Math.round(loaded / total * 100 );
         $('#fileInfo-publisher').text(fileName + ' ' + progress + '%');
       },

       messages: {
          typeError: Diaspora.I18n.t("photo_uploader.invalid_ext"),
          sizeError: Diaspora.I18n.t("photo_uploader.new_photo.size_error"),
          emptyError: Diaspora.I18n.t("photo_uploader.new_photo.empty")
       },

       onSubmit: function(id, fileName){
        $('#file-upload-publisher').addClass("loading");
        $('#publisher_textarea_wrapper').addClass("with_attachments");
        $('#photodropzone').append(
          "<li class='publisher_photo loading' style='position:relative;'>" +
            "<img alt='Ajax-loader2' src='/assets/ajax-loader2.gif' />" +
          "</li>"
          );
       },

       onComplete: function(id, fileName, responseJSON) {
        $('#fileInfo-publisher').text(Diaspora.I18n.t("photo_uploader.completed", {'file': fileName}));
        var id = responseJSON.data.photo.id,
            url = responseJSON.data.photo.unprocessed_image.url,
            currentPlaceholder = $('li.loading').first();

        $('#publisher_textarea_wrapper').addClass("with_attachments");
        $('#new_status_message').append("<input type='hidden' value='" + id + "' name='photos[]' />");

        // replace image placeholders
        var img = currentPlaceholder.find('img');
        img.attr('src', url);
        img.attr('data-id', id);
        currentPlaceholder.removeClass('loading');
        currentPlaceholder.append("<div class='x'>X</div>" +
            "<div class='circle'></div>");
        ////

        var publisher = $('#publisher'),
            textarea = publisher.find('textarea');

        publisher.find("input[type='submit']").removeAttr('disabled');

        $('.x').bind('click', function(){
          var photo = $(this).closest('.publisher_photo');
          photo.addClass("dim");
          $.ajax({url: "/photos/" + photo.children('img').attr('data-id'),
                  dataType: 'json',
                  type: 'DELETE',
                  success: function() {
                            photo.fadeOut(400, function(){
                              photo.remove();
                              if ( $('.publisher_photo').length == 0){
                                $('#publisher_textarea_wrapper').removeClass("with_attachments");
                              }
                            });
                          }
                  });
        });
       },

       onAllComplete: function(completed_files){
       }

   });
}
createUploader();
