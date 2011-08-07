var windowFocus = true;
var username = 'Me'; // TO CHANGE: User.name
var originalTitle;
var blinkOrder = 0;

var chatboxFocus = new Array();
var newMessages = new Array();
var newMessagesWin = new Array();
var chatBoxes = new Array();
var logout = 0;

// Object to manage Chatboxes
function chatBox(name, minimized, text) {
    this.name = name;
    this.minimized = minimized;
    this.text = text;
}

// Unloading the page
$(window).unload(function() {
    if(logout){
        Chat.disconnect();
    }else{
        Chat.pause();
        storeConnectionInfo();
    }
});

$(window).bind('beforeunload', function(){
    checkCall();
    Chat.send($pres({
        'type':'unavailable'
    }));
    Chat.bosh.flush();
})


function checkCall(){
    if(Jingle.callstatus != 0)
        Jingle.terminateCall();
}

// Page loaded
$(document).ready(function(){

    $('a').click(function() {
        window.onbeforeunload = checkCall();
    });

    $("#logout").click(function(){
        logout = 1;
    });

    originalTitle = document.title;

    // Handle window blur and focus
    $([window, document]).blur(function(){
        windowFocus = false;
    }).focus(function(){
        windowFocus = true;
        document.title = originalTitle;
    });

    // Get connection state
    var sid = localStorage.getItem("sid");
    var rid = localStorage.getItem("rid");
    var jid = localStorage.getItem("jid");

    // Create HTML chat menu
    $("<div id=\"chatmain\"/>" )
    .html('<div id="chatrosters" class="chatfriends"></div></div><div class="chat"><a href="javascript:void(0)" onclick="javascript:loginButton()"><div id="chatlogin" class="chatloginbutton">Chat</div></a><div id="chatloader" class="chatloadericon"><img src="/images/chatloader.gif"></div><a href="javascript:void(0)" onclick="javascript:Chat.offline()"><div id="chatlogout" class="chatlogoutbutton">X<br></div></a></div>')
    .appendTo($( "body" ));

    // Append to footer
    $("#chatlogin").css('bottom', '0px');
    $("#chatloader").css('bottom', '0px');
    $("#chatlogout").css('bottom', '0px');

    // Check if connection state is valid
    if (sid != null && rid != null && jid != null)
    {   
        Chat.attach(jid, sid, rid);
        // get last opened chatboxes
        chatBoxes = $.makeArray(JSON.parse(localStorage.getItem("chatboxes")));
        
        // get last rosters
        Chat.rosters = $.makeArray(JSON.parse(localStorage.getItem("roster")));
        if (Chat.rosters.length > 0)
            restoreRosters();
        
        if (chatBoxes.length > 0)
            restoreChatBoxes();
        $("#chatrosters").hide();
    } else {
        var user = localStorage.getItem("user");
        var pass = localStorage.getItem("pass");
        localStorage.removeItem("user");
        localStorage.removeItem("pass");
        Chat.start(user, pass);
    }
});

// Re-organize Chatboxes
function restructureChatBoxes() {
    var align = 0;
    for (i = 0; i < chatBoxes.length; i++) {

        var chatboxtitle = chatBoxes[i].name;

        if ($("#chatbox_"+chatboxtitle).css('display') != 'none') {
            var width = (align)*(225+7)+190;
            $("#chatbox_"+chatboxtitle).css('right', width+'px');
            align++;
        }

    }
    return;
}

// Restore opened Chatboxes
function restoreChatBoxes() {
    var align = 0;

    for (i = 0; i < chatBoxes.length; i++, align++) {
        var chatboxtitle = chatBoxes[i].name;

        // create chatbox with chat history
        $(" <div />" ).attr("id","chatbox_"+chatboxtitle)
        .addClass("chatbox").html(chatBoxes[i].text)
        .appendTo($( "body" ));

        // check if was minimized
        if (chatBoxes[i].minimized == false){
            $('#chatbox_'+chatboxtitle+' .chatboxcontent').css('display','block');
            $('#chatbox_'+chatboxtitle+' .chatboxinput').css('display','block');
            $("#chatbox_"+chatboxtitle+" .chatboxcontent").scrollTop($("#chatbox_"+chatboxtitle+" .chatboxcontent")[0].scrollHeight);
        } else {
            $('#chatbox_'+chatboxtitle+' .chatboxcontent').css('display','none');
            $('#chatbox_'+chatboxtitle+' .chatboxinput').css('display','none');
        }

        var width = (align)*(225+7)+190;
        $("#chatbox_"+chatboxtitle).css('right', width+'px');
        $("#chatbox_"+chatboxtitle).css('bottom', '0px');
        $("#chatbox_"+chatboxtitle).show();
        
    }
}

// Restore Rosters list with Presences (after attach not able to retrieve presences)
function restoreRosters(){

    for (i = 0; i < Chat.rosters.length; i++){
        if (Chat.rosters[i].resource != ""){
            var jid = Chat.rosters[i].jid;
            var id = Jid2Id(jid);
            var nick = Chat.rosters[i].nick;
            $('#chatrosters').append('<div class="friend" id="status_'+id+'"><a class="nick" href="javascript:void(0)" onclick="javascript:chatWith(\''+jid+'\')">'+nick+'</a></div>');
        }
    }
}

// Create a Chatbox with a Roster
function chatWith(chatuser) {
    var nick = jidToNick(chatuser);
    var id = Jid2Id(chatuser);
    createChatBox(id, nick);
    $("#chatbox_"+id+" .chatboxtextarea").focus();
}

function createChatBox(id, nick) {
    if ($("#chatbox_"+id).length > 0) { // If already present..
        if ($("#chatbox_"+id).css('display') == 'none') { // .. but previously closed (hidden)
            $("#chatbox_"+id).show();
            // Check if was minimized before hide
            if ( $('#chatbox_'+id+' .chatboxcontent').css('display') == 'none')
                chatBoxes.push(new chatBox(id, true)); // Insert it back to the active chatboxes
            else
                chatBoxes.push(new chatBox(id, false));
            restructureChatBoxes();
        } // .. and not closed (showed)
        $("#chatbox_"+id+" .chatboxtextarea").focus(); // Focus on it for "blind" people
        return;
    }
    // Create HTML for the Chatbox
    $(" <div />" ).attr("id","chatbox_"+id)
    .addClass("chatbox")
    .html('<div class="chatboxhead"><div class="chatboxtitle"><a href="javascript:void(0)" onclick="javascript:toggleChatBoxGrowth(\''+id+'\')">'+nick+'</a></div><div class="chatboxoptions"><a href="javascript:void(0)" onclick="javascript:videoButton(\''+id+'\')">O</a><a href="javascript:void(0)" onclick="javascript:closeChatBox(\''+id+'\')">X</a></div><br clear="all"/></div><div class="chatboxcontent"></div><div class="chatboxinput"><textarea class="chatboxtextarea" onkeydown="javascript:return checkChatBoxInputKey(event,this,\''+id+'\');"></textarea></div>')
    .appendTo($( "body" ));

    $("#chatbox_"+id).css('bottom', '0px');
    // Placing the Chatbox
    var width = (chatBoxes.length)*(225+7)+190;
    $("#chatbox_"+id).css('right', width+'px');
    // Add to the activate chatboxes
    chatBoxes.push(new chatBox(id, false));

    chatboxFocus[id] = false;
    // Add handlers for blur and focus
    $("#chatbox_"+id+" .chatboxtextarea").blur(function(){
        chatboxFocus[id] = false;
        $("#chatbox_"+id+" .chatboxtextarea").removeClass('chatboxtextareaselected');
    }).focus(function(){
        chatboxFocus[id] = true;
        newMessages[id] = false;
        $('#chatbox_'+id+' .chatboxhead').removeClass('chatboxblink');
        $("#chatbox_"+id+" .chatboxtextarea").addClass('chatboxtextareaselected');
    });
    // Clicking on any point of the chatbox
    $("#chatbox_"+id).click(function() {
        if ($('#chatbox_'+id+' .chatboxcontent').css('display') != 'none') {
            $("#chatbox_"+id+" .chatboxtextarea").focus();
        }
    });
    // Show created chatbox
    $("#chatbox_"+id).show();
}

function showAV(id, url){
    $('<div id = "chatFlashcontainer" style="width:1px; height:1px">')
    .html('<object type="application/x-shockwave-flash" data="../videochat.swf" id="chatFlash" width="100%" height="100%">\n\
<param name=FlashVars value="url='+ url +'" >\n\
<param name="allowScriptAccess" value="always">\n\
<param name="allowFullScreen" value="true" />\n\
<embed src="../videochat.swf?url=\'+ url +\'" type="application/x-shockwave-flash" allowScriptAccess="always" allowFullScreen="true" width="100%" height="100%" FlashVars="url='+ url +'"></embed></object>')
    .appendTo($('#chatbox_' + id +' .chatboxhead'));
    document.getElementById("chatFlashcontainer").style.height = "150px";
    document.getElementById("chatFlashcontainer").style.width = "215px";
}

function hideAV(){
    $("#chatFlashcontainer").remove();
}

function startAV(farId, farStream, nearStream){
    document.getElementById( "chatFlash" ).callMe(farId, farStream, nearStream);
}

// When message is received
function receivedMsg(from, nick, text){
    var id = Jid2Id(from.split('/')[0]);

    if (windowFocus == false) {
        newMessagesWin[id] = true;
        newMessages[id] = true;
        // TODO : Check blinking
        var blinkNumber = 0;
        var titleChanged = 0;
        for (x in newMessagesWin) {
            if (newMessagesWin[x] == true) {
                ++blinkNumber;
                if (blinkNumber >= blinkOrder) {
                    document.title = nick +' says...';
                    titleChanged = 1;
                    break;
                }
            }
        }

        if (titleChanged == 0) {
            document.title = originalTitle;
            blinkOrder = 0;
        } else {
            ++blinkOrder;
        }

    } else {
        for (x in newMessagesWin) {
            newMessagesWin[x] = false;
        }
    }

    for (x in newMessages) {
        if (newMessages[x] == true) {
            if (chatboxFocus[x] == false) {
                $('#chatbox_'+x+' .chatboxhead').toggleClass('chatboxblink');
            }
        }
    }
    // If message from non active chatbox, create it
    if (searchCB(id) == -1){
        createChatBox(id, nick);
        restructureChatBoxes();
    }

    // If message from hidden chatbox, show it
    if ($("#chatbox_"+id).css('display') == 'none') {
        $("#chatbox_"+id).css('display','block');
        restructureChatBoxes();
    }
    // Show message content
    $("#chatbox_"+id+" .chatboxcontent").append('<div class="chatboxmessage"><span class="chatboxmessagefrom">'+nick+':&nbsp;&nbsp;</span><span class="chatboxmessagecontent">'+text+'</span></div>');
    $("#chatbox_"+id+" .chatboxcontent").scrollTop($("#chatbox_"+id+" .chatboxcontent")[0].scrollHeight);
}

function closeAllChat(){
    for (var i = 0; i < chatBoxes.length; i++)
        $("#chatbox_"+chatBoxes[i].name).hide();

    chatBoxes.splice(0, chatBoxes.length);
}

function closeChatBox(id) {
    $("#chatbox_"+id).hide();
    var i = searchCB(id);
    chatBoxes.splice(i, 1);
    restructureChatBoxes();
}

// Minimize Chatbox
function toggleChatBoxGrowth(chatboxtitle) {
  
    var i  = searchCB (chatboxtitle);

    // If chatbox is already minimized, show it

    if ($('#chatbox_'+chatboxtitle+' .chatboxcontent').css('display') == 'none') {

        chatBoxes[i].minimized = false;
        $('#chatbox_'+chatboxtitle+' .chatboxcontent').css('display','block');
        $('#chatbox_'+chatboxtitle+' .chatboxinput').css('display','block');
        $("#chatbox_"+chatboxtitle+" .chatboxcontent").scrollTop($("#chatbox_"+chatboxtitle+" .chatboxcontent")[0].scrollHeight);

    } else { // If is not minimized, minimize it
        chatBoxes[i].minimized = true;
        $('#chatbox_'+chatboxtitle+' .chatboxcontent').css('display','none');
        $('#chatbox_'+chatboxtitle+' .chatboxinput').css('display','none');
    }

}

function checkChatBoxInputKey(event,chatboxtextarea,chatboxtitle) {
    // If we press Enter
    if(event.keyCode == 13 && event.shiftKey == 0)  {
        var message = $(chatboxtextarea).val();
        // Removes initial spaces or final spaces
        message = message.replace(/^\s+|\s+$/g,"");

        $(chatboxtextarea).val('');
        $(chatboxtextarea).focus();
        $(chatboxtextarea).css('height','44px');
        
        if (message != '') { // If is not an empty message
            // Recipient Jid
            var friendjid = Id2Jid(chatboxtitle);
            Chat.sendMessage(friendjid, message); // Send message
            // Replaces < > " with html codes
            message = message.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\"/g,"&quot;");
            $("#chatbox_"+chatboxtitle+" .chatboxcontent").append('<div class="chatboxmessage"><span class="chatboxmessagefrom">'+username+':&nbsp;&nbsp;</span><span class="chatboxmessagecontent">'+message+'</span></div>');
            $("#chatbox_"+chatboxtitle+" .chatboxcontent").scrollTop($("#chatbox_"+chatboxtitle+" .chatboxcontent")[0].scrollHeight);
        }

        return false;
    }

    var adjustedHeight = chatboxtextarea.clientHeight;
    var maxHeight = 94;

    if (maxHeight > adjustedHeight) {
        adjustedHeight = Math.max(chatboxtextarea.scrollHeight, adjustedHeight);
        if (maxHeight)
            adjustedHeight = Math.min(maxHeight, adjustedHeight);
        if (adjustedHeight > chatboxtextarea.clientHeight)
            $(chatboxtextarea).css('height',adjustedHeight+8 +'px');
    } else {
        $(chatboxtextarea).css('overflow','auto');
    }
}

// convert roster Jid to and ID used to create chaboxes
function Jid2Id (jid){
    return jid.split('@').join('_').split('.').join('-');
}
// convert roster ID to his own Jid
function Id2Jid (id){
    return id.replace('_','@').replace(/-/g,'.');
}

// return index of a chatbox
function searchCB (id){
    for (i = 0; i < chatBoxes.length; i++){
        if (id == chatBoxes[i].name)
            return i;
    }
    return -1;
}

function loginButton (){
    if ( Chat.presence == 1 ){
        Chat.online()
    }else{
        if ($("#chatrosters").is(":visible"))
            $("#chatrosters").hide();
        else
            $("#chatrosters").show();
    }
}

function videoButton (id){
    if ( Jingle.callstatus == 0 ){
        Jingle.makeCall(id)
    }else{
        if ($("#chatFlashcontainer").is(":visible")){
            Jingle.terminateCall();
        }
    }
}

function manageUI(event, id, jid, nick, state, status){
    var nameinthelist;
    switch(event){
        case "connecting":
            $("#chatloader").show();
            break;
        case "connected":
            $("#chatlogin").css('color', '#33CC00');
            $("#chatrosters").css('bottom', '32px');
            break;
        case "disconnecting":
            $("#chatloader").show();
            break;
        case "disconnected":
            $("#chatlogin").css('color', '#FFFFFF');
            closeAllChat();
            $("#chatrosters").hide();
            $("#chatloader").hide();
            break;
        case "offline":
            $("#chatlogin").css('color', '#FFFFFF');
            $("#chatrosters").hide();
            break;
        case "addroster":
            nameinthelist = document.getElementById('status_'+id);
            if (nameinthelist == null)
                $('#chatrosters').append('<div class="friend" id="status_'+id+'"><a class="nick" href="javascript:void(0)" onclick="javascript:chatWith(\''+jid+'\')">'+nick+'</a></div>');
            if (searchCB(id) != -1){
                if (state != "chat" && state != "available"){
                    $("#chatbox_"+id+" .chatboxcontent").append('<div class="chatboxmessage"><span class="chatboxmessagefrom">'+nick+' is '+state+'</span></div>');
                    $("#chatbox_"+id+" .chatboxtitle a").html(nick + ' - ' + state);
                }else{
                    $("#chatbox_"+id+" .chatboxtitle a").html(nick);
                }
                if (status != "undefined" && status != "")
                    $("#chatbox_"+id+" .chatboxcontent").append('<div class="chatboxmessage"><span class="chatboxmessagefrom">'+nick+': '+status+'</span></div>');
            }
            break;
        case "removeroster":
            // Get roster list element
            var roster_list = document.getElementById('chatrosters');
            nameinthelist = document.getElementById('status_'+id);
            if (nameinthelist != null)
                roster_list.removeChild(nameinthelist);
            if (searchCB(id) != -1){
                $("#chatbox_"+id+" .chatboxcontent").append('<div class="chatboxmessage"><span class="chatboxmessagefrom">'+nick+' is offline.</span></div>');
                $("#chatbox_"+id+" .chatboxcontent").scrollTop($("#chatbox_"+id+" .chatboxcontent")[0].scrollHeight);
                $("#chatbox_"+id+" .chatboxtitle a").html(nick+' - offline');
            }
            break;
    }
}

function hideDiv(id){
    $("#"+id).hide();
}

function showDiv(id){
    $("#"+id).show();
}