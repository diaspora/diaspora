var pod_url = document.URL.split('/')[2].split(':')[0].split('/')[0];
var BOSH_URL = 'http://' + pod_url + ':5280/http-bind';

// Object to manage Rosters


function rosterState(jid, nick, resource) {
  this.jid = jid;
  this.nick = nick;
  this.resource = resource;
}

function fullJid(jid) {
  for (var i = 0; i < Chat.rosters.length; i++)
  if (jid == Chat.rosters[i].jid) return jid + "/" + Chat.rosters[i].resource;
  return -1;
}

function jidToNick(jid) {
  for (var i = 0; i < Chat.rosters.length; i++)
  if (jid == Chat.rosters[i].jid || jid == Chat.rosters[i].jid + "/" + Chat.rosters[i].resource) return Chat.rosters[i].nick;
  return -1;
}

// return index of a roster


function searchJid(jid) {
  for (i = 0; i < Chat.rosters.length; i++) {
    if (jid == Chat.rosters[i].jid) return i;
  }
  return -1;
}

function storeConnectionInfo() {

  // Storing Connection state + Rosters
  localStorage.setItem("sid", Chat.bosh.sid);
  localStorage.setItem("rid", Chat.bosh.rid);
  localStorage.setItem("jid", Chat.bosh.jid);
  localStorage.setItem("presence", Chat.presence);
  localStorage.setItem("roster", JSON.stringify(Chat.rosters));
}

function clearConnectionInfo() {
  localStorage.removeItem("sid");
  localStorage.removeItem("rid");
  localStorage.removeItem("jid");
  localStorage.removeItem("roster");
}

// Object to manage Connection State
var Chat = {

  bosh: null,
  // Connection
  rosters: [],
  // Rosters
  sid: null,
  from: null,
  to: null,
  presence: 0,
  // 0 - available | 1 - unavailable
  // Start the connection
  start: function (jid, pass) {
    Chat.bosh = new Strophe.Connection(BOSH_URL);
    Chat.bosh.connect(jid, pass, Chat.connectCallback);
  },

  // Attach existing connection
  attach: function (jid, sid, rid) {
    if (Chat.bosh == null || Chat.bosh.connected == false) {
      Chat.presence = localStorage.getItem("presence");
      Chat.bosh = new Strophe.Connection(BOSH_URL);
      Chat.bosh.attach(jid, sid, rid, Chat.connectCallback);
    }
  },

  // Pause actual connection
  pause: function () {
    Chat.bosh.pause();
  },

  // Disconnect actual connection
  disconnect: function () {
    clearConnectionInfo();
    Chat.bosh.sync = true;
    Chat.bosh.flush();
    Chat.bosh.disconnect();
  },

  offline: function () {
    Chat.send($pres({
      'type': 'unavailable'
    }).tree());
    Chat.presence = 1;
    manageUI("disconnected");
  },

  online: function () {
    Chat.send($pres().tree());    
    Chat.presence = 0;
    manageUI("connected");
  },

  // Send a message
  sendMessage: function (to, msg) {
    Chat.send($msg({
      'to': to,
      'type': 'chat'
    }).c('body').t(msg));
  },

  // Handler to receive message
  recvMessage: function (msg) {
    var from = msg.getAttribute('from').split('/')[0];
    var i = searchJid(from);
    if (i > -1) { // If message is received from a roster
      var nick = Chat.rosters[i].nick;
      var type = msg.getAttribute('type');
      var text = msg.getElementsByTagName('body');
      var hash = MD5.hexdigest(from);
      var message_type = 'user-message';

      // Read the delay
      var delay = msg.getAttribute('delay');
      var d_stamp;

      // Manage this delay
      if (delay) {
        time = relativeDate(delay);
        d_stamp = Date.jab2date(delay);
      } else {
        time = getCompleteTime();
        d_stamp = new Date();
      }

      // Get the stamp
      var stamp = extractStamp(d_stamp);

      if (type == 'chat' && text.length > 0) 
    	  displayMessageMini(type, text[0].textContent, from, nick, hash, time, stamp, message_type); // Handle in UI
    }
    return true;
  },

  // Send raw XMPP messages
  send: function (data) {
    Chat.bosh.send(data);
  },

  // Ask for rosters
  getRoster: function () {
    var id = Chat.bosh.getUniqueId('roster');
    var rosteriq = $iq({
      'id': id,
      'type': 'get'
    }).c('query', {
      'xmlns': Strophe.NS.ROSTER
    });
    Chat.bosh.addHandler(Chat.recvRoster, null, 'iq', 'result', id);
    Chat.bosh.send(rosteriq.tree());
  },

  // Handler for rosters
  recvRoster: function (e) {
    var query = e.getElementsByTagName('query')[0];
    var entries = query.getElementsByTagName('item');
    var temprost = [];
    for (var item = 0; item < entries.length; item++) {
      var nick = entries[item].getAttribute('name');
      var jid = Strophe.getBareJidFromJid(entries[item].getAttribute('jid'));
      if (!nick) { // If the roster has no nickname
        nick = getXIDNick(jid);
      }
      var i = searchJid(jid);
      if (i == -1) { // If is a new Roster
        temprost.push(new rosterState(jid, nick, ""));
      } else {
        temprost.push(new rosterState(jid, nick, Chat.rosters[i].resource));
      }
      manageUI("addroster", jid, nick);
    }
    Chat.rosters = temprost.slice(0);
    temprost.length = 0;
    (Chat.presence == 1) ? Chat.offline() : Chat.online();
    // hideDiv("chatloader");
    // showDiv("chatrosters");
    return true;
  },

  // Handler for Presence
  handlerPresence: function (presence) {
    var from = Strophe.getBareJidFromJid(presence.getAttribute('from'));
    var to = Strophe.getBareJidFromJid(presence.getAttribute('to'));
    if (from != to) { // If is not sent by me
      var i = searchJid(from);
      if (i > -1) { // If is a presence from a roster
        var nick = Chat.rosters[i].nick;
        var resource = Strophe.getResourceFromJid(presence.getAttribute('from'));

        var type = presence.getAttribute('type') ? presence.getAttribute('type') : 'available';
        var show = presence.getElementsByTagName('show').length ? Strophe.getText(presence.getElementsByTagName('show')[0]) : type;
        var status = presence.getElementsByTagName('status').length ? Strophe.getText(presence.getElementsByTagName('status')[0]) : '';

        manageUI("updatepresence", from, nick, show, status);
      }
    }
    return true;
  },

  connectCallback: function (status) {
    switch (status) {
    case Strophe.Status.ERROR:
      Chat.append_on_top("Error...<br />");
      break;
    case Strophe.Status.CONNFAIL:
      Chat.append_on_top("Connection error...<br />");
      break;
    case Strophe.Status.AUTHFAIL:
      Chat.append_on_top("Check jid/password<br />");
      break;
    case Strophe.Status.CONNECTING:
      manageUI("connecting");
      break;
    case Strophe.Status.CONNECTED:
      Chat.getRoster();
      // Chat.send($pres().tree());
      // Subscribe handlers for Messages, Presences and Calls
      Chat.bosh.addHandler(Chat.recvMessage, null, 'message');
      Chat.bosh.addHandler(Chat.handlerPresence, null, 'presence');
      (Chat.presence == 1) ? manageUI("offline") : manageUI("connected");
      break;
    case Strophe.Status.ATTACHED:
      // Chat.getRoster();
      (Chat.presence == 1) ? Chat.offline() : Chat.online();

      // Subscribe handlers for Messages, Presences and Calls
      Chat.bosh.addHandler(Chat.recvMessage, null, 'message');
      Chat.bosh.addHandler(Chat.handlerPresence, null, 'presence');
      (Chat.presence == 1) ? manageUI("offline") : manageUI("connected");
      break;
    case Strophe.Status.DISCONNECTED:
      manageUI("disconnected");
      break;
    case Strophe.Status.DISCONNECTING:
      manageUI("disconnecting");
      break;
    }
  }
}