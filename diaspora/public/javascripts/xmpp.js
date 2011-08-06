
var BOSH_URL = 'http://82.59.139.8:5280/http-bind'; // TO CHANGE

// Object to manage Rosters
function rosterState(jid, nick, resource) {
    this.jid = jid;
    this.nick = nick;
    this.resource = resource;
}

function fullJid(jid) {
    for ( var i = 0; i < Chat.rosters.length; i++)
        if (jid == Chat.rosters[i].jid)
            return jid + "/" + Chat.rosters[i].resource;
    return -1;
}

function jidToNick(jid) {
    for ( var i = 0; i < Chat.rosters.length; i++)
        if (jid == Chat.rosters[i].jid || jid == Chat.rosters[i].jid + "/" + Chat.rosters[i].resource)
            return Chat.rosters[i].nick;
    return -1;
}


// Object to manage Connection State
var Chat = {

    bosh: null, // Connection
    rosters: [], // Rosters
    sid: null,
    from: null,
    to: null,
    presence: 0, // 0 - available | 1 - unavailable

    // Start the connection
    start: function (jid, pass) {
        //        if (Chat.bosh == null || Chat.bosh.connected == false){
        //Chat.presence = localStorage.getItem("presence");
        Chat.bosh = new Strophe.Connection(BOSH_URL);
        Chat.bosh.connect(jid, pass, Chat.connect_callback);
    //        }
    //        else{ // Manage "Chat" button
    //            loginButton();
    //        }
    },
    // Attach existing connection
    attach: function (jid, sid, rid) {
        if (Chat.bosh == null || Chat.bosh.connected == false){
            Chat.presence = localStorage.getItem("presence");
            Chat.bosh = new Strophe.Connection(BOSH_URL);
            Chat.bosh.attach(jid, sid, rid, Chat.connect_callback);
        }
    },
    // Pause actual connection
    pause: function(){
        Chat.bosh.pause();
    },
    
    // Disconnect actual connection
    disconnect: function () {
        clearConnectionInfo();
        Chat.bosh.disconnect();
    },

    offline: function() {
        Chat.send($pres().c('show').t('unavailable'));
        Chat.presence = 1;
        manageUI("disconnected");
        Chat.append_on_top("Current status: offline<br />");
    },

    online: function() {
        Chat.send($pres().c('show').t('chat'));
        Chat.presence = 0;
        manageUI("connected");
    },
    
    // Send a message
    send_message: function (to, msg) {
        Chat.send($msg({
            'to': to,
            'type': 'chat'
        }
        ).c('body'
            ).t(msg));
    },

 

    // Handler to receive message
    recv_message: function (msg) {
        var from = msg.getAttribute('from').split('/')[0];
        var i = searchJid(from);
        if (i > -1){    // If message is received from a roster
            var nick = Chat.rosters[i].nick;
            var type = msg.getAttribute('type');
            var text = msg.getElementsByTagName('body');

            if ( type == 'chat' && text.length > 0 )
                receivedMsg(from, nick, text[0].textContent); // Handle in UI
        }
        return true;
    },

    // TODO : REMOVE Just for Debug
    append_on_top: function (text) {
        $("#debug").append(text);
    },

    // Send raw XMPP messages
    send: function (data) {
        Chat.bosh.send(data);
    },

    // Ask for rosters
    get_roster: function(){
        var id = Chat.bosh.getUniqueId('roster');
        var rosteriq = $iq({
            'id':id,
            'type':'get'
        }
        ).c('query', {
            'xmlns':Strophe.NS.ROSTER
        });
        Chat.bosh.addHandler(Chat.recv_roster, null, 'iq', 'result', id);
        Chat.bosh.send(rosteriq.tree());
    },

    // Handler for rosters
    recv_roster: function(e){
        var query = e.getElementsByTagName('query')[0];
        var entries = query.getElementsByTagName('item');
        //Chat.rosters = new Array();
        for (var item=0; item<entries.length; item++) {
            var nick = entries[item].getAttribute('name');
            var jid =  Strophe.getBareJidFromJid(entries[item].getAttribute('jid'));
            if (!nick) { // If the roster has no nickname
                nick = jid.split('@')[0];
            }
            // If is a new Roster
            if (searchJid(jid) == -1){
                Chat.rosters.push(new rosterState(jid, nick, ""));
            }
        }
        //Chat.send($pres().tree()); // Send our presence
        hideDiv("chatloader");
        showDiv("chatrosters");
        return false;
    },

    // Handler for Presence
    handlerPresence: function(presence){
        var from = Strophe.getBareJidFromJid(presence.getAttribute('from'));
        var to = Strophe.getBareJidFromJid(presence.getAttribute('to'));
        if (from != to){ // If is not sent by me
            var i = searchJid(from);
            if (i > -1){    // If is a presence from a roster
                var nick = Chat.rosters[i].nick;
                var id = Jid2Id(from);
                var resource = Strophe.getResourceFromJid(presence.getAttribute('from'));

                var type = presence.getAttribute('type') ? presence.getAttribute('type') : 'available';
                var show = presence.getElementsByTagName('show').length ? Strophe.getText(presence.getElementsByTagName('show')[0]) : type;
                var status = presence.getElementsByTagName('status').length ? Strophe.getText(presence.getElementsByTagName('status')[0]) : '';

                //alert(from + " / " + show);
                if (show == 'unavailable'){
                    Chat.rosters[i].resource = "";
                    manageUI("removeroster", id, null, nick);
                } else {
                    Chat.rosters[i].resource = resource;
                    manageUI("addroster",id, from, nick, show, status);
                }
            //                if (type == 'unavailable' || status == 'unavailable') { // If is disconnected
            //                    Chat.rosters[i].resource = "";
            //                    manageUI("removeroster", id, null, nick);
            //                } else {
            //                    Chat.rosters[i].resource = resource;
            //                    manageUI("addroster",id, jid, nick);
            //                }

            }
        }
        return true;
    },

    connect_callback: function (status) {
        switch (status) {
            case Strophe.Status.ERROR :
                Chat.append_on_top("Error...<br />");
                break;
            case Strophe.Status.CONNFAIL :
                Chat.append_on_top("Connection error...<br />");
                break;
            case Strophe.Status.AUTHFAIL :
                Chat.append_on_top("Check jid/password<br />");
                break;
            case Strophe.Status.CONNECTING :
                manageUI("connecting");
                break;
            case Strophe.Status.CONNECTED :
                //                Chat.pause();
                //                localStorage.setItem("sid", Chat.bosh.sid);
                //                localStorage.setItem("rid", Chat.bosh.rid);
                //                localStorage.setItem("jid", Chat.bosh.jid);
                //alert(Chat.bosh.sid);
                //showAV();
                Chat.get_roster();
                (Chat.presence == 1) ? Chat.offline() : Chat.online();
                //(Chat.presence == 1) ? Chat.offline() : Chat.online();
                // Subscribe handlers for Messages, Presences and Calls
                Chat.bosh.addHandler(Chat.recv_message, null, 'message');
                Chat.bosh.addHandler(Chat.handlerPresence, null, 'presence');
                Chat.bosh.addHandler(Jingle.recv_call, null, 'iq', 'set');
                (Chat.presence == 1) ? manageUI("offline") : manageUI("connected");
                break;
            case Strophe.Status.ATTACHED :
                //showAV();
                Chat.get_roster();
                (Chat.presence == 1) ? Chat.offline() : Chat.online();
                // Subscribe handlers for Messages, Presences and Calls
                Chat.bosh.addHandler(Chat.recv_message, null, 'message');
                Chat.bosh.addHandler(Chat.handlerPresence, null, 'presence');
                Chat.bosh.addHandler(Jingle.recv_call, null, 'iq', 'set');
                (Chat.presence == 1) ? manageUI("offline") : manageUI("connected");
                break;
            case Strophe.Status.DISCONNECTED :
                manageUI("disconnected");
                break;
            case Strophe.Status.DISCONNECTING :
                manageUI("disconnecting");
                break;
        }
    }
}