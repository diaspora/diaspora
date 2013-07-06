/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require jquery.autoSuggest.custom

$(document).ready(function(){

  if ($('#first_unread').length > 0) {
    $("html").scrollTop($('#first_unread').offset().top-45);
  }

  $('time.timeago').each(function(i,e) {
    var jqe = $(e);
    jqe.attr('data-original-title', new Date(jqe.attr('datetime')).toLocaleString());
    jqe.attr('title', '');
  });

  $('.timeago').tooltip();
  $('.timeago').timeago();

  $('time.timeago').each(function(i,e) {
    var jqe = $(e);
    jqe.attr('title', '');
  });

  $('.conversation-wrapper').live('click', function(){
    var conversation_path = $(this).data('conversation-path');

    $.getScript(conversation_path, function() {
      Diaspora.page.directionDetector.updateBinds();
    });

    history.pushState(null, "", conversation_path);

    var conv = $(this).children('.stream_element'),
        cBadge = $("#message_inbox_badge .badge_count");
    if(conv.hasClass('unread') ){
      conv.removeClass('unread');
    }
    if(cBadge.html() !== null) {
      cBadge.html().replace(/\d+/, function(num){
        num = parseInt(num);
        cBadge.html(parseInt(num)-1);
        if(num == 1) {
          cBadge.addClass("hidden");
        }
      });
    }

    return false;
  });

  $(window).bind("popstate", function(){
    if (location.href.match(/conversations\/\d+/) !== null) {
	  $.getScript(location.href, function() {
        Diaspora.page.directionDetector.updateBinds();
      });
      return false;
    }
  });

  resize();
  $(window).resize(function(){
    resize();
  });

  $('#conversation_inbox .stream').infinitescroll({
    navSelector  : ".pagination",
                 // selector for the paged navigation (it will be hidden)
    nextSelector : ".pagination a.next_page",
                 // selector for the NEXT link (to page 2)
    itemSelector : "#conversation_inbox .conversation",
                 // selector for all items you'll retrieve
    localMode: true,
    debug: false,
    donetext: "no more.",
    loadingText: "",
    loadingImg: '/assets/ajax-loader.gif'
  }, function(){
    $('.conversation-wrapper', '.stream').bind('mousedown', function(){
      bindIt($(this));
    });
  });

  // kill scroll binding
  $(window).unbind('.infscr');

  // hook up the manual click guy.
  $('a.next_page').click(function(){
    $(document).trigger('retrieve.infscr');
    return false;
  });

  // remove the paginator when we're done.
  $(document).ajaxError(function(e,xhr,opt){
    if (xhr.status == 404) { $('a.next_page').remove(); }
  });

  $('#reply_to_conversation').live('click', function(evt) {
    evt.preventDefault();
     $('html, body').animate({scrollTop:$(window).height()}, 'medium', function(){
      $('#message_text').focus();
     });
  });

  $('.participants_link').popover({
    html: true,
    title: function(){
       return Diaspora.I18n.t('conversation.participants') + '<a href="#" class="close"><div class="icons-deletelabel"></div></a>';
    },
    content: function() {
      var conv_id = $(this).data('conversation-id');
      return $('[data-content-conversation-id="' + conv_id + '"]').html();
    },
    trigger: 'manual'
  });
  
  $('.participants_link > span').tooltip({placement: 'bottom'});

  $('.participants_link').click(function(e) {
    e.stopPropagation();
    var self = $(this);
    self.popover('show');
    var popup = self.data('popover').$tip[0];

    // attach tooltips to each avatar showing the name
    $(popup).find('.avatar').tooltip({ placement: 'bottom' });

    // register handler for the close button
    var close = $(popup).find('.close');
    close.click(function(){
      self.popover('hide');
    })
  });
});

var resize = function(){
  var inboxSidebar = $('#conversation_inbox'),
      inboxSidebarOffset = inboxSidebar.offset().top,
      windowHeight = $(window).height();

  inboxSidebar.css('height', windowHeight - inboxSidebarOffset);
};
