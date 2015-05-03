// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require jquery.charcount
//= require js-routes
//= require mbp-modernizr-custom
//= require mbp-respond.min
//= require mbp-helper
//= require jquery.autoSuggest.custom
//= require fileuploader-custom
//= require rails-timeago
//= require underscore
//= require diaspora
//= require helpers/i18n
//= require widgets/timeago
//= require mobile/mobile_file_uploader
//= require mobile/profile_aspects

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

  /* Drawer menu */
  $('#menu_badge').bind("tap click", function(evt){
    evt.preventDefault();
    $("#app").toggleClass('draw');
  });

  /* Show / hide aspects in the drawer */
  $('#all_aspects').bind("tap click", function(evt){
    evt.preventDefault();
    $("#all_aspects + li").toggleClass('hide');
  });

  /* Show / hide followed tags in the drawer */
  $('#followed_tags').bind("tap click", function(evt){
    evt.preventDefault();
    $("#followed_tags + li").toggleClass('hide');
  });

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
          complete: function(){
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
            success: function(){
              removeLoader(link);
            },
            error: function(){
              removeLoader(link);
              alert(Diaspora.I18n.t('failed_to_reshare'));
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
        commentsContainer = function(){ return parent.find(".comment_container").first(); },
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
            commentsContainer().find('time.timeago').timeago();
          }
        });
      } else {
        existingCommentsContainer.show();
        existingCommentsContainer.find('time.timeago').timeago();
      }

      link.addClass('active');

    } else {
      $.ajax({
        url: link.attr('href'),
        success: function(data){
          parent.append(data);
          link.addClass('active');
          scrollToOffset(parent, commentsContainer());
          commentsContainer().find('time.timeago').timeago();
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
          link.removeClass('loading');

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
    var link = $(this),
        form = link.closest("form"),
        commentActionLink = link.closest(".bottom_bar").find("a.comment_action").first(),
        container = link.closest('.bottom_bar').find('.add_comment_bottom_link_container');

    if(container.length > 0 ){
      container.first().show();
    }

    commentActionLink.addClass("inactive");
    form.remove();
  });

  $(document).on("submit", ".new_comment", function(evt){
    evt.preventDefault();
    var form = $(this);

    $.post(form.attr('action')+"?format=mobile", form.serialize(), function(data){
      var bottomBar = form.closest('.bottom_bar').first(),
          container = bottomBar.find('.add_comment_bottom_link_container'),
          commentActionLink = bottomBar.find("a.comment_action").first(),
          reactionLink = bottomBar.find(".show_comments").first(),
          commentCount = bottomBar.find(".comment_count");

      if(container.length > 0) {
        container.before(data);
        form.remove();
        container.show();

      } else {
        var comments = $("<ul class='comments'></ul>");
        container = $("<div class='comments_container not_all_present'></div>");

        comments.html(data);
        container.append(comments);
        form.remove();
        container.appendTo(bottomBar);
      }

      reactionLink.text(reactionLink.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentCount.text(commentCount.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
      commentActionLink.addClass("inactive");
      bottomBar.find('time.timeago').timeago();
    }, 'html');
  });


  $(".service_icon").bind("tap click", function() {
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
// @license-end
