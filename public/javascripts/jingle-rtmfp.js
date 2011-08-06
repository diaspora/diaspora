
var CUMULUS_URL = 'rtmfp://80.181.193.130:1935/c74f9b068350210a650e08de4c46bfe5eb709dff435059e89a2592ac89b853ce'; // TO CHANGE

Strophe.addNamespace('JINGLE', 'urn:xmpp:jingle:1');
Strophe.addNamespace('JINGLE_RTMFP', 'urn:xmpp:jingle:apps:rtmp');

var Jingle = {

    callstatus: 0, // 0 - no_call | 1 - makeCall | 2 - receive_call
    myId: null, // My_Id with VoIP Server
    myStream: null,
    farId: null,
    farStream: null,
    other: null,
    sid: null,


    
    // After connecting to VoIP server
    connectCall: function(myId){
        var calliq;
        var id = Chat.bosh.getUniqueId('jingle');
        Jingle.myId = myId;
        Jingle.myStream = MD5.hexdigest(Chat.bosh.jid);

        if (Jingle.callstatus == 1){
            var sid = Base64.encode(myId.substring(0,11));
            
            calliq = $iq({
                'to': Jingle.other,
                'from':Chat.bosh.jid,
                'id': id,
                'type':'set'
            }).c('jingle', {
                'action': 'session-initiate',
                'initiator': Chat.bosh.jid,
                'responder': Jingle.other,
                'sid': sid,
                'xmlns':Strophe.NS.JINGLE
            }).c('content', {
                'creator': 'initiator',
                'name': 'av',
                'senders': 'both'
            }).c('transport', {
                'xmlns':Strophe.NS.JINGLE_RTMFP
            }).c('candidate', {
                'id': Jingle.myId,
                'url': CUMULUS_URL,
                'pubid': Jingle.myStream
            });

        } else if (Jingle.callstatus == 2){

            // start webcam & audio
            startAV(Jingle.farId, Jingle.farStream, Jingle.myStream);

            calliq = $iq({
                'from':Chat.bosh.jid,
                'id': id,
                'to': Jingle.other,
                'type':'set'
            }
            ).c('jingle', {
                'xmlns':Strophe.NS.JINGLE,
                'action': 'session-accept',
                'initiator': Jingle.other,
                'responder': Chat.bosh.jid,
                'sid': Jingle.sid
            }).c('content', {
                'creator': 'initiator',
                'name': 'av'
            }).c('candidate', {
                'id': Jingle.myId,
                'pubid': Jingle.myStream
            });
        }
        Chat.send(calliq.tree());
    },

    // Make a call
    makeCall: function (to){
        showAV(to, CUMULUS_URL);
        Jingle.other = fullJid(Id2Jid(to));
        Jingle.callstatus = 1;
    //document.getElementById( "chatFlash" ).getID(CUMULUS_URL);
    },

    // Send call termination
    terminateCall: function (){
        var id =  Chat.bosh.getUniqueId('jingle');
        Chat.bosh.addHandler(Jingle.endCall, null, 'iq', 'result', id);
        Jingle.sendTermination(id, 'success');
        hideAV();
    },

    sendTermination: function(id, reason) {
        var calliq = $iq({
            'from':Chat.bosh.jid,
            'id': id,
            'to': Jingle.other,
            'type':'set'
        }
        ).c('jingle', {
            'xmlns':Strophe.NS.JINGLE,
            'action': 'session-terminate',
            'initiator': (Jingle.callstatus == 1) ? Chat.bosh.jid : Jingle.other ,
            'sid': Jingle.sid
        }).c(reason)
        Chat.send(calliq.tree());
    },

    // Terminate call
    endCall: function (){
        Jingle.callstatus = 0;
        return true;
    },

    // Handler to receive a call
    recvCall: function (iq){
        var from = iq.getAttribute('from');
        var jid = from.split('/')[0];
        var id = iq.getAttribute('id');
        var sid = iq.getElementsByTagName("jingle")[0].getAttribute('sid');

        // Send JingleACK
        var callack = $iq({
            'from': Chat.bosh.jid,
            'id': id,
            'type':'result',
            'to': from
        });
        Chat.send(callack.tree());

        // Received a positive call reply
        if (iq.getElementsByTagName("jingle")[0].getAttribute('action') == 'session-accept'){
            //alert("you got a response from "+ from);
            Jingle.callResponse (iq);
            // start webcam & audio
            startAV(Jingle.farId, Jingle.farStream, Jingle.myStream);
            return true;
        }
        // Received a negative call reply
        else if (iq.getElementsByTagName("jingle")[0].getAttribute('action') == 'session-terminate'){
            Jingle.callstatus = 0;
            if (iq.getElementsByTagName("busy").length > 0 )
                alert("Busy with another call");
            else if (iq.getElementsByTagName("decline").length > 0 )
                alert("Call rejected");
            else if (iq.getElementsByTagName("success").length > 0 )
                alert("Call terminated");
            hideAV();
            return true;
        }

        if ( Jingle.callstatus == 0 )  { // Free for call
            Jingle.sid = sid;
            Jingle.other = from;
            //var newid = Chat.bosh..getUniqueId('jingle');
            if (confirm(jidToNick(jid) + " is calling you, wanna reply?")){ // Accept call
                var nick = jidToNick(jid);
                var url = iq.getElementsByTagName("candidate")[0].getAttribute('url');
                chatWith(jid, nick);
                showAV(Jid2Id(jid), url);
                Jingle.callstatus = 2;
                Jingle.callResponse(iq);
            }
            else{ // Reject call
                Jingle.sendTermination(id, 'decline');
            }
        } else {
            // Can't accept call (busy with another call)
            Jingle.sendTermination(id, 'busy');
        }
        return true;
    },

    // Initiate call
    callResponse: function (iq) {
        var candidate = iq.getElementsByTagName("candidate")[0];
        Jingle.farId = candidate.getAttribute('id');
        Jingle.farStream = candidate.getAttribute('pubid');
    }

}