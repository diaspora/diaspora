/*

Jappix - An open social platform
These are the date related JS scripts for Jappix

-------------------------------------------------

License: AGPL
Author: Valérian Saliou
Last revision: 17/08/11

*/

// Gets a stamp from a date
function extractStamp(date) {
	return Math.round(date.getTime() / 1000);
}

// Gets the time from a date
function extractTime(date) {
	return date.toLocaleTimeString();
}

// Gets the actual date stamp
function getTimeStamp() {
	return extractStamp(new Date());
}

// Gets the last user activity in seconds
var LAST_ACTIVITY = 0;

function getLastActivity() {
	// Last activity not yet initialized?
	if(LAST_ACTIVITY == 0)
		return 0;
	
	return getTimeStamp() - LAST_ACTIVITY;
}

// Gets the last user available presence in seconds
var PRESENCE_LAST_ACTIVITY = 0;

function getPresenceLast() {
	// Last presence stamp not yet initialized?
	if(PRESENCE_LAST_ACTIVITY == 0)
		return 0;
	
	return getTimeStamp() - PRESENCE_LAST_ACTIVITY;
}

// Generates the time for XMPP
function getXMPPTime(location) {
	/* FROM : http://trac.jwchat.org/jsjac/browser/branches/jsjac_1.0/jsextras.js?rev=221 */
	
	// Initialize
	var jInit = new Date();
	var year, month, day, hours, minutes, seconds;
	
	// Gets the UTC date
	if(location == 'utc') {
		year = jInit.getUTCFullYear();
		month = jInit.getUTCMonth();
		day = jInit.getUTCDate();
		hours = jInit.getUTCHours();
		minutes = jInit.getUTCMinutes();
		seconds = jInit.getUTCSeconds();
	}
	
	// Gets the local date
	else {
		year = jInit.getFullYear();
		month = jInit.getMonth();
		day = jInit.getDate();
		hours = jInit.getHours();
		minutes = jInit.getMinutes();
		seconds = jInit.getSeconds();
	}
	
	// Generates the date string
	var jDate = year + '-';
	jDate += padZero(month + 1) + '-';
	jDate += padZero(day) + 'T';
	jDate += padZero(hours) + ':';
	jDate += padZero(minutes) + ':';
	jDate += padZero(seconds) + 'Z';
	
	// Returns the date string
	return jDate;
}

// Generates then human time
function getCompleteTime() {
	var init = new Date();
	var time = padZero(init.getHours()) + ':';
	time += padZero(init.getMinutes()) + ':';
	time += padZero(init.getSeconds());
	
	return time;
}

// Gets the TZO of a date
function getDateTZO() {
	// Get the date
	var date = new Date();
	var offset = date.getTimezoneOffset();
	
	// Default vars
	var sign = '';
	var hours = 0;
	var minutes = 0;
	
	// Process a neutral offset
	if(offset < 0) {
		offset = offset * -1;
		sign = '+';
	}
	
	// Get the values
	var n_date = new Date(offset * 60 * 1000);
	hours = n_date.getHours() - 1;
	minutes = n_date.getMinutes();
	
	// Process the TZO
	tzo = sign + padZero(hours) + ':' + padZero(minutes);
	
	// Return the processed value
	return tzo;
}

// Parses a XMPP date (yyyy-mm-dd, hh-mm-ss) into an human-readable one
function parseDate(to_parse) {
	var date = Date.jab2date(to_parse);
	var parsed = date.toLocaleDateString() + ' (' + date.toLocaleTimeString() + ')';
	
	return parsed; 
}

// Parses a XMPP date (yyyy-mm-dd) into an human-readable one
function parseDay(to_parse) {
	var date = Date.jab2date(to_parse);
	var parsed = date.toLocaleDateString();
	
	return parsed; 
}

// Parses a XMPP date (hh-mm-ss) into an human-readable one
function parseTime(to_parse) {
	var date = Date.jab2date(to_parse);
	var parsed = date.toLocaleTimeString();
	
	return parsed; 
}

// Parses a XMPP date stamp into a relative one
function relativeDate(to_parse) {
	// Get the current date
	var current_date = Date.jab2date(getXMPPTime('utc'));
	var current_day = current_date.getDate();
	var current_stamp = current_date.getTime();
	
	// Parse the given date
	var old_date = Date.jab2date(to_parse);
	var old_day = old_date.getDate();
	var old_stamp = old_date.getTime();
	var old_time = old_date.toLocaleTimeString();
	
	// Get the day number between the two dates
	var days = Math.round((current_stamp - old_stamp) / 86400000);
	
	// Invalid date?
	if(isNaN(old_stamp) || isNaN(days))
		return getCompleteTime();
	
	// Is it today?
	if(current_day == old_day)
		return old_time;
	
	// It is yesterday?
	if(days <= 1)
		return _e("Yesterday") + ' - ' + old_time;
	
	// Is it less than a week ago?
	if(days <= 7)
		return printf(_e("%s days ago"), days) + ' - ' + old_time;
	
	// Another longer period
	return old_date.toLocaleDateString() + ' - ' + old_time;
}

// Reads a message delay
function readMessageDelay(node) {
	// Initialize
	var delay, d_delay;
	
	// Read the delay
	d_delay = jQuery(node).find('delay[xmlns=' + NS_URN_DELAY + ']:first').attr('stamp');
	
	// New delay (valid XEP)
	if(d_delay)
		delay = d_delay;
	
	// Old delay (obsolete XEP!)
	else {
		// Try to read the old-school delay
		var x_delay = jQuery(node).find('x[xmlns=' + NS_DELAY + ']:first').attr('stamp');
		
		if(x_delay)
			delay = x_delay.replace(/^(\w{4})(\w{2})(\w{2})T(\w{2}):(\w{2}):(\w{2})Z?(\S+)?/, '$1-$2-$3T$4:$5:$6Z$7');
	}
	
	return delay;
}
