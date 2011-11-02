/*

Jappix - An open social platform
These are the common JS script for Jappix

-------------------------------------------------

License: AGPL
Authors: Valérian Saliou, Olivier Migeot
Last revision: 24/06/11

*/

// Checks if an element exists in the DOM
function exists(selector) {
	if(jQuery(selector).size() > 0)
		return true;
	else
		return false;
}

// Checks if Jappix is connected
function isConnected() {
	if((typeof con != 'undefined') && con && con.connected())
		return true;
	
	return false;
}

// Checks if Jappix has focus
function isFocused() {
	try {
		if(document.hasFocus())
			return true;
		
		return false;
	}
	
	catch(e) {
		return true;
	}
}

// Generates the good XID
function generateXID(xid, type) {
	// XID needs to be transformed
	if(xid && (xid.indexOf('@') == -1)) {
		// Groupchat
		if(type == 'groupchat')
			return xid + '@' + HOST_MUC;
		
		// One-to-one chat
		if(xid.indexOf('.') == -1)
			return xid + '@' + HOST_MAIN;
		
		// It might be a gateway?
		return xid;
	}
	
	// Nothing special (yet bare XID)
	return xid;
}

// Gets the asked translated string
function _e(string) {
	return string;
}

// Replaces '%s' to a given value for a translated string
function printf(string, value) {
	return string.replace('%s', value);
}

// Properly explodes a string with a given character
function explodeThis(toEx, toStr, i) {
	// Get the index of our char to explode
	var index = toStr.indexOf(toEx);
	
	// We split if necessary the string
	if(index != -1) {
		if(i == 0)
			toStr = toStr.substr(0, index);
		else
			toStr = toStr.substr(index + 1);
	}
	
	// We return the value
	return toStr;
}

// Cuts the resource of a XID
function cutResource(aXID) {
	return explodeThis('/', aXID, 0);
}

// Gets the resource of a XID
function thisResource(aXID) {
	// Any resource?
	if(aXID.indexOf('/') != -1)
		return explodeThis('/', aXID, 1);
	
	// No resource
	return '';
}

// Does stringprep on a string
function stringPrep(string) {
	// Replacement arrays
	var invalid = new Array('Š', 'š', 'Đ', 'đ', 'Ž', 'ž', 'Č', 'č', 'Ć', 'ć', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ù', 'ú', 'û', 'ý', 'þ', 'ÿ', 'Ŕ', 'ŕ');
	
	var valid   = new Array('S', 's', 'Dj', 'dj', 'Z', 'z', 'C', 'c', 'C', 'c', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'U', 'U', 'U', 'U', 'Y', 'B', 'Ss', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'o', 'n', 'o', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'y', 'b', 'y', 'R', 'r');
	
	// Compute a new string
	for(i in invalid)
		string = string.replace(invalid[i], valid[i]);
	
	return string;
}

// Encodes quotes in a string
function encodeQuotes(str) {
	return (str + '').replace(/"/g, '&quot;');
}

// Gets the bare XID from a XID
function bareXID(xid) {
	// Cut the resource
	xid = cutResource(xid);
	
	// Launch the stringprep
	xid = stringPrep(xid);
	
	// Set the XID to lower case
	xid = xid.toLowerCase();
	
	return xid;
}

// Gets the full XID from a XID
function fullXID(xid) {
	// Normalizes the XID
	var full = bareXID(xid);
	var resource = thisResource(xid);
	
	// Any resource?
	if(resource)
		full += '/' + resource;
	
	return full;
}

// Gets the nick from a XID
function getXIDNick(aXID) {
	return explodeThis('@', aXID, 0);
}

// Gets the host from a XID
function getXIDHost(aXID) {
	return explodeThis('@', aXID, 1);
}

// Checks if we are in developer mode
function isDeveloper() {
	if(DEVELOPER == 'on')
		return true;
	
	return false;
}

// Checks if anonymous mode is allowed
function allowedAnonymous() {
	if(ANONYMOUS == 'on')
		return true;
	
	return false;
}

// Checks if host is locked
function lockHost() {
	if(LOCK_HOST == 'on')
		return true;
	
	return false;
}

// Gets the full XID of the user
function getXID() {
	// Return the XID of the user
	if(con.username && con.domain)
		return con.username + '@' + con.domain;
	
	return '';
}

// Generates the colors for a given user XID
function generateColor(xid) {
	var colors = new Array(
			'ac0000',
			'a66200',
			'007703',
			'00705f',
			'00236b',
			'4e005c'
		     );
	
	var number = 0;
	
	for(var i = 0; i < xid.length; i++)
		number += xid.charCodeAt(i);
	
	var color = '#' + colors[number % (colors.length)];
	
	return color;
}

// Checks if the XID is a gateway
function isGateway(xid) {
	if(xid.indexOf('@') != -1)
		return false;
	
	return true;
}

// Gets the from attribute of a stanza (overrides some servers like Prosody missing from attributes)
function getStanzaFrom(stanza) {
	var from = stanza.getFrom();
	
	// No from, we assume this is our XID
	if(!from)
		from = getXID();
	
	return from;
}

// Logs a given data in the console
function logThis(data, level) {
	// Console not available
	if(!isDeveloper() || (typeof(console) == 'undefined'))
		return false;
	
	// Switch the log level
	switch(level) {
		// Debug
		case 0:
			console.debug(data);
			
			break;
		
		// Error
		case 1:
			console.error(data);
			
			break;
		
		// Warning
		case 2:
			console.warn(data);
			
			break;
		
		// Information
		case 3:
			console.info(data);
			
			break;
		
		// Default log level
		default:
			console.log(data);
			
			break;
	}
	
	return true;
}

// Gets the current Jappix app. location
function getJappixLocation() {
	var url = window.location.href;
	
	// If the URL has variables, remove them
	if(url.indexOf('?') != -1)
		url = url.split('?')[0];
	if(url.indexOf('#') != -1)
		url = url.split('#')[0];
	
	// No "/" at the end
	if(!url.match(/(.+)\/$/))
		url += '/';
	
	return url;
}

// Removes spaces at the beginning & the end of a string
function trim(str) {
	return str.replace(/^\s+/g,'').replace(/\s+$/g,'');
}

// Adds a zero to a date when needed
function padZero(i) {
	// Negative number (without first 0)
	if(i > -10 && i < 0)
		return '-0' + (i * -1);
	
	// Positive number (without first 0)
	if(i < 10 && i >= 0)
		return '0' + i;
	
	// All is okay
	return i;
}
