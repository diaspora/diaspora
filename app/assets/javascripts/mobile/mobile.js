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
//= require bootstrap
//= require diaspora
//= require helpers/i18n
//= require widgets/timeago
//= require mobile/mobile_file_uploader
//= require mobile/profile_aspects
//= require mobile/tag_following
//= require mobile/mobile_comments.js

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
