// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require jquery.charcount
//= require js-routes
//= require autosize
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
//= require mobile/publisher
//= require mobile/mobile_comments

$(document).ready(function(){

  $('.shield a').click(function(){
    $(this).parents(".stream_element").removeClass("shield-active");
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

  // init autosize plugin
  autosize($("textarea"));

  /* Drawer menu */
  $("#menu-badge").bind("tap click", function(evt){
    evt.preventDefault();
    $("#app").toggleClass("draw");
  });

  /* Show / hide aspects in the drawer */
  $("#all_aspects").bind("tap click", function(evt){
    evt.preventDefault();
    $("#all_aspects + li").toggleClass("hide");
  });

  /* Show / hide followed tags in the drawer */
  $("#followed_tags > a").bind("tap click", function(evt){
    evt.preventDefault();
    $("#followed_tags + li").toggleClass("hide");
  });

  /* Heart toggle */
  $(".like-action", ".stream").bind("tap click", function(evt){
    evt.preventDefault();
    var link = $(this),
        likeCounter = $(this).closest(".stream_element").find(".like-count"),
        url = link.data("url");

    if(!link.hasClass("loading")){
      if(link.hasClass('inactive')) {
        $.ajax({
          url: url,
          dataType: 'json',
          type: 'POST',
          beforeSend: showLoader(link),
          success: function(data){
            removeLoader(link);
            link.data("url", url + "/" + data.id);

            if(likeCounter){
              likeCounter.text(parseInt(likeCounter.text(), 10) + 1);
            }
          }
        });
      }
      else if(link.hasClass("active")){
        $.ajax({
          url: url,
          dataType: 'json',
          type: 'DELETE',
          beforeSend: showLoader(link),
          complete: function(){
            removeLoader(link);
            link.data("url", url.replace(/\/\d+$/, ""));

            if(likeCounter){
              likeCounter.text(parseInt(likeCounter.text(), 10) - 1);
            }
          }
        });
      }
    }
  });

  /* Reshare */
  $(".reshare-action:not(.disabled)", ".stream").bind("tap click", function(evt){
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
});
// @license-end
