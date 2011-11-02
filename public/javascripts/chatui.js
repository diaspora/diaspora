var logout = 0;
var MINI_TITLE = null;

// Unloading the page
$(window).unload(function () {
  if (logout) {
    Chat.disconnect();
  } else {
    Chat.pause();
    storeConnectionInfo();
    storeUIInfo();
  }
});

$(window).bind('beforeunload', function () {
  Chat.send($pres({
    'type': 'unavailable'
  }));
  Chat.bosh.flush();
})

// Page loaded
$(document).ready(function () {

  // Save the page title
  MINI_TITLE = document.title;
	
  // Sets the good roster max-height
  jQuery(window).resize(adaptRosterMini);

  // Logouts when Jappix is closed
  if (BrowserDetect.browser == 'Opera') {
    // Emulates onbeforeunload on Opera (link clicked)
    jQuery('a[href]:not([onclick])').click(function () {
      // Link attributes
      var href = jQuery(this).attr('href') || '';
      var target = jQuery(this).attr('target') || '';

      // Not new window or JS link
      if (href && !href.match(/^#/i) && !target.match(/_blank|_new/i)) saveSessionMini();
    });

    // Emulates onbeforeunload on Opera (form submitted)
    jQuery('form:not([onsubmit])').submit(saveSessionMini);
  }

  $('a').click(function () {
    window.onbeforeunload = null;
  });

  $("#logout").click(function () {
    logout = 1;
  });

  // Get connection state
  var sid = localStorage.getItem("sid");
  var rid = localStorage.getItem("rid");
  var jid = localStorage.getItem("jid");

  var suspended = false;

  // Check if connection state is valid
  if (sid != null && rid != null && jid != null) {
    suspended = true;
    Chat.attach(jid, sid, rid);
    // Try to restore the DOM
    var dom = localStorage.getItem("dom");
    var stamp = localStorage.getItem("stamp");

    // Invalid stored DOM?
    if (dom && isNaN(jQuery(dom).find('a.jm_pane.jm_button span.jm_counter').text())) dom = null;

    // get last rosters
    Chat.rosters = $.makeArray(JSON.parse(localStorage.getItem("roster")));

  } else {

    var user = localStorage.getItem("user");
    var pass = localStorage.getItem("pass");
    localStorage.removeItem("user");
    localStorage.removeItem("pass");

    // Create HTML chat menu
    dom = '<div class="jm_position">' + '<div class="jm_conversations"></div>' + '<div class="jm_starter">' + '<div class="jm_roster">' + '<div class="jm_actions">' + '<a class="jm_logo jm_images" href="javascript:void(0)"></a>' + '<a class="jm_one-action jm_available jm_images" title="Go offline" href="javascript:void(0)"></a>' + '</div>' + '<div class="jm_buddies"></div>' + '</div>' + '<a class="jm_pane jm_button jm_images" href="#">' + '<span class="jm_counter jm_images">Please wait...</span>' + '</a>' + '</div>' + '</div>';

    Chat.start(user, pass);
  }

  // Create the DOM
  jQuery('body').append('<div id="jappix_mini">' + dom + '</div>');

  // Adapt roster height
  adaptRosterMini();

  // The click events
  jQuery('#jappix_mini a.jm_button').click(function () {
    // Using a try/catch override IE issues
    try {
      // Presence counter
      var counter = '#jappix_mini a.jm_pane.jm_button span.jm_counter';

      // Cannot open the roster?
      if (jQuery(counter).text() == "Please wait...") return false;

      // Not yet connected?
      if (jQuery(counter).text() == "Chat") {
        // Remove the animated bubble
        jQuery('#jappix_mini div.jm_starter span.jm_animate').stopTime().remove();

        // Add a waiting marker
        jQuery(counter).text("Please wait...");
      }

      // Normal actions
      if (!jQuery(this).hasClass('jm_clicked')) showRosterMini();
      else hideRosterMini();
    } catch (e) {} finally {
      return false;
    }
  });

  jQuery('#jappix_mini div.jm_actions a.jm_available').click(function () {
	  if (Chat.presence == 0) {
		Chat.offline();
		jQuery(this).removeClass('jm_available');
		jQuery(this).addClass('jm_unavailable');
		jQuery(this).attr("title","Go online");
	  } else {
		Chat.online();
		jQuery(this).removeClass('jm_unavailable');
		jQuery(this).addClass('jm_available');
		jQuery(this).attr("title","Go offline");
	  }
  });

  // Hides the roster when clicking away of Jappix Mini
  jQuery(document).click(

  function (evt) {
    if (!jQuery(evt.target).parents('#jappix_mini').size() && !exists('#jappix_popup')) hideRosterMini();
  });

  // Hides all panes double clicking away of Jappix Mini
  jQuery(document).dblclick(

  function (evt) {
    if (!jQuery(evt.target).parents('#jappix_mini').size() && !exists('#jappix_popup')) switchPaneMini();
  });

  // Suspended session resumed?
  if (suspended) {
    // Restore chat input values
    jQuery('#jappix_mini div.jm_conversation input.jm_send-messages').each(

    function () {
      var chat_value = jQuery(this).attr('data-value');

      if (chat_value) jQuery(this).val(chat_value);
    });

    // Restore buddy click events
    jQuery('#jappix_mini a.jm_friend').click(function () {
      // Using a try/catch override IE issues
      try {
        chatMini('chat', unescape(jQuery(this).attr('data-xid')), unescape(jQuery(this).attr('data-nick')), jQuery(this).attr('data-hash'));
      } catch (e) {} finally {
        return false;
      }
    });

    // Restore chat click events
    jQuery('#jappix_mini div.jm_conversation').each(

    function () {
      chatEventsMini(jQuery(this).attr('data-type'), unescape(jQuery(
      this).attr('data-xid')), jQuery(this).attr('data-hash'));
    });

    // Scroll down to the last message
    var scroll_hash = jQuery('#jappix_mini div.jm_conversation:has(a.jm_pane.jm_clicked)').attr('data-hash');
    var scroll_position = localStorage.getItem("scroll");

    // Any scroll position?
    if (scroll_position) scroll_position = parseInt(scroll_position);

    if (scroll_hash) {
      // Use a timer to override the DOM lag issue
      jQuery(document).oneTime(200, function () {
        messageScrollMini(scroll_hash, scroll_position);
      });
    }

    // Update title notifications
    notifyTitleMini();
  }
});

function storeUIInfo() {

  localStorage.setItem("dom", jQuery('#jappix_mini').html());

  // Save the scrollbar position
  var scroll_position = '';
  var scroll_hash = jQuery('#jappix_mini div.jm_conversation:has(a.jm_pane.jm_clicked)').attr('data-hash');

  if (scroll_hash) scroll_position = document.getElementById('received-' + scroll_hash).scrollTop + '';

  localStorage.setItem("scroll", scroll_position);
  localStorage.setItem("stamp", getTimeStamp());

}

function adaptRosterMini() {
  // Process the new height
  var height = jQuery(window).height() - 70;

  // Apply the new height
  jQuery('#jappix_mini div.jm_roster div.jm_buddies').css('max-height', height);
}

// Manages and creates a chat


function chatMini(type, xid, nick, hash, show_pane) {
  var current = '#jappix_mini #chat-' + hash;

  // Not yet added?
  if (!exists(current)) {

    // Create the HTML markup
    var html = '<div class="jm_conversation jm_type_' + type + '" id="chat-' + hash + '" data-xid="' + escape(xid) + '" data-type="' + type + '" data-nick="' + escape(nick) + '" data-hash="' + hash + '" data-origin="' + escape(cutResource(xid)) + '">' + '<div class="jm_chat-content">' + '<div class="jm_actions">' + '<span class="jm_nick">' + nick + '</span>';

    html += '<a class="jm_one-action jm_close jm_images" title="' + "Close" + '" href="#"></a>';

    html += '</div>' +

    '<div class="jm_received-messages" id="received-' + hash + '"></div>' + '<form action="#" method="post">' + '<input type="text" class="jm_send-messages" name="body" autocomplete="off" />' + '<input type="hidden" name="xid" value="' + xid + '" />' + '<input type="hidden" name="type" value="' + type + '" />' + '</form>' + '</div>' + '<a class="jm_pane jm_chat-tab jm_images" href="#">' + '<span class="jm_name">' + nick.htmlEnc() + '</span>' + '</a>' + '</div>';

    jQuery('#jappix_mini div.jm_conversations').prepend(html);

    // Get the presence of this friend
    var selector = jQuery('#jappix_mini a#friend-' + hash + ' span.jm_presence');

    // Default presence
    var show = 'available';

    // Read the presence
    if (selector.hasClass('jm_unavailable')) show = 'unavailable';
    else if (selector.hasClass('jm_chat')) show = 'chat';
    else if (selector.hasClass('jm_away')) show = 'away';
    else if (selector.hasClass('jm_xa')) show = 'xa';
    else if (selector.hasClass('jm_dnd')) show = 'dnd';

    // Create the presence marker
    jQuery(current + ' a.jm_chat-tab').prepend('<span class="jm_presence jm_images jm_' + show + '"></span>');

    // The click events
    chatEventsMini(type, xid, hash);
  }

  // Focus on our pane
  if (show_pane != false) jQuery(document).oneTime(10, function () {
    switchPaneMini('chat-' + hash, hash);
  });

  return false;
}

// Events on the chat tool


function chatEventsMini(type, xid, hash) {
  var current = '#jappix_mini #chat-' + hash;

  // Submit the form
  jQuery(current + ' form').submit(function () {
    return sendMessageMini(this);
  });

  // Click on the tab
  jQuery(current + ' a.jm_chat-tab').click(function () {
    // Using a try/catch override IE issues
    try {
      // Not yet opened: open it!
      if (!jQuery(this).hasClass('jm_clicked')) {
        // Show it!
        switchPaneMini('chat-' + hash, hash);

        // Clear the eventual notifications
        clearNotificationsMini(hash);
      }

      // Yet opened: close it!
      else switchPaneMini();
    } catch (e) {} finally {
      return false;
    }
  });

  // Click on the close button
  jQuery(current + ' a.jm_close').click(function () {
    // Using a try/catch override IE issues
    try {
      jQuery(current).remove();

    } catch (e) {} finally {
      return false;
    }
  });

  // Click on the chat content
  jQuery(current + ' div.jm_received-messages').click(function () {
    try {
      jQuery(document).oneTime(10, function () {
        jQuery(current + ' input.jm_send-messages').focus();
      });
    } catch (e) {}
  });

  // Focus on the chat input
  jQuery(current + ' input.jm_send-messages').focus(function () {
    clearNotificationsMini(hash);
  })

  // Change on the chat input
  .keyup(function () {
    jQuery(this).attr('data-value', jQuery(this).val());
  });
}

// Clears the notifications


function clearNotificationsMini(hash) {
  // Not focused?
  if (!isFocused()) return false;

  // Remove the notifications counter
  jQuery('#jappix_mini #chat-' + hash + ' span.jm_notify').remove();

  // Update the page title
  notifyTitleMini();

  return true;
}

// Updates the page title with the new notifications


function notifyTitleMini() {

  // No saved title? Abort!
  if(MINI_TITLE == null)
    return false;
	
  // Page title code
  var title = MINI_TITLE;
	
  // Count the number of notifications
  var number = 0;

  jQuery('#jappix_mini span.jm_notify span.jm_notify_middle').each(

  function () {
    number = number + parseInt(jQuery(this).text());
  });

  // No new stuffs? Reset the title!
  if (number) title = '[' + number + '] ' + title;

  // Apply the title
  document.title = title;

  return true;
}

// Sends a given message


function sendMessageMini(aForm) {
  try {
    var body = trim(aForm.body.value);
    var xid = aForm.xid.value;
    var type = aForm.type.value;
    var hash = MD5.hexdigest(xid);

    if (body && xid) {
      Chat.sendMessage(xid, body); // Send message
      // Clear the input
      aForm.body.value = '';

      // Display the message we sent
      displayMessageMini(type, body, Chat.bosh.jid, 'me', hash, getCompleteTime(), getTimeStamp(), 'user-message');

    }
  } catch (e) {} finally {
    return false;
  }
}

// Generates the asked smiley image


function smileyMini(image, text) {
  return ' <img class="jm_smiley jm_smiley-' + image + ' jm_images" alt="' + encodeQuotes(text) + '" src="../images/blank.gif" /> ';
}

// Apply links in a string


function applyLinks(string, mode, style) {
  // Special stuffs
  var style, target;

  // Links style
  if (!style) style = '';
  else style = ' style="' + style + '"';

  // Open in new tabs
  if (mode != 'xhtml-im') target = ' target="_blank"';
  else target = '';

  // XMPP address
  string = string.replace(/(\s|<br \/>|^)(([a-zA-Z0-9\._-]+)@([a-zA-Z0-9\.\/_-]+))(,|\s|$)/gi, '$1<a href="xmpp:$2" target="_blank"' + style + '>$2</a>$5');

  // Simple link
  string = string.replace(/(\s|<br \/>|^|\()((https?|ftp|file|xmpp|irc|mailto|vnc|webcal|ssh|ldap|smb|magnet|spotify)(:)([^<>'"\s\)]+))/gim, '$1<a href="$2"' + target + style + '>$2</a>');
  return string;
}

// When message is received


function displayMessageMini(type, body, xid, nick, hash, time, stamp, message_type) {
  if (!hash) hash = MD5.hexdigest(xid);

  // Define the target div
  var target = '#jappix_mini #chat-' + hash;
  
  // Create the chat if it does not exist
  if (!exists(target)) chatMini(type, xid, nick, hash, false);

  // Generate path
  var path = '#chat-' + hash;

  // Can scroll?
  var cont_scroll = document.getElementById('received-' + hash);
  var can_scroll = false;

  if (!cont_scroll.scrollTop || ((cont_scroll.clientHeight + cont_scroll.scrollTop) == cont_scroll.scrollHeight)) can_scroll = true;

  // Remove the previous message border if needed
  var last = jQuery(path + ' div.jm_group:last');
  var last_stamp = parseInt(last.attr('data-stamp'));
  var last_b = jQuery(path + ' b:last');
  var last_xid = last_b.attr('data-xid');
  var last_type = last.attr('data-type');
  var header = '';

  // Write the message date
  if (nick) header += '<span class="jm_date">' + time + '</span>';

  // Write the buddy name at the top of the message group
  if (type == 'groupchat') header += '<b style="color: ' + generateColor(nick) + ';" data-xid="' + encodeQuotes(xid) + '">' + nick.htmlEnc() + '</b>';
  else if (nick == 'me') header += '<b class="jm_me" data-xid="' + encodeQuotes(xid) + '">You</b>';
  else header += '<b class="jm_him" data-xid="' + encodeQuotes(xid) + '">' + nick.htmlEnc() + '</b>';

  // Apply the /me command
  var me_command = false;

  if (body.match(/^\/me /i)) {
    body = body.replace(/^\/me /i, nick + ' ');

    // Marker
    me_command = true;
  }

  // HTML-encode the message
  body = body.htmlEnc();

  // Apply the smileys
  body = body.replace(/(;-?\))(\s|$)/gi, smileyMini('wink', '$1')).replace(/(:-?3)(\s|$)/gi, smileyMini('waii', '$1')).replace(/(:-?\()(\s|$)/gi, smileyMini('unhappy', '$1')).replace(/(:-?P)(\s|$)/gi, smileyMini('tongue', '$1')).replace(/(:-?O)(\s|$)/gi, smileyMini('surprised', '$1')).replace(/(:-?\))(\s|$)/gi, smileyMini('smile', '$1')).replace(/(\^_?\^)(\s|$)/gi, smileyMini('happy', '$1')).replace(/(:-?D)(\s|$)/gi, smileyMini('grin', '$1'));

  // Filter the links
  body = applyLinks(body, 'mini');

  // Generate the message code
  if (me_command) body = '<em>' + body + '</em>';

  body = '<p>' + body + '</p>';

  jQuery('#jappix_mini #chat-' + hash + ' div.jm_received-messages').append('<div class="jm_group jm_' + message_type + '" data-type="' + message_type + '" data-stamp="' + stamp + '">' + header + body + '</div>');

  // Scroll to this message
  if (can_scroll) messageScrollMini(hash);
  
  // Notify the user if not focused
  if((!jQuery(target + ' a.jm_chat-tab').hasClass('jm_clicked') || !isFocused()) && (message_type == 'user-message'))
	  notifyMessageMini(hash);
}

//Notifies incoming chat messages
function notifyMessageMini(hash) {
	// Define the paths
	var tab = '#jappix_mini #chat-' + hash + ' a.jm_chat-tab';
	var notify = tab + ' span.jm_notify';
	var notify_middle = notify + ' span.jm_notify_middle';
	
	// Notification box not yet added
	if(!exists(notify))
		jQuery(tab).append(
			'<span class="jm_notify">' + 
				'<span class="jm_notify_left jm_images"></span>' + 
				'<span class="jm_notify_middle">0</span>' + 
				'<span class="jm_notify_right jm_images"></span>' + 
			'</span>'
		);
	
	// Increment the notification number
	var number = parseInt(jQuery(notify_middle).text());
	jQuery(notify_middle).text(number + 1);
	
	// Change the page title
	notifyTitleMini();
}


// Scrolls to the last chat message


function messageScrollMini(hash, position) {
  var id = document.getElementById('received-' + hash);

  // No defined position?
  if (!position) position = id.scrollHeight;

  id.scrollTop = position;
}

// Switches to a given point


function switchPaneMini(element, hash) {
  // Hide every item
  jQuery('#jappix_mini a.jm_pane').removeClass('jm_clicked');
  jQuery('#jappix_mini div.jm_roster, #jappix_mini div.jm_chat-content').hide();

  // Show the asked element
  if (element && (element != 'roster')) {
    var current = '#jappix_mini #' + element;

    jQuery(current + ' a.jm_pane').addClass('jm_clicked');
    jQuery(current + ' div.jm_chat-content').show();

    // Use a timer to override the DOM lag issue
    jQuery(document).oneTime(10, function () {
      jQuery(current + ' input.jm_send-messages').focus();
    });

    // Scroll to the last message
    if (hash) messageScrollMini(hash);
  }
}

// Shows the roster


function showRosterMini() {
  switchPaneMini('roster');
  jQuery('#jappix_mini div.jm_roster').show();
  jQuery('#jappix_mini a.jm_button').addClass('jm_clicked');
}

// Hides the roster


function hideRosterMini() {
  jQuery('#jappix_mini div.jm_roster').hide();
  jQuery('#jappix_mini a.jm_button').removeClass('jm_clicked');  
}

function manageUI(event, jid, nick, state, status) {
  var nameinthelist;
  switch (event) {
  case "connecting":

    break;
  case "connected":
    // Update the roster
    jQuery('#jappix_mini a.jm_pane.jm_button span.jm_counter').text('0');
    showRosterMini();
    break;
  case "disconnecting":

    break;
  case "disconnected":
    break;
  case "offline":


    break;
  case "addroster":
    // Element
    var hash = MD5.hexdigest(jid);
    var element = '#jappix_mini a.jm_friend#friend-' + hash;

    // Yet added?
    if (exists(element)) return false;

    // Generate the path
    var path = '#jappix_mini div.jm_roster div.jm_buddies';

    // Append this buddy content
    var code = '<a class="jm_friend jm_offline" id="friend-' + hash + '" data-xid="' + escape(jid) + '" data-nick="' + escape(nick) + '" data-hash="' + hash + '" href="#"><span class="jm_presence jm_images jm_unavailable"></span>' + nick.htmlEnc() + '<br><span class="jm_status"></span></a>';

    jQuery(path).prepend(code);

    // Click event on this buddy
    jQuery(element).click(function () {
      // Using a try/catch override IE issues
      try {
        chatMini('chat', jid, nick, hash);
      } catch (e) {} finally {
        return false;
      }
    });

    return true;

    break;
  case "removeroster":
    var hash = MD5.hexdigest(jid);
    // Remove the buddy from the roster
    jQuery('#jappix_mini a.jm_friend#friend-' + hash).remove();
    return true;
    break;
  case "updatepresence":
    var hash = MD5.hexdigest(jid);
    // Friend path
    var chat = '#jappix_mini #chat-' + hash;
    var friend = '#jappix_mini a#friend-' + hash;
    var send_input = chat + ' input.jm_send-messages';

    // Is this friend online?
    if (state == 'unavailable') {
      // Offline marker
      jQuery(friend).addClass('jm_offline').removeClass('jm_online');

      // Disable the chat tools
      jQuery(chat).addClass('jm_disabled');
      jQuery(send_input).attr('disabled', true).attr('data-value', "Unavailable").val("Unavailable");
    } else {
      // Online marker
      jQuery(friend).removeClass('jm_offline').addClass('jm_online');

      // Enable the chat input
      jQuery(chat).removeClass('jm_disabled');
      jQuery(send_input).removeAttr('disabled').val('');
    }

    // Change the show presence of this buddy
    jQuery(friend + ' span.jm_presence, ' + chat + ' span.jm_presence').attr('class', 'jm_presence jm_images jm_' + state);

    // Change the status of this buddy
    jQuery(friend + ' span.jm_status').text(status);

    // Update the presence counter
    updateRosterMini();
    break;
  }
}

// Updates the roster counter


function updateRosterMini() {
  jQuery('#jappix_mini a.jm_button span.jm_counter').text(
  jQuery('#jappix_mini a.jm_online').size());
}