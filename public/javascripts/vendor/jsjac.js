/*

Jappix - An open social platform
This is the JSJaC library for Jappix (from trunk)

-------------------------------------------------

Licenses: Mozilla Public License version 1.1, GNU GPL, AGPL
Authors: Stefan Strigler, Valérian Saliou, Zash
Last revision: 25/08/11

*/

/**
 * @fileoverview Magic dependency loading. Taken from script.aculo.us
 * and modified to break it.
 * @author Stefan Strigler steve@zeank.in-berlin.de 
 * @version $Revision$
 */

var JSJaC = {
  Version: '$Rev$',
  bind: function(fn, obj, optArg) {
    return function(arg) {
      return fn.apply(obj, [arg, optArg]);
    };
  }
};

if (typeof JSJaCConnection == 'undefined')
  JSJaC.load();



/* Copyright 2006 Erik Arvidsson
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License.  You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.  See the License for the specific language governing
 * permissions and limitations under the License.
 */

/**
 * @fileoverview Wrapper to make working with XmlHttpRequest and the
 * DOM more convenient (cross browser compliance).
 * this code is taken from
 * http://webfx.eae.net/dhtml/xmlextras/xmlextras.html
 * @author Stefan Strigler steve@zeank.in-berlin.de
 * @version $Revision$
 */

/**
 * XmlHttp factory
 * @private
 */
function XmlHttp() {}

/**
 * creates a cross browser compliant XmlHttpRequest object
 */
XmlHttp.create = function () {
  try {
    // Are we cross-domain?
    if(((BOSH_PROXY == 'on') || (HOST_BOSH_MINI)) && (typeof jXHR == "function")) {
        // Able to use CORS?
        if (window.XMLHttpRequest) {
          var req = new XMLHttpRequest();
          
          if (req.withCredentials !== undefined)
            return req;
        }
        
    	return new jXHR();
    }
    // Might be local-domain?
    if (window.XMLHttpRequest) {
      var req = new XMLHttpRequest();
      
      // some versions of Moz do not support the readyState property
      // and the onreadystate event so we patch it!
      if (req.readyState == null) {
	req.readyState = 1;
	req.addEventListener("load", function () {
			       req.readyState = 4;
			       if (typeof req.onreadystatechange == "function")
				 req.onreadystatechange();
			     }, false);
      }
      
      return req;
    }
    if (window.ActiveXObject) {
      return new ActiveXObject(XmlHttp.getPrefix() + ".XmlHttp");
    }
  }
  catch (ex) {}
  // fell through
  throw new Error("Your browser does not support XmlHttp objects");
};

/**
 * used to find the Automation server name
 * @private
 */
XmlHttp.getPrefix = function() {
  if (XmlHttp.prefix) // I know what you did last summer
    return XmlHttp.prefix;
 
  var prefixes = ["MSXML2", "Microsoft", "MSXML", "MSXML3"];
  var o;
  for (var i = 0; i < prefixes.length; i++) {
    try {
      // try to create the objects
      o = new ActiveXObject(prefixes[i] + ".XmlHttp");
      return XmlHttp.prefix = prefixes[i];
    }
    catch (ex) {};
  }
 
  throw new Error("Could not find an installed XML parser");
};


/**
 * XmlDocument factory
 * @private
 */
function XmlDocument() {}

XmlDocument.create = function (name,ns) {
  name = name || 'foo';
  ns = ns || '';

  try {
    var doc;
    // DOM2
    if (document.implementation && document.implementation.createDocument) {
      doc = document.implementation.createDocument(ns, name, null);
      // some versions of Moz do not support the readyState property
      // and the onreadystate event so we patch it!
      if (doc.readyState == null) {
	doc.readyState = 1;
	doc.addEventListener("load", function () {
			       doc.readyState = 4;
			       if (typeof doc.onreadystatechange == "function")
				 doc.onreadystatechange();
			     }, false);
      }
    } else if (window.ActiveXObject) {
      doc = new ActiveXObject(XmlDocument.getPrefix() + ".DomDocument");
    }
   
    if (!doc.documentElement || doc.documentElement.tagName != name ||
        (doc.documentElement.namespaceURI &&
         doc.documentElement.namespaceURI != ns)) {
          try {
            if (ns != '')
              doc.appendChild(doc.createElement(name)).
                setAttribute('xmlns',ns);
            else
              doc.appendChild(doc.createElement(name));
          } catch (dex) {
            doc = document.implementation.createDocument(ns,name,null);
           
            if (doc.documentElement == null)
              doc.appendChild(doc.createElement(name));

             // fix buggy opera 8.5x
            if (ns != '' &&
                doc.documentElement.getAttribute('xmlns') != ns) {
              doc.documentElement.setAttribute('xmlns',ns);
            }
          }
        }
   
    return doc;
  }
  catch (ex) { }
  throw new Error("Your browser does not support XmlDocument objects");
};

/**
 * used to find the Automation server name
 * @private
 */
XmlDocument.getPrefix = function() {
  if (XmlDocument.prefix)
    return XmlDocument.prefix;

  var prefixes = ["MSXML2", "Microsoft", "MSXML", "MSXML3"];
  var o;
  for (var i = 0; i < prefixes.length; i++) {
    try {
      // try to create the objects
      o = new ActiveXObject(prefixes[i] + ".DomDocument");
      return XmlDocument.prefix = prefixes[i];
    }
    catch (ex) {};
  }
 
  throw new Error("Could not find an installed XML parser");
};


// Create the loadXML method
if (typeof(Document) != 'undefined' && window.DOMParser) {

  /**
   * XMLDocument did not extend the Document interface in some
   * versions of Mozilla.
   * @private
   */
  Document.prototype.loadXML = function (s) {
	
    // parse the string to a new doc
    var doc2 = (new DOMParser()).parseFromString(s, "text/xml");
	
    // remove all initial children
    while (this.hasChildNodes())
      this.removeChild(this.lastChild);
		
    // insert and import nodes
    for (var i = 0; i < doc2.childNodes.length; i++) {
      this.appendChild(this.importNode(doc2.childNodes[i], true));
    }
  };
 }

// Create xml getter for Mozilla
if (window.XMLSerializer &&
    window.Node && Node.prototype && Node.prototype.__defineGetter__) {

  /**
   * xml getter
   *
   * This serializes the DOM tree to an XML String
   *
   * Usage: var sXml = oNode.xml
   * @deprecated
   * @private
   */
  // XMLDocument did not extend the Document interface in some versions
  // of Mozilla. Extend both!
  XMLDocument.prototype.__defineGetter__("xml", function () {
                                           return (new XMLSerializer()).serializeToString(this);
                                         });
  /**
   * xml getter
   *
   * This serializes the DOM tree to an XML String
   *
   * Usage: var sXml = oNode.xml
   * @deprecated
   * @private
   */
  Document.prototype.__defineGetter__("xml", function () {
                                        return (new XMLSerializer()).serializeToString(this);
                                      });

  /**
   * xml getter
   *
   * This serializes the DOM tree to an XML String
   *
   * Usage: var sXml = oNode.xml
   * @deprecated
   * @private
   */
  Node.prototype.__defineGetter__("xml", function () {
                                    return (new XMLSerializer()).serializeToString(this);
                                  });
 }


/**
 * @fileoverview Collection of functions to make live easier
 * @author Stefan Strigler
 * @version $Revision$
 */

/**
 * Convert special chars to HTML entities
 * @addon
 * @return The string with chars encoded for HTML
 * @type String
 */
String.prototype.htmlEnc = function() {
  if(!this)
    return this;
  
  var str = this.replace(/&/g,"&amp;");
  str = str.replace(/</g,"&lt;");
  str = str.replace(/>/g,"&gt;");
  str = str.replace(/\"/g,"&quot;");
  str = str.replace(/\n/g,"<br />");
  return str;
};

/**
 * Convert HTML entities to special chars
 * @addon
 * @return The normal string
 * @type String
 */
String.prototype.revertHtmlEnc = function() {
  if(!this)
    return this;
  
  var str = this.replace(/&amp;/gi,'&');
  str = str.replace(/&lt;/gi,'<');
  str = str.replace(/&gt;/gi,'>');
  str = str.replace(/&quot;/gi,'\"');
  str = str.replace(/<br( )?(\/)?>/gi,'\n');
  return str;
};

/**
 * Converts from jabber timestamps to JavaScript Date objects
 * @addon
 * @param {String} ts A string representing a jabber datetime timestamp as
 * defined by {@link http://www.xmpp.org/extensions/xep-0082.html XEP-0082}
 * @return A javascript Date object corresponding to the jabber DateTime given
 * @type Date
 */
Date.jab2date = function(ts) {
  // Get the UTC date
  var date = new Date(Date.UTC(ts.substr(0,4),ts.substr(5,2)-1,ts.substr(8,2),ts.substr(11,2),ts.substr(14,2),ts.substr(17,2)));
  
  if (ts.substr(ts.length-6,1) != 'Z') { // there's an offset
    var date_offset = date.getTimezoneOffset() * 60 * 1000;
    var offset = new Date();
    offset.setTime(0);
    offset.setUTCHours(ts.substr(ts.length-5,2));
    offset.setUTCMinutes(ts.substr(ts.length-2,2));
    if (ts.substr(ts.length-6,1) == '+')
      date.setTime(date.getTime() + offset.getTime() + date_offset);
    else if (ts.substr(ts.length-6,1) == '-')
      date.setTime(date.getTime() - offset.getTime() + date_offset);
  }
  return date;
};

/**
 * Takes a timestamp in the form of 2004-08-13T12:07:04+02:00 as argument
 * and converts it to some sort of humane readable format
 * @addon
 */
Date.hrTime = function(ts) {
  return Date.jab2date(ts).toLocaleString();
};

/**
 * somewhat opposit to {@link #hrTime}
 * expects a javascript Date object as parameter and returns a jabber
 * date string conforming to
 * {@link http://www.xmpp.org/extensions/xep-0082.html XEP-0082}
 * @see #hrTime
 * @return The corresponding jabber DateTime string
 * @type String
 */
Date.prototype.jabberDate = function() {
  var padZero = function(i) {
    if (i < 10) return "0" + i;
    return i;
  };

  var jDate = this.getUTCFullYear() + "-";
  jDate += padZero(this.getUTCMonth()+1) + "-";
  jDate += padZero(this.getUTCDate()) + "T";
  jDate += padZero(this.getUTCHours()) + ":";
  jDate += padZero(this.getUTCMinutes()) + ":";
  jDate += padZero(this.getUTCSeconds()) + "Z";

  return jDate;
};

/**
 * Determines the maximum of two given numbers
 * @addon
 * @param {Number} A a number
 * @param {Number} B another number
 * @return the maximum of A and B
 * @type Number
 */
Number.max = function(A, B) {
  return (A > B)? A : B;
};

Number.min = function(A, B) {
  return (A < B)? A : B;
};


/* Copyright (c) 1998 - 2007, Paul Johnston & Contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following
 * disclaimer. Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * Neither the name of the author nor the names of its contributors
 * may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * @fileoverview Collection of MD5 and SHA1 hashing and encoding
 * methods.
 * @author Stefan Strigler steve@zeank.in-berlin.de
 * @version $Revision$
 */

/*
 * A JavaScript implementation of the Secure Hash Algorithm, SHA-1, as defined
 * in FIPS PUB 180-1
 * Version 2.1a Copyright Paul Johnston 2000 - 2002.
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for details.
 */

/*
 * Configurable variables. You may need to tweak these to be compatible with
 * the server-side, but the defaults work in most cases.
 */
var hexcase = 0;  /* hex output format. 0 - lowercase; 1 - uppercase        */
var b64pad  = "="; /* base-64 pad character. "=" for strict RFC compliance   */
var chrsz   = 8;  /* bits per input character. 8 - ASCII; 16 - Unicode      */

/*
 * These are the functions you'll usually want to call
 * They take string arguments and return either hex or base-64 encoded strings
 */
function hex_sha1(s){return binb2hex(core_sha1(str2binb(s),s.length * chrsz));}
function b64_sha1(s){return binb2b64(core_sha1(str2binb(s),s.length * chrsz));}
function str_sha1(s){return binb2str(core_sha1(str2binb(s),s.length * chrsz));}
function hex_hmac_sha1(key, data){ return binb2hex(core_hmac_sha1(key, data));}
function b64_hmac_sha1(key, data){ return binb2b64(core_hmac_sha1(key, data));}
function str_hmac_sha1(key, data){ return binb2str(core_hmac_sha1(key, data));}

/*
 * Perform a simple self-test to see if the VM is working
 */
function sha1_vm_test()
{
  return hex_sha1("abc") == "a9993e364706816aba3e25717850c26c9cd0d89d";
}

/*
 * Calculate the SHA-1 of an array of big-endian words, and a bit length
 */
function core_sha1(x, len)
{
  /* append padding */
  x[len >> 5] |= 0x80 << (24 - len % 32);
  x[((len + 64 >> 9) << 4) + 15] = len;

  var w = Array(80);
  var a =  1732584193;
  var b = -271733879;
  var c = -1732584194;
  var d =  271733878;
  var e = -1009589776;

  for(var i = 0; i < x.length; i += 16)
    {
      var olda = a;
      var oldb = b;
      var oldc = c;
      var oldd = d;
      var olde = e;

      for(var j = 0; j < 80; j++)
        {
          if(j < 16) w[j] = x[i + j];
          else w[j] = rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
          var t = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)),
                           safe_add(safe_add(e, w[j]), sha1_kt(j)));
          e = d;
          d = c;
          c = rol(b, 30);
          b = a;
          a = t;
        }

      a = safe_add(a, olda);
      b = safe_add(b, oldb);
      c = safe_add(c, oldc);
      d = safe_add(d, oldd);
      e = safe_add(e, olde);
    }
  return Array(a, b, c, d, e);

}

/*
 * Perform the appropriate triplet combination function for the current
 * iteration
 */
function sha1_ft(t, b, c, d)
{
  if(t < 20) return (b & c) | ((~b) & d);
  if(t < 40) return b ^ c ^ d;
  if(t < 60) return (b & c) | (b & d) | (c & d);
  return b ^ c ^ d;
}

/*
 * Determine the appropriate additive constant for the current iteration
 */
function sha1_kt(t)
{
  return (t < 20) ?  1518500249 : (t < 40) ?  1859775393 :
    (t < 60) ? -1894007588 : -899497514;
}

/*
 * Calculate the HMAC-SHA1 of a key and some data
 */
function core_hmac_sha1(key, data)
{
  var bkey = str2binb(key);
  if(bkey.length > 16) bkey = core_sha1(bkey, key.length * chrsz);

  var ipad = Array(16), opad = Array(16);
  for(var i = 0; i < 16; i++)
    {
      ipad[i] = bkey[i] ^ 0x36363636;
      opad[i] = bkey[i] ^ 0x5C5C5C5C;
    }

  var hash = core_sha1(ipad.concat(str2binb(data)), 512 + data.length * chrsz);
  return core_sha1(opad.concat(hash), 512 + 160);
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
function rol(num, cnt)
{
  return (num << cnt) | (num >>> (32 - cnt));
}

/*
 * Convert an 8-bit or 16-bit string to an array of big-endian words
 * In 8-bit function, characters >255 have their hi-byte silently ignored.
 */
function str2binb(str)
{
  var bin = Array();
  var mask = (1 << chrsz) - 1;
  for(var i = 0; i < str.length * chrsz; i += chrsz)
    bin[i>>5] |= (str.charCodeAt(i / chrsz) & mask) << (32 - chrsz - i%32);
  return bin;
}

/*
 * Convert an array of big-endian words to a string
 */
function binb2str(bin)
{
  var str = "";
  var mask = (1 << chrsz) - 1;
  for(var i = 0; i < bin.length * 32; i += chrsz)
    str += String.fromCharCode((bin[i>>5] >>> (32 - chrsz - i%32)) & mask);
  return str;
}

/*
 * Convert an array of big-endian words to a hex string.
 */
function binb2hex(binarray)
{
  var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
  var str = "";
  for(var i = 0; i < binarray.length * 4; i++)
    {
      str += hex_tab.charAt((binarray[i>>2] >> ((3 - i%4)*8+4)) & 0xF) +
        hex_tab.charAt((binarray[i>>2] >> ((3 - i%4)*8  )) & 0xF);
    }
  return str;
}

/*
 * Convert an array of big-endian words to a base-64 string
 */
function binb2b64(binarray)
{
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  var str = "";
  for(var i = 0; i < binarray.length * 4; i += 3)
    {
      var triplet = (((binarray[i   >> 2] >> 8 * (3 -  i   %4)) & 0xFF) << 16)
        | (((binarray[i+1 >> 2] >> 8 * (3 - (i+1)%4)) & 0xFF) << 8 )
        |  ((binarray[i+2 >> 2] >> 8 * (3 - (i+2)%4)) & 0xFF);
      for(var j = 0; j < 4; j++)
        {
          if(i * 8 + j * 6 > binarray.length * 32) str += b64pad;
          else str += tab.charAt((triplet >> 6*(3-j)) & 0x3F);
        }
    }
  return str.replace(/AAA\=(\=*?)$/,'$1'); // cleans garbage chars at end of string
}

/*
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Version 2.1 Copyright (C) Paul Johnston 1999 - 2002.
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for more info.
 */

/*
 * Configurable variables. You may need to tweak these to be compatible with
 * the server-side, but the defaults work in most cases.
 */
// var hexcase = 0;  /* hex output format. 0 - lowercase; 1 - uppercase        */
// var b64pad  = ""; /* base-64 pad character. "=" for strict RFC compliance   */
// var chrsz   = 8;  /* bits per input character. 8 - ASCII; 16 - Unicode      */

/*
 * These are the functions you'll usually want to call
 * They take string arguments and return either hex or base-64 encoded strings
 */
function hex_md5(s){ return binl2hex(core_md5(str2binl(s), s.length * chrsz));}
function b64_md5(s){ return binl2b64(core_md5(str2binl(s), s.length * chrsz));}
function str_md5(s){ return binl2str(core_md5(str2binl(s), s.length * chrsz));}
function hex_hmac_md5(key, data) { return binl2hex(core_hmac_md5(key, data)); }
function b64_hmac_md5(key, data) { return binl2b64(core_hmac_md5(key, data)); }
function str_hmac_md5(key, data) { return binl2str(core_hmac_md5(key, data)); }

/*
 * Perform a simple self-test to see if the VM is working
 */
function md5_vm_test()
{
  return hex_md5("abc") == "900150983cd24fb0d6963f7d28e17f72";
}

/*
 * Calculate the MD5 of an array of little-endian words, and a bit length
 */
function core_md5(x, len)
{
  /* append padding */
  x[len >> 5] |= 0x80 << ((len) % 32);
  x[(((len + 64) >>> 9) << 4) + 14] = len;

  var a =  1732584193;
  var b = -271733879;
  var c = -1732584194;
  var d =  271733878;

  for(var i = 0; i < x.length; i += 16)
  {
    var olda = a;
    var oldb = b;
    var oldc = c;
    var oldd = d;

    a = md5_ff(a, b, c, d, x[i+ 0], 7 , -680876936);
    d = md5_ff(d, a, b, c, x[i+ 1], 12, -389564586);
    c = md5_ff(c, d, a, b, x[i+ 2], 17,  606105819);
    b = md5_ff(b, c, d, a, x[i+ 3], 22, -1044525330);
    a = md5_ff(a, b, c, d, x[i+ 4], 7 , -176418897);
    d = md5_ff(d, a, b, c, x[i+ 5], 12,  1200080426);
    c = md5_ff(c, d, a, b, x[i+ 6], 17, -1473231341);
    b = md5_ff(b, c, d, a, x[i+ 7], 22, -45705983);
    a = md5_ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
    d = md5_ff(d, a, b, c, x[i+ 9], 12, -1958414417);
    c = md5_ff(c, d, a, b, x[i+10], 17, -42063);
    b = md5_ff(b, c, d, a, x[i+11], 22, -1990404162);
    a = md5_ff(a, b, c, d, x[i+12], 7 ,  1804603682);
    d = md5_ff(d, a, b, c, x[i+13], 12, -40341101);
    c = md5_ff(c, d, a, b, x[i+14], 17, -1502002290);
    b = md5_ff(b, c, d, a, x[i+15], 22,  1236535329);

    a = md5_gg(a, b, c, d, x[i+ 1], 5 , -165796510);
    d = md5_gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
    c = md5_gg(c, d, a, b, x[i+11], 14,  643717713);
    b = md5_gg(b, c, d, a, x[i+ 0], 20, -373897302);
    a = md5_gg(a, b, c, d, x[i+ 5], 5 , -701558691);
    d = md5_gg(d, a, b, c, x[i+10], 9 ,  38016083);
    c = md5_gg(c, d, a, b, x[i+15], 14, -660478335);
    b = md5_gg(b, c, d, a, x[i+ 4], 20, -405537848);
    a = md5_gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
    d = md5_gg(d, a, b, c, x[i+14], 9 , -1019803690);
    c = md5_gg(c, d, a, b, x[i+ 3], 14, -187363961);
    b = md5_gg(b, c, d, a, x[i+ 8], 20,  1163531501);
    a = md5_gg(a, b, c, d, x[i+13], 5 , -1444681467);
    d = md5_gg(d, a, b, c, x[i+ 2], 9 , -51403784);
    c = md5_gg(c, d, a, b, x[i+ 7], 14,  1735328473);
    b = md5_gg(b, c, d, a, x[i+12], 20, -1926607734);

    a = md5_hh(a, b, c, d, x[i+ 5], 4 , -378558);
    d = md5_hh(d, a, b, c, x[i+ 8], 11, -2022574463);
    c = md5_hh(c, d, a, b, x[i+11], 16,  1839030562);
    b = md5_hh(b, c, d, a, x[i+14], 23, -35309556);
    a = md5_hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
    d = md5_hh(d, a, b, c, x[i+ 4], 11,  1272893353);
    c = md5_hh(c, d, a, b, x[i+ 7], 16, -155497632);
    b = md5_hh(b, c, d, a, x[i+10], 23, -1094730640);
    a = md5_hh(a, b, c, d, x[i+13], 4 ,  681279174);
    d = md5_hh(d, a, b, c, x[i+ 0], 11, -358537222);
    c = md5_hh(c, d, a, b, x[i+ 3], 16, -722521979);
    b = md5_hh(b, c, d, a, x[i+ 6], 23,  76029189);
    a = md5_hh(a, b, c, d, x[i+ 9], 4 , -640364487);
    d = md5_hh(d, a, b, c, x[i+12], 11, -421815835);
    c = md5_hh(c, d, a, b, x[i+15], 16,  530742520);
    b = md5_hh(b, c, d, a, x[i+ 2], 23, -995338651);

    a = md5_ii(a, b, c, d, x[i+ 0], 6 , -198630844);
    d = md5_ii(d, a, b, c, x[i+ 7], 10,  1126891415);
    c = md5_ii(c, d, a, b, x[i+14], 15, -1416354905);
    b = md5_ii(b, c, d, a, x[i+ 5], 21, -57434055);
    a = md5_ii(a, b, c, d, x[i+12], 6 ,  1700485571);
    d = md5_ii(d, a, b, c, x[i+ 3], 10, -1894986606);
    c = md5_ii(c, d, a, b, x[i+10], 15, -1051523);
    b = md5_ii(b, c, d, a, x[i+ 1], 21, -2054922799);
    a = md5_ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
    d = md5_ii(d, a, b, c, x[i+15], 10, -30611744);
    c = md5_ii(c, d, a, b, x[i+ 6], 15, -1560198380);
    b = md5_ii(b, c, d, a, x[i+13], 21,  1309151649);
    a = md5_ii(a, b, c, d, x[i+ 4], 6 , -145523070);
    d = md5_ii(d, a, b, c, x[i+11], 10, -1120210379);
    c = md5_ii(c, d, a, b, x[i+ 2], 15,  718787259);
    b = md5_ii(b, c, d, a, x[i+ 9], 21, -343485551);

    a = safe_add(a, olda);
    b = safe_add(b, oldb);
    c = safe_add(c, oldc);
    d = safe_add(d, oldd);
  }
  return Array(a, b, c, d);

}

/*
 * These functions implement the four basic operations the algorithm uses.
 */
function md5_cmn(q, a, b, x, s, t)
{
  return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s),b);
}
function md5_ff(a, b, c, d, x, s, t)
{
  return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
}
function md5_gg(a, b, c, d, x, s, t)
{
  return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
}
function md5_hh(a, b, c, d, x, s, t)
{
  return md5_cmn(b ^ c ^ d, a, b, x, s, t);
}
function md5_ii(a, b, c, d, x, s, t)
{
  return md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
}

/*
 * Calculate the HMAC-MD5, of a key and some data
 */
function core_hmac_md5(key, data)
{
  var bkey = str2binl(key);
  if(bkey.length > 16) bkey = core_md5(bkey, key.length * chrsz);

  var ipad = Array(16), opad = Array(16);
  for(var i = 0; i < 16; i++)
  {
    ipad[i] = bkey[i] ^ 0x36363636;
    opad[i] = bkey[i] ^ 0x5C5C5C5C;
  }

  var hash = core_md5(ipad.concat(str2binl(data)), 512 + data.length * chrsz);
  return core_md5(opad.concat(hash), 512 + 128);
}

/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */
function safe_add(x, y)
{
  var lsw = (x & 0xFFFF) + (y & 0xFFFF);
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
  return (msw << 16) | (lsw & 0xFFFF);
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
function bit_rol(num, cnt)
{
  return (num << cnt) | (num >>> (32 - cnt));
}

/*
 * Convert a string to an array of little-endian words
 * If chrsz is ASCII, characters >255 have their hi-byte silently ignored.
 */
function str2binl(str)
{
  var bin = Array();
  var mask = (1 << chrsz) - 1;
  for(var i = 0; i < str.length * chrsz; i += chrsz)
    bin[i>>5] |= (str.charCodeAt(i / chrsz) & mask) << (i%32);
  return bin;
}

/*
 * Convert an array of little-endian words to a string
 */
function binl2str(bin)
{
  var str = "";
  var mask = (1 << chrsz) - 1;
  for(var i = 0; i < bin.length * 32; i += chrsz)
    str += String.fromCharCode((bin[i>>5] >>> (i % 32)) & mask);
  return str;
}

/*
 * Convert an array of little-endian words to a hex string.
 */
function binl2hex(binarray)
{
  var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
  var str = "";
  for(var i = 0; i < binarray.length * 4; i++)
  {
    str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
           hex_tab.charAt((binarray[i>>2] >> ((i%4)*8  )) & 0xF);
  }
  return str;
}

/*
 * Convert an array of little-endian words to a base-64 string
 */
function binl2b64(binarray)
{
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  var str = "";
  for(var i = 0; i < binarray.length * 4; i += 3)
  {
    var triplet = (((binarray[i   >> 2] >> 8 * ( i   %4)) & 0xFF) << 16)
                | (((binarray[i+1 >> 2] >> 8 * ((i+1)%4)) & 0xFF) << 8 )
                |  ((binarray[i+2 >> 2] >> 8 * ((i+2)%4)) & 0xFF);
    for(var j = 0; j < 4; j++)
    {
      if(i * 8 + j * 6 > binarray.length * 32) str += b64pad;
      else str += tab.charAt((triplet >> 6*(3-j)) & 0x3F);
    }
  }
  return str;
}

/* #############################################################################
   UTF-8 Decoder and Encoder
   base64 Encoder and Decoder
   written by Tobias Kieslich, justdreams
   Contact: tobias@justdreams.de				http://www.justdreams.de/
   ############################################################################# */

// returns an array of byterepresenting dezimal numbers which represent the
// plaintext in an UTF-8 encoded version. Expects a string.
// This function includes an exception management for those nasty browsers like
// NN401, which returns negative decimal numbers for chars>128. I hate it!!
// This handling is unfortunately limited to the user's charset. Anyway, it works
// in most of the cases! Special signs with an unicode>256 return numbers, which
// can not be converted to the actual unicode and so not to the valid utf-8
// representation. Anyway, this function does always return values which can not
// misinterpretd by RC4 or base64 en- or decoding, because every value is >0 and
// <255!!
// Arrays are faster and easier to handle in b64 encoding or encrypting....
function utf8t2d(t)
{
  t = t.replace(/\r\n/g,"\n");
  var d=new Array; var test=String.fromCharCode(237);
  if (test.charCodeAt(0) < 0)
    for(var n=0; n<t.length; n++)
      {
        var c=t.charCodeAt(n);
        if (c>0)
          d[d.length]= c;
        else {
          d[d.length]= (((256+c)>>6)|192);
          d[d.length]= (((256+c)&63)|128);}
      }
  else
    for(var n=0; n<t.length; n++)
      {
        var c=t.charCodeAt(n);
        // all the signs of asci => 1byte
        if (c<128)
          d[d.length]= c;
        // all the signs between 127 and 2047 => 2byte
        else if((c>127) && (c<2048)) {
          d[d.length]= ((c>>6)|192);
          d[d.length]= ((c&63)|128);}
        // all the signs between 2048 and 66536 => 3byte
        else {
          d[d.length]= ((c>>12)|224);
          d[d.length]= (((c>>6)&63)|128);
          d[d.length]= ((c&63)|128);}
      }
  return d;
}
	
// returns plaintext from an array of bytesrepresenting dezimal numbers, which
// represent an UTF-8 encoded text; browser which does not understand unicode
// like NN401 will show "?"-signs instead
// expects an array of byterepresenting decimals; returns a string
function utf8d2t(d)
{
  var r=new Array; var i=0;
  while(i<d.length)
    {
      if (d[i]<128) {
        r[r.length]= String.fromCharCode(d[i]); i++;}
      else if((d[i]>191) && (d[i]<224)) {
        r[r.length]= String.fromCharCode(((d[i]&31)<<6) | (d[i+1]&63)); i+=2;}
      else {
        r[r.length]= String.fromCharCode(((d[i]&15)<<12) | ((d[i+1]&63)<<6) | (d[i+2]&63)); i+=3;}
    }
  return r.join("");
}

// included in <body onload="b64arrays"> it creates two arrays which makes base64
// en- and decoding faster
// this speed is noticeable especially when coding larger texts (>5k or so)
function b64arrays() {
  var b64s='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  b64 = new Array();f64 =new Array();
  for (var i=0; i<b64s.length ;i++) {
    b64[i] = b64s.charAt(i);
    f64[b64s.charAt(i)] = i;
  }
}

// creates a base64 encoded text out of an array of byerepresenting dezimals
// it is really base64 :) this makes serversided handling easier
// expects an array; returns a string
function b64d2t(d) {
  var r=new Array; var i=0; var dl=d.length;
  // this is for the padding
  if ((dl%3) == 1) {
    d[d.length] = 0; d[d.length] = 0;}
  if ((dl%3) == 2)
    d[d.length] = 0;
  // from here conversion
  while (i<d.length)
    {
      r[r.length] = b64[d[i]>>2];
      r[r.length] = b64[((d[i]&3)<<4) | (d[i+1]>>4)];
      r[r.length] = b64[((d[i+1]&15)<<2) | (d[i+2]>>6)];
      r[r.length] = b64[d[i+2]&63];
      i+=3;
    }
  // this is again for the padding
  if ((dl%3) == 1)
    r[r.length-1] = r[r.length-2] = "=";
  if ((dl%3) == 2)
    r[r.length-1] = "=";
  // we join the array to return a textstring
  var t=r.join("");
  return t;
}

// returns array of byterepresenting numbers created of an base64 encoded text
// it is still the slowest function in this modul; I hope I can make it faster
// expects string; returns an array
function b64t2d(t) {
  var d=new Array; var i=0;
  // here we fix this CRLF sequenz created by MS-OS; arrrgh!!!
  t=t.replace(/\n|\r/g,""); t=t.replace(/=/g,"");
  while (i<t.length)
    {
      d[d.length] = (f64[t.charAt(i)]<<2) | (f64[t.charAt(i+1)]>>4);
      d[d.length] = (((f64[t.charAt(i+1)]&15)<<4) | (f64[t.charAt(i+2)]>>2));
      d[d.length] = (((f64[t.charAt(i+2)]&3)<<6) | (f64[t.charAt(i+3)]));
      i+=4;
    }
  if (t.length%4 == 2)
    d = d.slice(0, d.length-2);
  if (t.length%4 == 3)
    d = d.slice(0, d.length-1);
  return d;
}

b64arrays();

b64decode = function(s) {
  return utf8d2t(b64t2d(s));
}

b64encode = function(s) {
  return b64d2t(utf8t2d(s));
}

function cnonce(size) {
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  var cnonce = '';
  for (var i=0; i<size; i++) {
    cnonce += tab.charAt(Math.round(Math.random(new Date().getTime())*(tab.length-1)));
  }
  return cnonce;
}



JSJAC_HAVEKEYS = true;          // whether to use keys
JSJAC_NKEYS    = 16;            // number of keys to generate
JSJAC_INACTIVITY = 300;         // qnd hack to make suspend/resume 
                                    // work more smoothly with polling
JSJAC_ERR_COUNT = 10;           // number of retries in case of connection
                                    // errors

JSJAC_ALLOW_PLAIN = true;       // whether to allow plaintext logins

JSJAC_CHECKQUEUEINTERVAL = 100;   // msecs to poll send queue
JSJAC_CHECKINQUEUEINTERVAL = 100; // msecs to poll incoming queue
JSJAC_TIMERVAL = 2000;          // default polling interval

// Options specific to HTTP Binding (BOSH)
JSJACHBC_MAX_HOLD = 1;          // default for number of connections held by 
                                    // connection manager 
JSJACHBC_MAX_WAIT = 20;        // default 'wait' param - how long an idle connection
                                    // should be held by connection manager

JSJACHBC_BOSH_VERSION  = "1.6";
JSJACHBC_USE_BOSH_VER  = true;

JSJACHBC_MAXPAUSE = 20;        // how long a suspend/resume cycle may take

/*** END CONFIG ***/


/* Copyright (c) 2005-2007 Sam Stephenson
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
  json.js
  taken from prototype.js, made static
*/
function JSJaCJSON() {}
JSJaCJSON.toString = function (obj) {
  var m = {
    '\b': '\\b',
    '\t': '\\t',
    '\n': '\\n',
    '\f': '\\f',
    '\r': '\\r',
    '"' : '\\"',
    '\\': '\\\\'
  },
  s = {
    array: function (x) {
      var a = ['['], b, f, i, l = x.length, v;
      for (i = 0; i < l; i += 1) {
        v = x[i];
        f = s[typeof v];
        if (f) {
	  try {
            v = f(v);
            if (typeof v == 'string') {
              if (b) {
                a[a.length] = ',';
              }
              a[a.length] = v;
              b = true;
            }
	  } catch(e) { 
	  }
        }
      }
      a[a.length] = ']';
      return a.join('');
    },
    'boolean': function (x) {
      return String(x);
    },
    'null': function (x) {
      return "null";
    },
    number: function (x) {
      return isFinite(x) ? String(x) : 'null';
    },
    object: function (x) {
      if (x) {
        if (x instanceof Array) {
          return s.array(x);
        }
        var a = ['{'], b, f, i, v;
        for (i in x) {
          if (x.hasOwnProperty(i)) {
            v = x[i];
            f = s[typeof v];
            if (f) {
	      try {
                v = f(v);
                if (typeof v == 'string') {
                  if (b) {
                    a[a.length] = ',';
                  }
                  a.push(s.string(i), ':', v);
                  b = true;
                }
	      } catch(e) {
	      }
            }
          }
        }
         
        a[a.length] = '}';
        return a.join('');
      }
      return 'null';
    },
    string: function (x) {
      if (/["\\\x00-\x1f]/.test(x)) {
                    x = x.replace(/([\x00-\x1f\\"])/g, function(a, b) {
          var c = m[b];
          if (c) {
            return c;
          }
          c = b.charCodeAt();
          return '\\u00' +
          Math.floor(c / 16).toString(16) +
          (c % 16).toString(16);
        });
  }
  return '"' + x + '"';
}
  };

switch (typeof(obj)) {
 case 'object':
   return s.object(obj);
 case 'array':
   return s.array(obj);
   
 }
};

JSJaCJSON.parse = function (str) {
  try {
    return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                                                       str.replace(/"(\\.|[^"\\])*"/g, ''))) &&
            eval('(' + str + ')');
    } catch (e) {
        return false;
    }
};


/**
 * @fileoverview This file contains all things that make life easier when
 * dealing with JIDs
 * @author Stefan Strigler
 * @version $Revision$
 */

/**
 * list of forbidden chars for nodenames
 * @private
 */
var JSJACJID_FORBIDDEN = ['"',' ','&','\'','/',':','<','>','@'];

/**
 * Creates a new JSJaCJID object
 * @class JSJaCJID models xmpp jid objects
 * @constructor
 * @param {Object} jid jid may be either of type String or a JID represented
 * by JSON with fields 'node', 'domain' and 'resource'
 * @throws JSJaCJIDInvalidException Thrown if jid is not valid
 * @return a new JSJaCJID object
 */
function JSJaCJID(jid) {
  /**
   *@private
   */
  this._node = '';
  /**
   *@private
   */
  this._domain = '';
  /**
   *@private
   */
  this._resource = '';

  if (typeof(jid) == 'string') {
    if (jid.indexOf('@') != -1) {
        this.setNode(jid.substring(0,jid.indexOf('@')));
        jid = jid.substring(jid.indexOf('@')+1);
    }
    if (jid.indexOf('/') != -1) {
      this.setResource(jid.substring(jid.indexOf('/')+1));
      jid = jid.substring(0,jid.indexOf('/'));
    }
    this.setDomain(jid);
  } else {
    this.setNode(jid.node);
    this.setDomain(jid.domain);
    this.setResource(jid.resource);
  }
}


/**
 * Gets the node part of the jid
 * @return A string representing the node name
 * @type String
 */
JSJaCJID.prototype.getNode = function() { return this._node; };

/**
 * Gets the domain part of the jid
 * @return A string representing the domain name
 * @type String
 */
JSJaCJID.prototype.getDomain = function() { return this._domain; };

/**
 * Gets the resource part of the jid
 * @return A string representing the resource
 * @type String
 */
JSJaCJID.prototype.getResource = function() { return this._resource; };


/**
 * Sets the node part of the jid
 * @param {String} node Name of the node
 * @throws JSJaCJIDInvalidException Thrown if node name contains invalid chars
 * @return This object
 * @type JSJaCJID
 */
JSJaCJID.prototype.setNode = function(node) {
  JSJaCJID._checkNodeName(node);
  this._node = node || '';
  return this;
};

/**
 * Sets the domain part of the jid
 * @param {String} domain Name of the domain
 * @throws JSJaCJIDInvalidException Thrown if domain name contains invalid
 * chars or is empty
 * @return This object
 * @type JSJaCJID
 */
JSJaCJID.prototype.setDomain = function(domain) {
  if (!domain || domain == '')
    throw new JSJaCJIDInvalidException("domain name missing");
  // chars forbidden for a node are not allowed in domain names
  // anyway, so let's check
  JSJaCJID._checkNodeName(domain);
  this._domain = domain;
  return this;
};

/**
 * Sets the resource part of the jid
 * @param {String} resource Name of the resource
 * @return This object
 * @type JSJaCJID
 */
JSJaCJID.prototype.setResource = function(resource) {
  this._resource = resource || '';
  return this;
};

/**
 * The string representation of the full jid
 * @return A string representing the jid
 * @type String
 */
JSJaCJID.prototype.toString = function() {
  var jid = '';
  if (this.getNode() && this.getNode() != '')
    jid = this.getNode() + '@';
  jid += this.getDomain(); // we always have a domain
  if (this.getResource() && this.getResource() != "")
    jid += '/' + this.getResource();
  return jid;
};

/**
 * Removes the resource part of the jid
 * @return This object
 * @type JSJaCJID
 */
JSJaCJID.prototype.removeResource = function() {
  return this.setResource();
};

/**
 * creates a copy of this JSJaCJID object
 * @return A copy of this
 * @type JSJaCJID
 */
JSJaCJID.prototype.clone = function() {
  return new JSJaCJID(this.toString());
};

/**
 * Compares two jids if they belong to the same entity (i.e. w/o resource)
 * @param {String} jid a jid as string or JSJaCJID object
 * @return 'true' if jid is same entity as this
 * @type Boolean
 */
JSJaCJID.prototype.isEntity = function(jid) {
  if (typeof jid == 'string')
	  jid = (new JSJaCJID(jid));
  jid.removeResource();
  return (this.clone().removeResource().toString() === jid.toString());
};

/**
 * Check if node name is valid
 * @private
 * @param {String} node A name for a node
 * @throws JSJaCJIDInvalidException Thrown if name for node is not allowed
 */
JSJaCJID._checkNodeName = function(nodeprep) {
    if (!nodeprep || nodeprep == '')
      return;
    for (var i=0; i< JSJACJID_FORBIDDEN.length; i++) {
      if (nodeprep.indexOf(JSJACJID_FORBIDDEN[i]) != -1) {
        throw new JSJaCJIDInvalidException("forbidden char in nodename: "+JSJACJID_FORBIDDEN[i]);
      }
    }
};

/**
 * Creates a new Exception of type JSJaCJIDInvalidException
 * @class Exception to indicate invalid values for a jid
 * @constructor
 * @param {String} message The message associated with this Exception
 */
function JSJaCJIDInvalidException(message) {
  /**
   * The exceptions associated message
   * @type String
   */
  this.message = message;
  /**
   * The name of the exception
   * @type String
   */
  this.name = "JSJaCJIDInvalidException";
}


/* Copyright (c) 2005 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
 * @private
 * This code is taken from {@link
 * http://wiki.script.aculo.us/scriptaculous/show/Builder
 * script.aculo.us' Dom Builder} and has been modified to suit our
 * needs.<br/>
 * The original parts of the code do have the following
 * copyright and license notice:<br/>
 * Copyright (c) 2005, 2006 Thomas Fuchs (http://script.aculo.us,
 * http://mir.acu lo.us) <br/>
 * script.aculo.us is freely distributable under the terms of an
 * MIT-style license.<br>
 * For details, see the script.aculo.us web site:
 * http://script.aculo.us/<br>
 */
var JSJaCBuilder = {
  /**
   * @private
   */
  buildNode: function(doc, elementName) {

    var element, ns = arguments[4];

    // attributes (or text)
    if(arguments[2])
      if(JSJaCBuilder._isStringOrNumber(arguments[2]) ||
         (arguments[2] instanceof Array)) {
        element = this._createElement(doc, elementName, ns);
        JSJaCBuilder._children(doc, element, arguments[2]);
      } else {
        ns = arguments[2]['xmlns'] || ns;
        element = this._createElement(doc, elementName, ns);
        for(attr in arguments[2]) {
          if (arguments[2].hasOwnProperty(attr) && attr != 'xmlns')
            element.setAttribute(attr, arguments[2][attr]);
        }
      }
    else
      element = this._createElement(doc, elementName, ns);
    // text, or array of children
    if(arguments[3])
      JSJaCBuilder._children(doc, element, arguments[3], ns);

    return element;
  },

  _createElement: function(doc, elementName, ns) {
    try {
      if (ns)
        return doc.createElementNS(ns, elementName);
    } catch (ex) { }

    var el = doc.createElement(elementName);

    if (ns)
      el.setAttribute("xmlns", ns);

    return el;
  },

  /**
   * @private
   */
  _text: function(doc, text) {
    return doc.createTextNode(text);
  },

  /**
   * @private
   */
  _children: function(doc, element, children, ns) {
    if(typeof children=='object') { // array can hold nodes and text
      for (var i in children) {
        if (children.hasOwnProperty(i)) {
          var e = children[i];
          if (typeof e=='object') {
            if (e instanceof Array) {
              var node = JSJaCBuilder.buildNode(doc, e[0], e[1], e[2], ns);
              element.appendChild(node);
            } else {
              element.appendChild(e);
            }
          } else {
            if(JSJaCBuilder._isStringOrNumber(e)) {
              element.appendChild(JSJaCBuilder._text(doc, e));
            }
          }
        }
      }
    } else {
      if(JSJaCBuilder._isStringOrNumber(children)) {
        element.appendChild(JSJaCBuilder._text(doc, children));
      }
    }
  },

  _attributes: function(attributes) {
    var attrs = [];
    for(attribute in attributes)
      if (attributes.hasOwnProperty(attribute))
        attrs.push(attribute +
          '="' + attributes[attribute].toString().htmlEnc() + '"');
    return attrs.join(" ");
  },

  _isStringOrNumber: function(param) {
    return(typeof param=='string' || typeof param=='number');
  }
};


/**
 * @fileoverview Contains all Jabber/XMPP packet related classes.
 * @author Stefan Strigler steve@zeank.in-berlin.de
 * @version $Revision$
 */

var JSJACPACKET_USE_XMLNS = true;

/**
 * Creates a new packet with given root tag name (for internal use)
 * @class Somewhat abstract base class for all kinds of specialised packets
 * @param {String} name The root tag name of the packet
 * (i.e. one of 'message', 'iq' or 'presence')
 */
function JSJaCPacket(name) {
  /**
   * @private
   */
  this.name = name;

  if (typeof(JSJACPACKET_USE_XMLNS) != 'undefined' && JSJACPACKET_USE_XMLNS)
    /**
     * @private
     */
    this.doc = XmlDocument.create(name,'jabber:client');
  else
    /**
     * @private
     */
    this.doc = XmlDocument.create(name,'');
}

/**
 * Gets the type (name of root element) of this packet, i.e. one of
 * 'presence', 'message' or 'iq'
 * @return the top level tag name
 * @type String
 */
JSJaCPacket.prototype.pType = function() { return this.name; };

/**
 * Gets the associated Document for this packet.
 * @type {@link http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#i-Document Document}
 */
JSJaCPacket.prototype.getDoc = function() {
  return this.doc;
};
/**
 * Gets the root node of this packet
 * @type {@link http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node}
 */
JSJaCPacket.prototype.getNode = function() {
  if (this.getDoc() && this.getDoc().documentElement)
    return this.getDoc().documentElement;
  else
    return null;
};

/**
 * Sets the 'to' attribute of the root node of this packet
 * @param {String} to
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.setTo = function(to) {
  if (!to || to == '')
    this.getNode().removeAttribute('to');
  else if (typeof(to) == 'string')
    this.getNode().setAttribute('to',to);
  else
    this.getNode().setAttribute('to',to.toString());
  return this;
};
/**
 * Sets the 'from' attribute of the root node of this
 * packet. Usually this is not needed as the server will take care
 * of this automatically.
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.setFrom = function(from) {
  if (!from || from == '')
    this.getNode().removeAttribute('from');
  else if (typeof(from) == 'string')
    this.getNode().setAttribute('from',from);
  else
    this.getNode().setAttribute('from',from.toString());
  return this;
};
/**
 * Sets 'id' attribute of the root node of this packet.
 * @param {String} id The id of the packet.
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.setID = function(id) {
  if (!id || id == '')
    this.getNode().removeAttribute('id');
  else
    this.getNode().setAttribute('id',id);
  return this;
};
/**
 * Sets the 'type' attribute of the root node of this packet.
 * @param {String} type The type of the packet.
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.setType = function(type) {
  if (!type || type == '')
    this.getNode().removeAttribute('type');
  else
    this.getNode().setAttribute('type',type);
  return this;
};
/**
 * Sets 'xml:lang' for this packet
 * @param {String} xmllang The xml:lang of the packet.
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.setXMLLang = function(xmllang) {
  // Fix IE9+ bug with xml:lang attribute
  if (BrowserDetect && (BrowserDetect.browser == 'Explorer') && (BrowserDetect.version >= 9))
    return this;
  if (!xmllang || xmllang == '')
    this.getNode().removeAttribute('xml:lang');
  else
    this.getNode().setAttribute('xml:lang',xmllang);
  return this;
};

/**
 * Gets the 'to' attribute of this packet
 * @type String
 */
JSJaCPacket.prototype.getTo = function() {
  return this.getNode().getAttribute('to');
};
/**
 * Gets the 'from' attribute of this packet.
 * @type String
 */
JSJaCPacket.prototype.getFrom = function() {
  return this.getNode().getAttribute('from');
};
/**
 * Gets the 'to' attribute of this packet as a JSJaCJID object
 * @type JSJaCJID
 */
JSJaCPacket.prototype.getToJID = function() {
  return new JSJaCJID(this.getTo());
};
/**
 * Gets the 'from' attribute of this packet as a JSJaCJID object
 * @type JSJaCJID
 */
JSJaCPacket.prototype.getFromJID = function() {
  return new JSJaCJID(this.getFrom());
};
/**
 * Gets the 'id' of this packet
 * @type String
 */
JSJaCPacket.prototype.getID = function() {
  return this.getNode().getAttribute('id');
};
/**
 * Gets the 'type' of this packet
 * @type String
 */
JSJaCPacket.prototype.getType = function() {
  return this.getNode().getAttribute('type');
};
/**
 * Gets the 'xml:lang' of this packet
 * @type String
 */
JSJaCPacket.prototype.getXMLLang = function() {
  return this.getNode().getAttribute('xml:lang');
};
/**
 * Gets the 'xmlns' (xml namespace) of the root node of this packet
 * @type String
 */
JSJaCPacket.prototype.getXMLNS = function() {
  return this.getNode().namespaceURI || this.getNode().getAttribute('xmlns');
};

/**
 * Gets a child element of this packet. If no params given returns first child.
 * @param {String} name Tagname of child to retrieve. Use '*' to match any tag. [optional]
 * @param {String} ns   Namespace of child. Use '*' to match any ns.[optional]
 * @return The child node, null if none found
 * @type {@link http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node}
 */
JSJaCPacket.prototype.getChild = function(name, ns) {
  if (!this.getNode()) {
    return null;
  }

  name = name || '*';
  ns = ns || '*';

  if (this.getNode().getElementsByTagNameNS) {
    return this.getNode().getElementsByTagNameNS(ns, name).item(0);
  }

  // fallback
  var nodes = this.getNode().getElementsByTagName(name);
  if (ns != '*') {
    for (var i=0; i<nodes.length; i++) {
      if (nodes.item(i).namespaceURI == ns || nodes.item(i).getAttribute('xmlns') == ns) {
        return nodes.item(i);
      }
    }
  } else {
    return nodes.item(0);
  }
  return null; // nothing found
};

/**
 * Gets the node value of a child element of this packet.
 * @param {String} name Tagname of child to retrieve.
 * @param {String} ns   Namespace of child
 * @return The value of the child node, empty string if none found
 * @type String
 */
JSJaCPacket.prototype.getChildVal = function(name, ns) {
  var node = this.getChild(name, ns);
  var ret = '';
  if (node && node.hasChildNodes()) {
    // concatenate all values from childNodes
    for (var i=0; i<node.childNodes.length; i++)
      if (node.childNodes.item(i).nodeValue)
        ret += node.childNodes.item(i).nodeValue;
  }
  return ret;
};

/**
 * Returns a copy of this node
 * @return a copy of this node
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.clone = function() {
  return JSJaCPacket.wrapNode(this.getNode());
};

/**
 * Checks if packet is of type 'error'
 * @return 'true' if this packet is of type 'error', 'false' otherwise
 * @type boolean
 */
JSJaCPacket.prototype.isError = function() {
  return (this.getType() == 'error');
};

/**
 * Returns an error condition reply according to {@link http://www.xmpp.org/extensions/xep-0086.html XEP-0086}. Creates a clone of the calling packet with senders and recipient exchanged and error stanza appended.
 * @param {STANZA_ERROR} stanza_error an error stanza containing error cody, type and condition of the error to be indicated
 * @return an error reply packet
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.errorReply = function(stanza_error) {
  var rPacket = this.clone();
  rPacket.setTo(this.getFrom());
  rPacket.setFrom();
  rPacket.setType('error');

  rPacket.appendNode('error',
                     {code: stanza_error.code, type: stanza_error.type},
                     [[stanza_error.cond]]);

  return rPacket;
};

/**
 * Returns a string representation of the raw xml content of this packet.
 * @type String
 */
JSJaCPacket.prototype.xml = typeof XMLSerializer != 'undefined' ?
function() {
  var r = (new XMLSerializer()).serializeToString(this.getNode());
  if (typeof(r) == 'undefined')
    r = (new XMLSerializer()).serializeToString(this.doc); // oldschool
  return r
} :
function() {// IE
  return this.getDoc().xml
};


// PRIVATE METHODS DOWN HERE

/**
 * Gets an attribute of the root element
 * @private
 */
JSJaCPacket.prototype._getAttribute = function(attr) {
  return this.getNode().getAttribute(attr);
};


if (document.ELEMENT_NODE == null) {
  document.ELEMENT_NODE = 1;
  document.ATTRIBUTE_NODE = 2;
  document.TEXT_NODE = 3;
  document.CDATA_SECTION_NODE = 4;
  document.ENTITY_REFERENCE_NODE = 5;
  document.ENTITY_NODE = 6;
  document.PROCESSING_INSTRUCTION_NODE = 7;
  document.COMMENT_NODE = 8;
  document.DOCUMENT_NODE = 9;
  document.DOCUMENT_TYPE_NODE = 10;
  document.DOCUMENT_FRAGMENT_NODE = 11;
  document.NOTATION_NODE = 12;
}

/**
 * import node into this packets document
 * @private
 */
JSJaCPacket.prototype._importNode = function(node, allChildren) {
  switch (node.nodeType) {
  case document.ELEMENT_NODE:

  if (this.getDoc().createElementNS) {
    var newNode = this.getDoc().createElementNS(node.namespaceURI, node.nodeName);
  } else {
    var newNode = this.getDoc().createElement(node.nodeName);
  }

  /* does the node have any attributes to add? */
  if (node.attributes && node.attributes.length > 0)
    for (var i = 0, il = node.attributes.length;i < il; i++) {
      var attr = node.attributes.item(i);
      if (attr.nodeName == 'xmlns' && newNode.getAttribute('xmlns') != null ) continue;
      if (newNode.setAttributeNS && attr.namespaceURI) {
        newNode.setAttributeNS(attr.namespaceURI,
                               attr.nodeName,
                               attr.nodeValue);
      } else {
        newNode.setAttribute(attr.nodeName,
                             attr.nodeValue);
      }
    }
  /* are we going after children too, and does the node have any? */
  if (allChildren && node.childNodes && node.childNodes.length > 0) {
    for (var i = 0, il = node.childNodes.length; i < il; i++) {
      newNode.appendChild(this._importNode(node.childNodes.item(i), allChildren));
    }
  }
  return newNode;
  break;
  case document.TEXT_NODE:
  case document.CDATA_SECTION_NODE:
  case document.COMMENT_NODE:
  return this.getDoc().createTextNode(node.nodeValue);
  break;
  }
};

/**
 * Set node value of a child node
 * @private
 */
JSJaCPacket.prototype._setChildNode = function(nodeName, nodeValue) {
  var aNode = this.getChild(nodeName);
  var tNode = this.getDoc().createTextNode(nodeValue);
  if (aNode)
    try {
      aNode.replaceChild(tNode,aNode.firstChild);
    } catch (e) { }
  else {
    try {
      aNode = this.getDoc().createElementNS(this.getNode().namespaceURI,
                                            nodeName);
    } catch (ex) {
      aNode = this.getDoc().createElement(nodeName)
    }
    this.getNode().appendChild(aNode);
    aNode.appendChild(tNode);
  }
  return aNode;
};

/**
 * Builds a node using {@link
 * http://wiki.script.aculo.us/scriptaculous/show/Builder
 * script.aculo.us' Dom Builder} notation.
 * This code is taken from {@link
 * http://wiki.script.aculo.us/scriptaculous/show/Builder
 * script.aculo.us' Dom Builder} and has been modified to suit our
 * needs.<br/>
 * The original parts of the code do have the following copyright
 * and license notice:<br/>
 * Copyright (c) 2005, 2006 Thomas Fuchs (http://script.aculo.us,
 * http://mir.acu lo.us) <br/>
 * script.aculo.us is freely distributable under the terms of an
 * MIT-style licen se.  // For details, see the script.aculo.us web
 * site: http://script.aculo.us/<br>
 * @author Thomas Fuchs
 * @author Stefan Strigler
 * @return The newly created node
 * @type {@link http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node}
 */
JSJaCPacket.prototype.buildNode = function(elementName) {
  return JSJaCBuilder.buildNode(this.getDoc(),
                                elementName,
                                arguments[1],
                                arguments[2]);
};

/**
 * Appends node created by buildNode to this packets parent node.
 * @param {@link http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node} element The node to append or
 * @param {String} element A name plus an object hash with attributes (optional) plus an array of childnodes (optional)
 * @see #buildNode
 * @return This packet
 * @type JSJaCPacket
 */
JSJaCPacket.prototype.appendNode = function(element) {
  if (typeof element=='object') { // seems to be a prebuilt node
    return this.getNode().appendChild(element)
  } else { // build node
    return this.getNode().appendChild(this.buildNode(element,
                                                     arguments[1],
                                                     arguments[2],
                                                     null,
                                                     this.getNode().namespaceURI));
  }
};


/**
 * A jabber/XMPP presence packet
 * @class Models the XMPP notion of a 'presence' packet
 * @extends JSJaCPacket
 */
function JSJaCPresence() {
  /**
   * @ignore
   */
  this.base = JSJaCPacket;
  this.base('presence');
}
JSJaCPresence.prototype = new JSJaCPacket;

/**
 * Sets the status message for current status. Usually this is set
 * to some human readable string indicating what the user is
 * doing/feel like currently.
 * @param {String} status A status message
 * @return this
 * @type JSJaCPacket
 */
JSJaCPresence.prototype.setStatus = function(status) {
  this._setChildNode("status", status);
  return this;
};
/**
 * Sets the online status for this presence packet.
 * @param {String} show An XMPP complient status indicator. Must
 * be one of 'chat', 'away', 'xa', 'dnd'
 * @return this
 * @type JSJaCPacket
 */
JSJaCPresence.prototype.setShow = function(show) {
  if (show == 'chat' || show == 'away' || show == 'xa' || show == 'dnd')
    this._setChildNode("show",show);
  return this;
};
/**
 * Sets the priority of the resource bind to with this connection
 * @param {int} prio The priority to set this resource to
 * @return this
 * @type JSJaCPacket
 */
JSJaCPresence.prototype.setPriority = function(prio) {
  this._setChildNode("priority", prio);
  return this;
};
/**
 * Some combined method that allowes for setting show, status and
 * priority at once
 * @param {String} show A status message
 * @param {String} status A status indicator as defined by XMPP
 * @param {int} prio A priority for this resource
 * @return this
 * @type JSJaCPacket
 */
JSJaCPresence.prototype.setPresence = function(show,status,prio) {
  if (show)
    this.setShow(show);
  if (status)
    this.setStatus(status);
  if (prio)
    this.setPriority(prio);
  return this;
};

/**
 * Gets the status message of this presence
 * @return The (human readable) status message
 * @type String
 */
JSJaCPresence.prototype.getStatus = function() {
  return this.getChildVal('status');
};
/**
 * Gets the status of this presence.
 * Either one of 'chat', 'away', 'xa' or 'dnd' or null.
 * @return The status indicator as defined by XMPP
 * @type String
 */
JSJaCPresence.prototype.getShow = function() {
  return this.getChildVal('show');
};
/**
 * Gets the priority of this status message
 * @return A resource priority
 * @type int
 */
JSJaCPresence.prototype.getPriority = function() {
  return this.getChildVal('priority');
};


/**
 * A jabber/XMPP iq packet
 * @class Models the XMPP notion of an 'iq' packet
 * @extends JSJaCPacket
 */
function JSJaCIQ() {
  /**
   * @ignore
   */
  this.base = JSJaCPacket;
  this.base('iq');
}
JSJaCIQ.prototype = new JSJaCPacket;

/**
 * Some combined method to set 'to', 'type' and 'id' at once
 * @param {String} to the recepients JID
 * @param {String} type A XMPP compliant iq type (one of 'set', 'get', 'result' and 'error'
 * @param {String} id A packet ID
 * @return this
 * @type JSJaCIQ
 */
JSJaCIQ.prototype.setIQ = function(to,type,id) {
  if (to)
    this.setTo(to);
  if (type)
    this.setType(type);
  if (id)
    this.setID(id);
  return this;
};
/**
 * Creates a 'query' child node with given XMLNS
 * @param {String} xmlns The namespace for the 'query' node
 * @return The query node
 * @type {@link  http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node}
 */
JSJaCIQ.prototype.setQuery = function(xmlns) {
  var query;
  try {
    query = this.getDoc().createElementNS(xmlns,'query');
  } catch (e) {
    query = this.getDoc().createElement('query');
	query.setAttribute('xmlns',xmlns);
  }
  this.getNode().appendChild(query);
  return query;
};

/**
 * Gets the 'query' node of this packet
 * @return The query node
 * @type {@link  http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247 Node}
 */
JSJaCIQ.prototype.getQuery = function() {
  return this.getNode().getElementsByTagName('query').item(0);
};
/**
 * Gets the XMLNS of the query node contained within this packet
 * @return The namespace of the query node
 * @type String
 */
JSJaCIQ.prototype.getQueryXMLNS = function() {
  if (this.getQuery()) {
    return this.getQuery().namespaceURI || this.getQuery().getAttribute('xmlns');
  } else {
    return null;
  }
};

/**
 * Creates an IQ reply with type set to 'result'. If given appends payload to first child if IQ. Payload maybe XML as string or a DOM element (or an array of such elements as well).
 * @param {Element} payload A payload to be appended [optional]
 * @return An IQ reply packet
 * @type JSJaCIQ
 */
JSJaCIQ.prototype.reply = function(payload) {
  var rIQ = this.clone();
  rIQ.setTo(this.getFrom());
  rIQ.setFrom();
  rIQ.setType('result');
  if (payload) {
    if (typeof payload == 'string')
      rIQ.getChild().appendChild(rIQ.getDoc().loadXML(payload));
    else if (payload.constructor == Array) {
      var node = rIQ.getChild();
      for (var i=0; i<payload.length; i++)
        if(typeof payload[i] == 'string')
          node.appendChild(rIQ.getDoc().loadXML(payload[i]));
        else if (typeof payload[i] == 'object')
          node.appendChild(payload[i]);
    }
    else if (typeof payload == 'object')
      rIQ.getChild().appendChild(payload);
  }
  return rIQ;
};

/**
 * A jabber/XMPP message packet
 * @class Models the XMPP notion of an 'message' packet
 * @extends JSJaCPacket
 */
function JSJaCMessage() {
  /**
   * @ignore
   */
  this.base = JSJaCPacket;
  this.base('message');
}
JSJaCMessage.prototype = new JSJaCPacket;

/**
 * Sets the body of the message
 * @param {String} body Your message to be sent along
 * @return this message
 * @type JSJaCMessage
 */
JSJaCMessage.prototype.setBody = function(body) {
  this._setChildNode("body",body);
  return this;
};
/**
 * Sets the subject of the message
 * @param {String} subject Your subject to be sent along
 * @return this message
 * @type JSJaCMessage
 */
JSJaCMessage.prototype.setSubject = function(subject) {
  this._setChildNode("subject",subject);
  return this;
};
/**
 * Sets the 'tread' attribute for this message. This is used to identify
 * threads in chat conversations
 * @param {String} thread Usually a somewhat random hash.
 * @return this message
 * @type JSJaCMessage
 */
JSJaCMessage.prototype.setThread = function(thread) {
  this._setChildNode("thread", thread);
  return this;
};
/**
 * Gets the 'thread' identifier for this message
 * @return A thread identifier
 * @type String
 */
JSJaCMessage.prototype.getThread = function() {
  return this.getChildVal('thread');
};
/**
 * Gets the body of this message
 * @return The body of this message
 * @type String
 */
JSJaCMessage.prototype.getBody = function() {
  return this.getChildVal('body');
};
/**
 * Gets the subject of this message
 * @return The subject of this message
 * @type String
 */
JSJaCMessage.prototype.getSubject = function() {
  return this.getChildVal('subject')
};


/**
 * Tries to transform a w3c DOM node to JSJaC's internal representation
 * (JSJaCPacket type, one of JSJaCPresence, JSJaCMessage, JSJaCIQ)
 * @param: {Node
 * http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1950641247}
 * node The node to be transformed
 * @return A JSJaCPacket representing the given node. If node's root
 * elemenent is not one of 'message', 'presence' or 'iq',
 * <code>null</code> is being returned.
 * @type JSJaCPacket
 */
JSJaCPacket.wrapNode = function(node) {
  var oPacket = null;

  switch (node.nodeName.toLowerCase()) {
  case 'presence':
      oPacket = new JSJaCPresence();
      break;
  case 'message':
      oPacket = new JSJaCMessage();
      break;
  case 'iq':
      oPacket = new JSJaCIQ();
      break;
  }

  if (oPacket) {
    oPacket.getDoc().replaceChild(oPacket._importNode(node, true),
                                  oPacket.getNode());
  }

  return oPacket;
};



/**
 * an error packet for internal use
 * @private
 * @constructor
 */
function JSJaCError(code,type,condition) {
  var xmldoc = XmlDocument.create("error","jsjac");

  xmldoc.documentElement.setAttribute('code',code);
  xmldoc.documentElement.setAttribute('type',type);
  if (condition)
    xmldoc.documentElement.appendChild(xmldoc.createElement(condition)).
      setAttribute('xmlns','urn:ietf:params:xml:ns:xmpp-stanzas');
  return xmldoc.documentElement;
}



/**
 * Creates a new set of hash keys
 * @class Reflects a set of sha1/md5 hash keys for securing sessions
 * @constructor
 * @param {Function} func The hash function to be used for creating the keys
 * @param {Debugger} oDbg Reference to debugger implementation [optional]
 */									 
function JSJaCKeys(func,oDbg) {
  var seed = Math.random();

  /**
   * @private
   */
  this._k = new Array();
  this._k[0] = seed.toString();
  if (oDbg)
    /**
     * Reference to Debugger
     * @type Debugger
     */
    this.oDbg = oDbg;
  else {
    this.oDbg = {};
    this.oDbg.log = function() {};
  }

  if (func) {
    for (var i=1; i<JSJAC_NKEYS; i++) {
      this._k[i] = func(this._k[i-1]);
      oDbg.log(i+": "+this._k[i],4);
    }
  }

  /**
   * @private
   */
  this._indexAt = JSJAC_NKEYS-1;
  /**
   * Gets next key from stack
   * @return New hash key
   * @type String
   */
  this.getKey = function() {
    return this._k[this._indexAt--];
  };
  /**
   * Indicates whether there's only one key left
   * @return <code>true</code> if there's only one key left, false otherwise
   * @type boolean
   */
  this.lastKey = function() { return (this._indexAt == 0); };
  /**
   * Returns number of overall/initial stack size
   * @return Number of keys created
   * @type int
   */
  this.size = function() { return this._k.length; };

  /**
   * @private
   */
  this._getSuspendVars = function() {
    return ('_k,_indexAt').split(',');
  }
}


/**
 * @fileoverview Contains all things in common for all subtypes of connections
 * supported.
 * @author Stefan Strigler steve@zeank.in-berlin.de
 * @version $Revision$
 */

/**
 * Creates a new Jabber connection (a connection to a jabber server)
 * @class Somewhat abstract base class for jabber connections. Contains all
 * of the code in common for all jabber connections
 * @constructor
 * @param {JSON http://www.json.org/index} oArg JSON with properties: <br>
 * * <code>httpbase</code> the http base address of the service to be used for
 * connecting to jabber<br>
 * * <code>oDbg</code> (optional) a reference to a debugger interface
 */
function JSJaCConnection(oArg) {

  if (oArg && oArg.oDbg && oArg.oDbg.log) {
      /**
       * Reference to debugger interface
       * (needs to implement method <code>log</code>)
       * @type Debugger
       */
    this.oDbg = oArg.oDbg;
  } else {
    this.oDbg = new Object(); // always initialise a debugger
    this.oDbg.log = function() { };
  }

  if (oArg && oArg.timerval)
    this.setPollInterval(oArg.timerval);
  else
    this.setPollInterval(JSJAC_TIMERVAL);

  if (oArg && oArg.httpbase)
      /**
       * @private
       */
    this._httpbase = oArg.httpbase;

  if (oArg &&oArg.allow_plain)
      /**
       * @private
       */
    this.allow_plain = oArg.allow_plain;
  else
    this.allow_plain = JSJAC_ALLOW_PLAIN;

  if (oArg && oArg.cookie_prefix)
      /**
       * @private
       */
    this._cookie_prefix = oArg.cookie_prefix;
  else
    this._cookie_prefix = "";

  /**
   * @private
   */
  this._connected = false;
  /**
   * @private
   */
  this._events = new Array();
  /**
   * @private
   */
  this._keys = null;
  /**
   * @private
   */
  this._ID = 0;
  /**
   * @private
   */
  this._inQ = new Array();
  /**
   * @private
   */
  this._pQueue = new Array();
  /**
   * @private
   */
  this._regIDs = new Array();
  /**
   * @private
   */
  this._req = new Array();
  /**
   * @private
   */
  this._status = 'intialized';
  /**
   * @private
   */
  this._errcnt = 0;
  /**
   * @private
   */
  this._inactivity = JSJAC_INACTIVITY;
  /**
   * @private
   */
  this._sendRawCallbacks = new Array();
}

// Generates an ID
var STANZA_ID = 1;

function genID() {
  return STANZA_ID++;
}

JSJaCConnection.prototype.connect = function(oArg) {
    this._setStatus('connecting');

    this.domain = oArg.domain || 'localhost';
    this.username = oArg.username;
    this.resource = oArg.resource;
    this.pass = oArg.pass;
    this.register = oArg.register;

    this.authhost = oArg.authhost || this.domain;
    this.authtype = oArg.authtype || 'sasl';

    if (oArg.xmllang && oArg.xmllang != '')
        this._xmllang = oArg.xmllang;
    else
        this._xmllang = 'en';

    this.host = oArg.host || this.domain;
    this.port = oArg.port || 5222;
    if (oArg.secure)
        this.secure = 'true';
    else
        this.secure = 'false';

    if (oArg.wait)
        this._wait = oArg.wait;

    this.jid = this.username + '@' + this.domain;
    this.fulljid = this.jid + '/' + this.resource;

    this._rid  = Math.round( 100000.5 + ( ( (900000.49999) - (100000.5) ) * Math.random() ) );

    // setupRequest must be done after rid is created but before first use in reqstr
    var slot = this._getFreeSlot();
    this._req[slot] = this._setupRequest(true);

    var reqstr = this._getInitialRequestString();

    this.oDbg.log(reqstr,4);

    this._req[slot].r.onreadystatechange =
        JSJaC.bind(function() {
            var r = this._req[slot].r;
            if (r.readyState == 4) {
                this.oDbg.log("async recv: "+r.responseText,4);
                this._handleInitialResponse(r); // handle response
            }
        }, this);

    if (typeof(this._req[slot].r.onerror) != 'undefined') {
        this._req[slot].r.onerror =
            JSJaC.bind(function(e) {
                this.oDbg.log('XmlHttpRequest error',1);
                return false;
            }, this);
    }

    this._req[slot].r.send(reqstr);
};

/**
 * Tells whether this connection is connected
 * @return <code>true</code> if this connections is connected,
 * <code>false</code> otherwise
 * @type boolean
 */
JSJaCConnection.prototype.connected = function() { return this._connected; };

/**
 * Disconnects from jabber server and terminates session (if applicable)
 */
JSJaCConnection.prototype.disconnect = function() {
  this._setStatus('disconnecting');
 
  if (!this.connected())
    return;
  this._connected = false;
 
  clearInterval(this._interval);
  clearInterval(this._inQto);
 
  if (this._timeout)
    clearTimeout(this._timeout); // remove timer
 
  var slot = this._getFreeSlot();
  // Intentionally synchronous
  this._req[slot] = this._setupRequest(false);
 
  request = this._getRequestString(false, true);
 
  this.oDbg.log("Disconnecting: " + request,4);
  this._req[slot].r.send(request);
 
  try {
    removeDB('jsjac', 'state');
  } catch (e) {}
 
  this.oDbg.log("Disconnected: "+this._req[slot].r.responseText,2);
  this._handleEvent('ondisconnect');
};

/**
 * Gets current value of polling interval
 * @return Polling interval in milliseconds
 * @type int
 */
JSJaCConnection.prototype.getPollInterval = function() {
  return this._timerval;
};

/**
 * Registers an event handler (callback) for this connection.

 * <p>Note: All of the packet handlers for specific packets (like
 * message_in, presence_in and iq_in) fire only if there's no
 * callback associated with the id.<br>

 * <p>Example:<br/>
 * <code>con.registerHandler('iq', 'query', 'jabber:iq:version', handleIqVersion);</code>


 * @param {String} event One of

 * <ul>
 * <li>onConnect - connection has been established and authenticated</li>
 * <li>onDisconnect - connection has been disconnected</li>
 * <li>onResume - connection has been resumed</li>

 * <li>onStatusChanged - connection status has changed, current
 * status as being passed argument to handler. See {@link #status}.</li>

 * <li>onError - an error has occured, error node is supplied as
 * argument, like this:<br><code>&lt;error code='404' type='cancel'&gt;<br>
 * &lt;item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/&gt;<br>
 * &lt;/error&gt;</code></li>

 * <li>packet_in - a packet has been received (argument: the
 * packet)</li>

 * <li>packet_out - a packet is to be sent(argument: the
 * packet)</li>

 * <li>message_in | message - a message has been received (argument:
 * the packet)</li>

 * <li>message_out - a message packet is to be sent (argument: the
 * packet)</li>

 * <li>presence_in | presence - a presence has been received
 * (argument: the packet)</li>

 * <li>presence_out - a presence packet is to be sent (argument: the
 * packet)</li>

 * <li>iq_in | iq - an iq has been received (argument: the packet)</li>
 * <li>iq_out - an iq is to be sent (argument: the packet)</li>
 * </ul>

 * @param {String} childName A childnode's name that must occur within a
 * retrieved packet [optional]

 * @param {String} childNS A childnode's namespace that must occure within
 * a retrieved packet (works only if childName is given) [optional]

 * @param {String} type The type of the packet to handle (works only if childName and chidNS are given (both may be set to '*' in order to get skipped) [optional]

 * @param {Function} handler The handler to be called when event occurs. If your handler returns 'true' it cancels bubbling of the event. No other registered handlers for this event will be fired.
 */
JSJaCConnection.prototype.registerHandler = function(event) {
  event = event.toLowerCase(); // don't be case-sensitive here
  var eArg = {handler: arguments[arguments.length-1],
              childName: '*',
              childNS: '*',
              type: '*'};
  if (arguments.length > 2)
    eArg.childName = arguments[1];
  if (arguments.length > 3)
    eArg.childNS = arguments[2];
  if (arguments.length > 4)
    eArg.type = arguments[3];
  if (!this._events[event])
    this._events[event] = new Array(eArg);
  else
    this._events[event] = this._events[event].concat(eArg);

  // sort events in order how specific they match criterias thus using
  // wildcard patterns puts them back in queue when it comes to
  // bubbling the event
  this._events[event] =
  this._events[event].sort(function(a,b) {
    var aRank = 0;
    var bRank = 0;
    with (a) {
      if (type == '*')
        aRank++;
      if (childNS == '*')
        aRank++;
      if (childName == '*')
        aRank++;
    }
    with (b) {
      if (type == '*')
        bRank++;
      if (childNS == '*')
        bRank++;
      if (childName == '*')
        bRank++;
    }
    if (aRank > bRank)
      return 1;
    if (aRank < bRank)
      return -1;
    return 0;
  });
  this.oDbg.log("registered handler for event '"+event+"'",2);
};

JSJaCConnection.prototype.unregisterHandler = function(event,handler) {
  event = event.toLowerCase(); // don't be case-sensitive here

  if (!this._events[event])
    return;

  var arr = this._events[event], res = new Array();
  for (var i=0; i<arr.length; i++)
    if (arr[i].handler != handler)
      res.push(arr[i]);

  if (arr.length != res.length) {
    this._events[event] = res;
    this.oDbg.log("unregistered handler for event '"+event+"'",2);
  }
};

/**
 * Register for iq packets of type 'get'.
 * @param {String} childName A childnode's name that must occur within a
 * retrieved packet

 * @param {String} childNS A childnode's namespace that must occure within
 * a retrieved packet (works only if childName is given)

 * @param {Function} handler The handler to be called when event occurs. If your handler returns 'true' it cancels bubbling of the event. No other registered handlers for this event will be fired.
 */
JSJaCConnection.prototype.registerIQGet = function(childName, childNS, handler) {
  this.registerHandler('iq', childName, childNS, 'get', handler);
};

/**
 * Register for iq packets of type 'set'.
 * @param {String} childName A childnode's name that must occur within a
 * retrieved packet

 * @param {String} childNS A childnode's namespace that must occure within
 * a retrieved packet (works only if childName is given)

 * @param {Function} handler The handler to be called when event occurs. If your handler returns 'true' it cancels bubbling of the event. No other registered handlers for this event will be fired.
 */
JSJaCConnection.prototype.registerIQSet = function(childName, childNS, handler) {
  this.registerHandler('iq', childName, childNS, 'set', handler);
};

/**
 * Resumes this connection from saved state (cookie)
 * @return Whether resume was successful
 * @type boolean
 */
JSJaCConnection.prototype.resume = function() {
  try {
    var json = getDB('jsjac', 'state');
    this.oDbg.log('read cookie: '+json,2);
    removeDB('jsjac', 'state');

    return this.resumeFromData(JSJaCJSON.parse(json));
  } catch (e) {}
  return false; // sth went wrong
};

/**
 * Resumes BOSH connection from data
 * @param {Object} serialized jsjac state information
 * @return Whether resume was successful
 * @type boolean
 */
JSJaCConnection.prototype.resumeFromData = function(data) {
  try {
    this._setStatus('resuming');

    for (var i in data)
      if (data.hasOwnProperty(i))
        this[i] = data[i];

    // copy keys - not being very generic here :-/
    if (this._keys) {
      this._keys2 = new JSJaCKeys();
      var u = this._keys2._getSuspendVars();
      for (var i=0; i<u.length; i++)
        this._keys2[u[i]] = this._keys[u[i]];
      this._keys = this._keys2;
    }

    if (this._connected) {
      // don't poll too fast!
      this._handleEvent('onresume');
      setTimeout(JSJaC.bind(this._resume, this),this.getPollInterval());
      this._interval = setInterval(JSJaC.bind(this._checkQueue, this),
				   JSJAC_CHECKQUEUEINTERVAL);
      this._inQto = setInterval(JSJaC.bind(this._checkInQ, this),
				JSJAC_CHECKINQUEUEINTERVAL);
    }

    return (this._connected === true);
  } catch (e) {
    if (e.message)
      this.oDbg.log("Resume failed: "+e.message, 1);
    else
      this.oDbg.log("Resume failed: "+e, 1);
    return false;
  }
};

/**
 * Sends a JSJaCPacket
 * @param {JSJaCPacket} packet  The packet to send
 * @param {Function}    cb      The callback to be called if there's a reply
 * to this packet (identified by id) [optional]
 * @param {Object}      arg     Arguments passed to the callback
 * (additionally to the packet received) [optional]
 * @return 'true' if sending was successfull, 'false' otherwise
 * @type boolean
 */
JSJaCConnection.prototype.send = function(packet,cb,arg) {
  if (!packet || !packet.pType) {
    this.oDbg.log("no packet: "+packet, 1);
    return false;
  }

  if (!this.connected())
    return false;

  // generate an ID for the packet
  if (!packet.getID())
    packet.setID(genID());

  // packet xml:lang
  if (!packet.getXMLLang())
    packet.setXMLLang(XML_LANG);

  // remember id for response if callback present
  if (cb)
    this._registerPID(packet.getID(),cb,arg);

  try {
    this._handleEvent(packet.pType()+'_out', packet);
    this._handleEvent("packet_out", packet);
    this._pQueue = this._pQueue.concat(packet.xml());
  } catch (e) {
    this.oDbg.log(e.toString(),1);
    return false;
  }

  return true;
};

/**
 * Sends an IQ packet. Has default handlers for each reply type.
 * Those maybe overriden by passing an appropriate handler.
 * @param {JSJaCIQPacket} iq - the iq packet to send
 * @param {Object} handlers - object with properties 'error_handler',
 *                            'result_handler' and 'default_handler'
 *                            with appropriate functions
 * @param {Object} arg - argument to handlers
 * @return 'true' if sending was successfull, 'false' otherwise
 * @type boolean
 */
JSJaCConnection.prototype.sendIQ = function(iq, handlers, arg) {
  if (!iq || iq.pType() != 'iq') {
    return false;
  }

  handlers = handlers || {};
    var error_handler = handlers.error_handler || JSJaC.bind(function(aIq) {
        this.oDbg.log(aIq.xml(), 1);
    }, this);

    var result_handler = handlers.result_handler ||  JSJaC.bind(function(aIq) {
        this.oDbg.log(aIq.xml(), 2);
    }, this);

  var iqHandler = function(aIq, arg) {
    switch (aIq.getType()) {
      case 'error':
      error_handler(aIq);
      break;
      case 'result':
      result_handler(aIq, arg);
      break;
    }
  };
  return this.send(iq, iqHandler, arg);
};

/**
 * Sets polling interval for this connection
 * @param {int} millisecs Milliseconds to set timer to
 * @return effective interval this connection has been set to
 * @type int
 */
JSJaCConnection.prototype.setPollInterval = function(timerval) {
  if (timerval && !isNaN(timerval))
    this._timerval = timerval;
  return this._timerval;
};

/**
 * Returns current status of this connection
 * @return String to denote current state. One of
 * <ul>
 * <li>'initializing' ... well
 * <li>'connecting' if connect() was called
 * <li>'resuming' if resume() was called
 * <li>'processing' if it's about to operate as normal
 * <li>'onerror_fallback' if there was an error with the request object
 * <li>'protoerror_fallback' if there was an error at the http binding protocol flow (most likely that's where you interested in)
 * <li>'internal_server_error' in case of an internal server error
 * <li>'suspending' if suspend() is being called
 * <li>'aborted' if abort() was called
 * <li>'disconnecting' if disconnect() has been called
 * </ul>
 * @type String
 */
JSJaCConnection.prototype.status = function() { return this._status; };

/**
 * Suspends this connection (saving state for later resume)
 * Saves state to cookie
 * @return Whether suspend (saving to cookie) was successful
 * @type boolean
 */
JSJaCConnection.prototype.suspend = function(has_pause) {
  var data = this.suspendToData(has_pause);
  
  try {
    var c = setDB('jsjac', 'state', JSJaCJSON.toString(data));
    return c;
  } catch (e) {
    this.oDbg.log("Failed creating cookie '"+this._cookie_prefix+
                  "JSJaC_State': "+e.message,1);
  }
  return false;
};

/**
 * Suspend connection and return serialized JSJaC connection state
 * @return JSJaC connection state object
 * @type Object
 */
JSJaCConnection.prototype.suspendToData = function(has_pause) {
  
  // remove timers
  if(has_pause) {
    clearTimeout(this._timeout);
    clearInterval(this._interval);
    clearInterval(this._inQto);

    this._suspend();
  }
  
  var u = ('_connected,_keys,_ID,_inQ,_pQueue,_regIDs,_errcnt,_inactivity,domain,username,resource,jid,fulljid,_sid,_httpbase,_timerval,_is_polling').split(',');
  u = u.concat(this._getSuspendVars());
  var s = new Object();

  for (var i=0; i<u.length; i++) {
    if (!this[u[i]]) continue; // hu? skip these!
    if (this[u[i]]._getSuspendVars) {
      var uo = this[u[i]]._getSuspendVars();
      var o = new Object();
      for (var j=0; j<uo.length; j++)
        o[uo[j]] = this[u[i]][uo[j]];
    } else
      var o = this[u[i]];

    s[u[i]] = o;
  }
  
  if(has_pause) {
    this._connected = false;
    this._setStatus('suspending');
  }
  
  return s;
};

/**
 * @private
 */
JSJaCConnection.prototype._abort = function() {
  clearTimeout(this._timeout); // remove timer

  clearInterval(this._inQto);
  clearInterval(this._interval);

  this._connected = false;

  this._setStatus('aborted');

  this.oDbg.log("Disconnected.",1);
  this._handleEvent('ondisconnect');
  this._handleEvent('onerror',
                    JSJaCError('500','cancel','service-unavailable'));
};

/**
 * @private
 */
JSJaCConnection.prototype._checkInQ = function() {
  for (var i=0; i<this._inQ.length && i<10; i++) {
    var item = this._inQ[0];
    this._inQ = this._inQ.slice(1,this._inQ.length);
    var packet = JSJaCPacket.wrapNode(item);

    if (!packet)
      return;

    this._handleEvent("packet_in", packet);

    if (packet.pType && !this._handlePID(packet)) {
      this._handleEvent(packet.pType()+'_in',packet);
      this._handleEvent(packet.pType(),packet);
    }
  }
};

/**
 * @private
 */
JSJaCConnection.prototype._checkQueue = function() {
  if (this._pQueue.length != 0)
    this._process();
  return true;
};

/**
 * @private
 */
JSJaCConnection.prototype._doAuth = function() {
  if (this.has_sasl && this.authtype == 'nonsasl')
    this.oDbg.log("Warning: SASL present but not used", 1);

  if (!this._doSASLAuth() &&
      !this._doLegacyAuth()) {
    this.oDbg.log("Auth failed for authtype "+this.authtype,1);
    this.disconnect();
    return false;
  }
  return true;
};

/**
 * @private
 */
JSJaCConnection.prototype._doInBandReg = function() {
  if (this.authtype == 'saslanon' || this.authtype == 'anonymous')
    return; // bullshit - no need to register if anonymous

  /* ***
   * In-Band Registration see JEP-0077
   */

  var iq = new JSJaCIQ();
  iq.setType('set');
  iq.setID('reg1');
  iq.appendNode("query", {xmlns: "jabber:iq:register"},
                [["username", this.username],
                 ["password", this.pass]]);

  this.send(iq,this._doInBandRegDone);
};

/**
 * @private
 */
JSJaCConnection.prototype._doInBandRegDone = function(iq) {
  if (iq && iq.getType() == 'error') { // we failed to register
    this.oDbg.log("registration failed for "+this.username,0);
    this._handleEvent('onerror',iq.getChild('error'));
    return;
  }

  this.oDbg.log(this.username + " registered succesfully",0);

  this._doAuth();
};

/**
 * @private
 */
JSJaCConnection.prototype._doLegacyAuth = function() {
  if (this.authtype != 'nonsasl' && this.authtype != 'anonymous')
    return false;

  /* ***
   * Non-SASL Authentication as described in JEP-0078
   */
  var iq = new JSJaCIQ();
  iq.setIQ(null,'get','auth1');
  iq.appendNode('query', {xmlns: 'jabber:iq:auth'},
                [['username', this.username]]);

  this.send(iq,this._doLegacyAuth2);
  return true;
};

/**
 * @private
 */
JSJaCConnection.prototype._doLegacyAuth2 = function(iq) {
  if (!iq || iq.getType() != 'result') {
    if (iq && iq.getType() == 'error')
      this._handleEvent('onerror',iq.getChild('error'));
    this.disconnect();
    return;
  }

  var use_digest = (iq.getChild('digest') != null);

  /* ***
   * Send authentication
   */
  var iq = new JSJaCIQ();
  iq.setIQ(null,'set','auth2');

  query = iq.appendNode('query', {xmlns: 'jabber:iq:auth'},
                        [['username', this.username],
                         ['resource', this.resource]]);

  if (use_digest) { // digest login
    query.appendChild(iq.buildNode('digest', {xmlns: 'jabber:iq:auth'},
                                   hex_sha1(this.streamid + this.pass)));
  } else if (this.allow_plain) { // use plaintext auth
    query.appendChild(iq.buildNode('password', {xmlns: 'jabber:iq:auth'},
                                   this.pass));
  } else {
    this.oDbg.log("no valid login mechanism found",1);
    this.disconnect();
    return false;
  }

  this.send(iq,this._doLegacyAuthDone);
};

/**
 * @private
 */
JSJaCConnection.prototype._doLegacyAuthDone = function(iq) {
  if (iq.getType() != 'result') { // auth' failed
    if (iq.getType() == 'error')
      this._handleEvent('onerror',iq.getChild('error'));
    this.disconnect();
  } else
    this._handleEvent('onconnect');
};

/**
 * @private
 */
JSJaCConnection.prototype._doSASLAuth = function() {
  if (this.authtype == 'nonsasl' || this.authtype == 'anonymous')
    return false;

  if (this.authtype == 'saslanon') {
    if (this.mechs['ANONYMOUS']) {
      this.oDbg.log("SASL using mechanism 'ANONYMOUS'",2);
      return this._sendRaw("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='ANONYMOUS'/>",
                           this._doSASLAuthDone);
    }
    this.oDbg.log("SASL ANONYMOUS requested but not supported",1);
  } else {
    if (this.mechs['DIGEST-MD5']) {
      this.oDbg.log("SASL using mechanism 'DIGEST-MD5'",2);
      return this._sendRaw("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='DIGEST-MD5'/>",
                           this._doSASLAuthDigestMd5S1);
    } else if (this.allow_plain && this.mechs['PLAIN']) {
      this.oDbg.log("SASL using mechanism 'PLAIN'",2);
      var authStr = this.username+'@'+
      this.domain+String.fromCharCode(0)+
      this.username+String.fromCharCode(0)+
      this.pass;
      this.oDbg.log("authenticating with '"+authStr+"'",2);
      authStr = b64encode(authStr);
      return this._sendRaw("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>"+authStr+"</auth>",
                           this._doSASLAuthDone);
    }
    this.oDbg.log("No SASL mechanism applied",1);
    this.authtype = 'nonsasl'; // fallback
  }
  return false;
};

/**
 * @private
 */
JSJaCConnection.prototype._doSASLAuthDigestMd5S1 = function(el) {
  if (el.nodeName != "challenge") {
    this.oDbg.log("challenge missing",1);
    this._handleEvent('onerror',JSJaCError('401','auth','not-authorized'));
    this.disconnect();
  } else {
    var challenge = b64decode(el.firstChild.nodeValue);
    this.oDbg.log("got challenge: "+challenge,2);
    this._nonce = challenge.substring(challenge.indexOf("nonce=")+7);
    this._nonce = this._nonce.substring(0,this._nonce.indexOf("\""));
    this.oDbg.log("nonce: "+this._nonce,2);
    if (this._nonce == '' || this._nonce.indexOf('\"') != -1) {
      this.oDbg.log("nonce not valid, aborting",1);
      this.disconnect();
      return;
    }

    this._digest_uri = "xmpp/";
    //     if (typeof(this.host) != 'undefined' && this.host != '') {
    //       this._digest-uri += this.host;
    //       if (typeof(this.port) != 'undefined' && this.port)
    //         this._digest-uri += ":" + this.port;
    //       this._digest-uri += '/';
    //     }
    this._digest_uri += this.domain;

    this._cnonce = cnonce(14);

    this._nc = '00000001';

    var A1 = str_md5(this.username+':'+this.domain+':'+this.pass)+
    ':'+this._nonce+':'+this._cnonce;

    var A2 = 'AUTHENTICATE:'+this._digest_uri;

    var response = hex_md5(hex_md5(A1)+':'+this._nonce+':'+this._nc+':'+
                           this._cnonce+':auth:'+hex_md5(A2));

    var rPlain = 'username="'+this.username+'",realm="'+this.domain+
    '",nonce="'+this._nonce+'",cnonce="'+this._cnonce+'",nc="'+this._nc+
    '",qop=auth,digest-uri="'+this._digest_uri+'",response="'+response+
    '",charset="utf-8"';

    this.oDbg.log("response: "+rPlain,2);

    this._sendRaw("<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>"+
                  b64encode(rPlain)+"</response>",
                  this._doSASLAuthDigestMd5S2);
  }
};

/**
 * @private
 */
JSJaCConnection.prototype._doSASLAuthDigestMd5S2 = function(el) {
  if (el.nodeName == 'failure') {
    if (el.xml)
      this.oDbg.log("auth error: "+el.xml,1);
    else
      this.oDbg.log("auth error",1);
    this._handleEvent('onerror',JSJaCError('401','auth','not-authorized'));
    this.disconnect();
    return;
  }

  var response = b64decode(el.firstChild.nodeValue);
  this.oDbg.log("response: "+response,2);

  var rspauth = response.substring(response.indexOf("rspauth=")+8);
  this.oDbg.log("rspauth: "+rspauth,2);

  var A1 = str_md5(this.username+':'+this.domain+':'+this.pass)+
  ':'+this._nonce+':'+this._cnonce;

  var A2 = ':'+this._digest_uri;

  var rsptest = hex_md5(hex_md5(A1)+':'+this._nonce+':'+this._nc+':'+
                        this._cnonce+':auth:'+hex_md5(A2));
  this.oDbg.log("rsptest: "+rsptest,2);

  if (rsptest != rspauth) {
    this.oDbg.log("SASL Digest-MD5: server repsonse with wrong rspauth",1);
    this.disconnect();
    return;
  }

    if (el.nodeName == 'success') {
        this._reInitStream(JSJaC.bind(this._doStreamBind, this));
    } else { // some extra turn
        this._sendRaw("<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>",
                      this._doSASLAuthDone);
    }
};

/**
 * @private
 */
JSJaCConnection.prototype._doSASLAuthDone = function (el) {
    if (el.nodeName != 'success') {
        this.oDbg.log("auth failed",1);
        this._handleEvent('onerror',JSJaCError('401','auth','not-authorized'));
        this.disconnect();
    } else {
        this._reInitStream(JSJaC.bind(this._doStreamBind, this));
    }
};

/**
 * @private
 */
JSJaCConnection.prototype._doStreamBind = function() {
  var iq = new JSJaCIQ();
  iq.setIQ(null,'set','bind_1');
  iq.appendNode("bind", {xmlns: "urn:ietf:params:xml:ns:xmpp-bind"},
                [["resource", this.resource]]);
  this.oDbg.log(iq.xml());
  this.send(iq,this._doXMPPSess);
};

/**
 * @private
 */
JSJaCConnection.prototype._doXMPPSess = function(iq) {
  if (iq.getType() != 'result' || iq.getType() == 'error') { // failed
    this.disconnect();
    if (iq.getType() == 'error')
      this._handleEvent('onerror',iq.getChild('error'));
    return;
  }

  this.fulljid = iq.getChildVal("jid");
  this.jid = this.fulljid.substring(0,this.fulljid.lastIndexOf('/'));

  iq = new JSJaCIQ();
  iq.setIQ(null,'set','sess_1');
  iq.appendNode("session", {xmlns: "urn:ietf:params:xml:ns:xmpp-session"},
                []);
  this.oDbg.log(iq.xml());
  this.send(iq,this._doXMPPSessDone);
};

/**
 * @private
 */
JSJaCConnection.prototype._doXMPPSessDone = function(iq) {
  if (iq.getType() != 'result' || iq.getType() == 'error') { // failed
    this.disconnect();
    if (iq.getType() == 'error')
      this._handleEvent('onerror',iq.getChild('error'));
    return;
  } else
    this._handleEvent('onconnect');
};

/**
 * @private
 */
JSJaCConnection.prototype._handleEvent = function(event,arg) {
  event = event.toLowerCase(); // don't be case-sensitive here
  this.oDbg.log("incoming event '"+event+"'",3);
  if (!this._events[event])
    return;
  this.oDbg.log("handling event '"+event+"'",2);
  for (var i=0;i<this._events[event].length; i++) {
    var aEvent = this._events[event][i];
    if (typeof aEvent.handler == 'function') {
      try {
        if (arg) {
          if (arg.pType) { // it's a packet
            if ((!arg.getNode().hasChildNodes() && aEvent.childName != '*') ||
				(arg.getNode().hasChildNodes() &&
				 !arg.getChild(aEvent.childName, aEvent.childNS)))
              continue;
            if (aEvent.type != '*' &&
                arg.getType() != aEvent.type)
              continue;
            this.oDbg.log(aEvent.childName+"/"+aEvent.childNS+"/"+aEvent.type+" => match for handler "+aEvent.handler,3);
          }
          if (aEvent.handler(arg)) {
            // handled!
            break;
          }
        }
        else
          if (aEvent.handler()) {
            // handled!
            break;
          }
      } catch (e) {

        if (e.fileName&&e.lineNumber) {
            this.oDbg.log(aEvent.handler+"\n>>>"+e.name+": "+ e.message+' in '+e.fileName+' line '+e.lineNumber,1);
        } else {
            this.oDbg.log(aEvent.handler+"\n>>>"+e.name+": "+ e.message,1);
        }

      }
    }
  }
};

/**
 * @private
 */
JSJaCConnection.prototype._handlePID = function(aJSJaCPacket) {
  if (!aJSJaCPacket.getID())
    return false;
  for (var i in this._regIDs) {
    if (this._regIDs.hasOwnProperty(i) &&
        this._regIDs[i] && i == aJSJaCPacket.getID()) {
      var pID = aJSJaCPacket.getID();
      this.oDbg.log("handling "+pID,3);
      try {
        if (this._regIDs[i].cb.call(this, aJSJaCPacket, this._regIDs[i].arg) === false) {
          // don't unregister
          return false;
        } else {
          this._unregisterPID(pID);
          return true;
        }
      } catch (e) {
        // broken handler?
        this.oDbg.log(e.name+": "+ e.message, 1);
        this._unregisterPID(pID);
        return true;
      }
    }
  }
  return false;
};

/**
 * @private
 */
JSJaCConnection.prototype._handleResponse = function(req) {
  var rootEl = this._parseResponse(req);

  if (!rootEl)
    return;

  for (var i=0; i<rootEl.childNodes.length; i++) {
    if (this._sendRawCallbacks.length) {
      var cb = this._sendRawCallbacks[0];
      this._sendRawCallbacks = this._sendRawCallbacks.slice(1, this._sendRawCallbacks.length);
      cb.fn.call(this, rootEl.childNodes.item(i), cb.arg);
      continue;
    }
    this._inQ = this._inQ.concat(rootEl.childNodes.item(i));
  }
};

/**
 * @private
 */
JSJaCConnection.prototype._parseStreamFeatures = function(doc) {
    if (!doc) {
        this.oDbg.log("nothing to parse ... aborting",1);
        return false;
    }

    var errorTag;
    if (doc.getElementsByTagNameNS) {
        errorTag = doc.getElementsByTagNameNS("http://etherx.jabber.org/streams", "error").item(0);
    } else {
        var errors = doc.getElementsByTagName("error");
        for (var i=0; i<errors.length; i++)
            if (errors.item(i).namespaceURI == "http://etherx.jabber.org/streams" ||
                errors.item(i).getAttribute('xmlns') == "http://etherx.jabber.org/streams") {
                errorTag = errors.item(i);
                break;
            }
    }

    if (errorTag) {
        this._setStatus("internal_server_error");
        clearTimeout(this._timeout); // remove timer
        clearInterval(this._interval);
        clearInterval(this._inQto);
        this._handleEvent('onerror',JSJaCError('503','cancel','session-terminate'));
        this._connected = false;
        this.oDbg.log("Disconnected.",1);
        this._handleEvent('ondisconnect');
        return false;
    }
    
    this.mechs = new Object();
    var lMec1 = doc.getElementsByTagName("mechanisms");
    this.has_sasl = false;
    for (var i=0; i<lMec1.length; i++)
        if (lMec1.item(i).getAttribute("xmlns") ==
            "urn:ietf:params:xml:ns:xmpp-sasl") {
            this.has_sasl=true;
            var lMec2 = lMec1.item(i).getElementsByTagName("mechanism");
            for (var j=0; j<lMec2.length; j++)
                this.mechs[lMec2.item(j).firstChild.nodeValue] = true;
            break;
        }
    if (this.has_sasl)
        this.oDbg.log("SASL detected",2);
    else {
        this.oDbg.log("No support for SASL detected",2);
        return false;
    }
    
    // Get the server CAPS (if available)
    this.server_caps=null;
    var sCaps = doc.getElementsByTagName("c");
    for (var i=0; i<sCaps.length; i++) {
      var c_sCaps=sCaps.item(i);
      var x_sCaps=c_sCaps.getAttribute("xmlns");
      var v_sCaps=c_sCaps.getAttribute("ver");
      
      if ((x_sCaps == NS_CAPS) && v_sCaps) {
        this.server_caps=v_sCaps;
        break;
      }
    }
    
    return true;
};

/**
 * @private
 */
JSJaCConnection.prototype._process = function(timerval) {
  if (!this.connected()) {
    this.oDbg.log("Connection lost ...",1);
    if (this._interval)
      clearInterval(this._interval);
    return;
  }

  this.setPollInterval(timerval);

  if (this._timeout)
    clearTimeout(this._timeout);

  var slot = this._getFreeSlot();

  if (slot < 0)
    return;

  if (typeof(this._req[slot]) != 'undefined' &&
      typeof(this._req[slot].r) != 'undefined' &&
      this._req[slot].r.readyState != 4) {
    this.oDbg.log("Slot "+slot+" is not ready");
    return;
  }

  if (!this.isPolling() && this._pQueue.length == 0 &&
      this._req[(slot+1)%2] && this._req[(slot+1)%2].r.readyState != 4) {
    this.oDbg.log("all slots busy, standby ...", 2);
    return;
  }

  if (!this.isPolling())
    this.oDbg.log("Found working slot at "+slot,2);

  this._req[slot] = this._setupRequest(true);

  /* setup onload handler for async send */
  this._req[slot].r.onreadystatechange =
  JSJaC.bind(function() {
               if (this._req[slot].r.readyState == 4) {
                 this._setStatus('processing');
                 this.oDbg.log("async recv: "+this._req[slot].r.responseText,4);
                 this._handleResponse(this._req[slot]);

                 if (!this.connected())
                   return;

                 // schedule next tick
                 if (this._pQueue.length) {
                   this._timeout = setTimeout(JSJaC.bind(this._process, this),100);
                 } else {
                   this.oDbg.log("scheduling next poll in "+this.getPollInterval()+
                                 " msec", 4);
                   this._timeout = setTimeout(JSJaC.bind(this._process, this),this.getPollInterval());
                 }
               }
             }, this);

  try {
    this._req[slot].r.onerror =
      JSJaC.bind(function() {
                   if (!this.connected())
                     return;
                   this._errcnt++;
                   this.oDbg.log('XmlHttpRequest error ('+this._errcnt+')',1);
                   if (this._errcnt > JSJAC_ERR_COUNT) {
                     // abort
                     this._abort();
                     return false;
                   }

                   this._setStatus('onerror_fallback');

                   // schedule next tick
                   setTimeout(JSJaC.bind(this._resume, this),this.getPollInterval());
                   return false;
                 }, this);
  } catch(e) { } // well ... no onerror property available, maybe we
  // can catch the error somewhere else ...

  var reqstr = this._getRequestString();

  if (typeof(this._rid) != 'undefined') // remember request id if any
    this._req[slot].rid = this._rid;

  this.oDbg.log("sending: " + reqstr,4);
  this._req[slot].r.send(reqstr);
};

/**
 * @private
 */
JSJaCConnection.prototype._registerPID = function(pID,cb,arg) {
  if (!pID || !cb)
    return false;
  this._regIDs[pID] = new Object();
  this._regIDs[pID].cb = cb;
  if (arg)
    this._regIDs[pID].arg = arg;
  this.oDbg.log("registered "+pID,3);
  return true;
};

/**
 * partial function binding sendEmpty to callback
 * @private
 */
JSJaCConnection.prototype._prepSendEmpty = function(cb, ctx) {
    return function() {
        ctx._sendEmpty(JSJaC.bind(cb, ctx));
    };
};

/**
 * send empty request
 * waiting for stream id to be able to proceed with authentication
 * @private
 */
JSJaCConnection.prototype._sendEmpty = function(cb) {
  var slot = this._getFreeSlot();
  this._req[slot] = this._setupRequest(true);

  this._req[slot].r.onreadystatechange =
  JSJaC.bind(function() {
               if (this._req[slot].r.readyState == 4) {
                 this.oDbg.log("async recv: "+this._req[slot].r.responseText,4);
                   cb(this._req[slot].r); // handle response
               }
             },this);

  if (typeof(this._req[slot].r.onerror) != 'undefined') {
    this._req[slot].r.onerror =
      JSJaC.bind(function(e) {
                   this.oDbg.log('XmlHttpRequest error',1);
                   return false;
                 }, this);
  }

  var reqstr = this._getRequestString();
  this.oDbg.log("sending: " + reqstr,4);
  this._req[slot].r.send(reqstr);
};

/**
 * @private
 */
JSJaCConnection.prototype._sendRaw = function(xml,cb,arg) {
  if (cb)
    this._sendRawCallbacks.push({fn: cb, arg: arg});

  this._pQueue.push(xml);
  this._process();

  return true;
};

/**
 * @private
 */
JSJaCConnection.prototype._setStatus = function(status) {
  if (!status || status == '')
    return;
  if (status != this._status) { // status changed!
    this._status = status;
    this._handleEvent('onstatuschanged', status);
    this._handleEvent('status_changed', status);
  }
};

/**
 * @private
 */
JSJaCConnection.prototype._unregisterPID = function(pID) {
  if (!this._regIDs[pID])
    return false;
  this._regIDs[pID] = null;
  this.oDbg.log("unregistered "+pID,3);
  return true;
};


/**
 * @fileoverview All stuff related to HTTP Binding
 * @author Stefan Strigler steve@zeank.in-berlin.de
 * @version $Revision$
 */

/**
 * Instantiates an HTTP Binding session
 * @class Implementation of {@link
 * http://www.xmpp.org/extensions/xep-0206.html XMPP Over BOSH}
 * formerly known as HTTP Binding.
 * @extends JSJaCConnection
 * @constructor
 */
function JSJaCHttpBindingConnection(oArg) {
  /**
   * @ignore
   */
  this.base = JSJaCConnection;
  this.base(oArg);

  // member vars
  /**
   * @private
   */
  this._hold = JSJACHBC_MAX_HOLD;
  /**
   * @private
   */
  this._inactivity = 0;
  /**
   * @private
   */
  this._last_requests = new Object(); // 'hash' storing hold+1 last requests
  /**
   * @private
   */
  this._last_rid = 0;                 // I know what you did last summer
  /**
   * @private
   */
  this._min_polling = 0;

  /**
   * @private
   */
  this._pause = 0;
  /**
   * @private
   */
  this._wait = JSJACHBC_MAX_WAIT;
}
JSJaCHttpBindingConnection.prototype = new JSJaCConnection();

/**
 * Inherit an instantiated HTTP Binding session
 */
JSJaCHttpBindingConnection.prototype.inherit = function(oArg) {
  if (oArg.jid) {
    var oJid = new JSJaCJID(oArg.jid);
    this.domain = oJid.getDomain();
    this.username = oJid.getNode();
    this.resource = oJid.getResource();
  } else {
    this.domain = oArg.domain || 'localhost';
    this.username = oArg.username;
    this.resource = oArg.resource;
  }
  this._sid = oArg.sid;
  this._rid = oArg.rid;
  this._min_polling = oArg.polling;
  this._inactivity = oArg.inactivity;
  this._setHold(oArg.requests-1);
  this.setPollInterval(this._timerval);
  if (oArg.wait)
    this._wait = oArg.wait; // for whatever reason

  this._connected = true;

  this._handleEvent('onconnect');

  this._interval= setInterval(JSJaC.bind(this._checkQueue, this),
                              JSJAC_CHECKQUEUEINTERVAL);
  this._inQto = setInterval(JSJaC.bind(this._checkInQ, this),
                            JSJAC_CHECKINQUEUEINTERVAL);
  this._timeout = setTimeout(JSJaC.bind(this._process, this),
                             this.getPollInterval());
};

/**
 * Sets poll interval
 * @param {int} timerval the interval in seconds
 */
JSJaCHttpBindingConnection.prototype.setPollInterval = function(timerval) {
  if (timerval && !isNaN(timerval)) {
    if (!this.isPolling())
      this._timerval = 100;
    else if (this._min_polling && timerval < this._min_polling*1000)
      this._timerval = this._min_polling*1000;
    else if (this._inactivity && timerval > this._inactivity*1000)
      this._timerval = this._inactivity*1000;
    else
      this._timerval = timerval;
  }
  return this._timerval;
};

/**
 * whether this session is in polling mode
 * @type boolean
 */
JSJaCHttpBindingConnection.prototype.isPolling = function() { return (this._hold == 0) };

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getFreeSlot = function() {
  for (var i=0; i<this._hold+1; i++)
    if (typeof(this._req[i]) == 'undefined' || typeof(this._req[i].r) == 'undefined' || this._req[i].r.readyState == 4)
      return i;
  return -1; // nothing found
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getHold = function() { return this._hold; };

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getRequestString = function(raw, last) {
  raw = raw || '';
  var reqstr = '';

  // check if we're repeating a request

  if (this._rid <= this._last_rid && typeof(this._last_requests[this._rid]) != 'undefined') // repeat!
    reqstr = this._last_requests[this._rid].xml;
  else { // grab from queue
    var xml = '';
    while (this._pQueue.length) {
      var curNode = this._pQueue[0];
      xml += curNode;
      this._pQueue = this._pQueue.slice(1,this._pQueue.length);
    }

    reqstr = "<body xml:lang='"+XML_LANG+"' rid='"+this._rid+"' sid='"+this._sid+"' xmlns='http://jabber.org/protocol/httpbind' ";
    if (JSJAC_HAVEKEYS) {
      reqstr += "key='"+this._keys.getKey()+"' ";
      if (this._keys.lastKey()) {
        this._keys = new JSJaCKeys(hex_sha1,this.oDbg);
        reqstr += "newkey='"+this._keys.getKey()+"' ";
      }
    }
    if (last)
      reqstr += "type='terminate'";
    else if (this._reinit) {
      if (JSJACHBC_USE_BOSH_VER)
        reqstr += "xmpp:restart='true' xmlns:xmpp='urn:xmpp:xbosh' to='"+this.domain+"'";
      this._reinit = false;
    }

    if (xml != '' || raw != '') {
      reqstr += ">" + raw + xml + "</body>";
    } else {
      reqstr += "/>";
    }

    this._last_requests[this._rid] = new Object();
    this._last_requests[this._rid].xml = reqstr;
    this._last_rid = this._rid;

    for (var i in this._last_requests)
      if (this._last_requests.hasOwnProperty(i) &&
          i < this._rid-this._hold)
        delete(this._last_requests[i]); // truncate
  }

  return reqstr;
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getInitialRequestString = function() {
  var reqstr = "<body xml:lang='"+XML_LANG+"' content='text/xml; charset=utf-8' hold='"+this._hold+"' xmlns='http://jabber.org/protocol/httpbind' to='"+this.authhost+"' wait='"+this._wait+"' rid='"+this._rid+"'";
  if (this.secure)
    reqstr += " secure='"+this.secure+"'";
  if (JSJAC_HAVEKEYS) {
    this._keys = new JSJaCKeys(hex_sha1,this.oDbg); // generate first set of keys
    key = this._keys.getKey();
    reqstr += " newkey='"+key+"'";
  }

  if (JSJACHBC_USE_BOSH_VER) {
    reqstr += " ver='" + JSJACHBC_BOSH_VERSION + "'";
    reqstr += " xmlns:xmpp='urn:xmpp:xbosh'";
    if (this.authtype == 'sasl' || this.authtype == 'saslanon')
      reqstr += " xmpp:version='1.0'";
  }
  reqstr += "/>";
  return reqstr;
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getStreamID = function(req) {

  this.oDbg.log(req.responseText,4);

  if (!req.responseXML || !req.responseXML.documentElement) {
    this._handleEvent('onerror',JSJaCError('503','cancel','service-unavailable'));
    return;
  }
  var body = req.responseXML.documentElement;
  
  // any session error?
  if(body.getAttribute('type') == 'terminate') {
    this._handleEvent('onerror',JSJaCError('503','cancel','service-unavailable'));
    return;
  }
  
  // extract stream id used for non-SASL authentication
  if (body.getAttribute('authid')) {
    this.streamid = body.getAttribute('authid');
    this.oDbg.log("got streamid: "+this.streamid,2);
  }

  if (!this._parseStreamFeatures(body)) {
      this._sendEmpty(JSJaC.bind(this._getStreamID, this));
      return;
  }

  this._timeout = setTimeout(JSJaC.bind(this._process, this),
                             this.getPollInterval());

  if (this.register)
    this._doInBandReg();
  else
    this._doAuth();
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._getSuspendVars = function() {
  return ('host,port,secure,_rid,_last_rid,_wait,_min_polling,_inactivity,_hold,_last_requests,_pause').split(',');
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._handleInitialResponse = function(req) {
  try {
    // This will throw an error on Mozilla when the connection was refused
    this.oDbg.log(req.getAllResponseHeaders(),4);
    this.oDbg.log(req.responseText,4);
  } catch(ex) {
    this.oDbg.log("No response",4);
  }

  if (req.status != 200 || !req.responseXML) {
    this.oDbg.log("initial response broken (status: "+req.status+")",1);
    this._handleEvent('onerror',JSJaCError('503','cancel','service-unavailable'));
    return;
  }
  var body = req.responseXML.documentElement;

  if (!body || body.tagName != 'body' || body.namespaceURI != 'http://jabber.org/protocol/httpbind') {
    this.oDbg.log("no body element or incorrect body in initial response",1);
    this._handleEvent("onerror",JSJaCError("500","wait","internal-service-error"));
    return;
  }

  // Check for errors from the server
  if (body.getAttribute("type") == "terminate") {
    this.oDbg.log("invalid response:\n" + req.responseText,1);
    clearTimeout(this._timeout); // remove timer
    this._connected = false;
    this.oDbg.log("Disconnected.",1);
    this._handleEvent('ondisconnect');
    this._handleEvent('onerror',JSJaCError('503','cancel','service-unavailable'));
    return;
  }

  // get session ID
  this._sid = body.getAttribute('sid');
  this.oDbg.log("got sid: "+this._sid,2);

  // get attributes from response body
  if (body.getAttribute('polling'))
    this._min_polling = body.getAttribute('polling');

  if (body.getAttribute('inactivity'))
    this._inactivity = body.getAttribute('inactivity');

  if (body.getAttribute('requests'))
    this._setHold(body.getAttribute('requests')-1);
  this.oDbg.log("set hold to " + this._getHold(),2);

  if (body.getAttribute('ver'))
    this._bosh_version = body.getAttribute('ver');

  if (body.getAttribute('maxpause'))
    this._pause = Number.min(body.getAttribute('maxpause'), JSJACHBC_MAXPAUSE);

  // must be done after response attributes have been collected
  this.setPollInterval(this._timerval);

  /* start sending from queue for not polling connections */
  this._connected = true;

  this._inQto = setInterval(JSJaC.bind(this._checkInQ, this),
                            JSJAC_CHECKINQUEUEINTERVAL);
  this._interval= setInterval(JSJaC.bind(this._checkQueue, this),
                              JSJAC_CHECKQUEUEINTERVAL);

  /* wait for initial stream response to extract streamid needed
   * for digest auth
   */
  this._getStreamID(req);
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._parseResponse = function(req) {
  if (!this.connected() || !req)
    return null;

  var r = req.r; // the XmlHttpRequest

  try {
    if (r.status == 404 || r.status == 403) {
      // connection manager killed session
      this._abort();
      return null;
    }

    if (r.status != 200 || !r.responseXML) {
      this._errcnt++;
      var errmsg = "invalid response ("+r.status+"):\n" + r.getAllResponseHeaders()+"\n"+r.responseText;
      if (!r.responseXML)
        errmsg += "\nResponse failed to parse!";
      this.oDbg.log(errmsg,1);
      if (this._errcnt > JSJAC_ERR_COUNT) {
        // abort
        this._abort();
        return null;
      }

      if (this.connected()) {
        this.oDbg.log("repeating ("+this._errcnt+")",1);
        this._setStatus('proto_error_fallback');

        // schedule next tick
        setTimeout(JSJaC.bind(this._resume, this),
                   this.getPollInterval());
      }

      return null;
    }
  } catch (e) {
    this.oDbg.log("XMLHttpRequest error: status not available", 1);
	  this._errcnt++;
	  if (this._errcnt > JSJAC_ERR_COUNT) {
	    // abort
	    this._abort();
	  } else {
      if (this.connected()) {
	      this.oDbg.log("repeating ("+this._errcnt+")",1);

	      this._setStatus('proto_error_fallback');

	      // schedule next tick
	      setTimeout(JSJaC.bind(this._resume, this),
                   this.getPollInterval());
      }
    }
    return null;
  }

  var body = r.responseXML.documentElement;
  if (!body || body.tagName != 'body' ||
	  body.namespaceURI != 'http://jabber.org/protocol/httpbind') {
    this.oDbg.log("invalid response:\n" + r.responseText,1);

    clearTimeout(this._timeout); // remove timer
    clearInterval(this._interval);
    clearInterval(this._inQto);

    this._connected = false;
    this.oDbg.log("Disconnected.",1);
    this._handleEvent('ondisconnect');

    this._setStatus('internal_server_error');
    this._handleEvent('onerror',
		      JSJaCError('500','wait','internal-server-error'));

    return null;
  }

  if (typeof(req.rid) != 'undefined' && this._last_requests[req.rid]) {
    if (this._last_requests[req.rid].handled) {
      this.oDbg.log("already handled "+req.rid,2);
      return null;
    } else
      this._last_requests[req.rid].handled = true;
  }


  // Check for errors from the server
  if (body.getAttribute("type") == "terminate") {
    // read condition
    var condition = body.getAttribute('condition');

    if (condition != "item-not-found") {
      this.oDbg.log("session terminated:\n" + r.responseText,1);

      clearTimeout(this._timeout); // remove timer
      clearInterval(this._interval);
      clearInterval(this._inQto);

      try {
        removeDB('jsjac', 'state');
      } catch (e) {}

      this._connected = false;

      if (condition == "remote-stream-error")
        if (body.getElementsByTagName("conflict").length > 0)
          this._setStatus("session-terminate-conflict");
      if (condition == null)
        condition = 'session-terminate';
      this._handleEvent('onerror',JSJaCError('503','cancel',condition));

      this.oDbg.log("Aborting remaining connections",4);

      for (var i=0; i<this._hold+1; i++) {
        try {
          this._req[i].r.abort();
        } catch(e) { this.oDbg.log(e, 1); }
      }

      this.oDbg.log("parseResponse done with terminating", 3);

      this.oDbg.log("Disconnected.",1);
      this._handleEvent('ondisconnect');
    } else {
      this._errcnt++;
      if (this._errcnt > JSJAC_ERR_COUNT)
        this._abort();
    }
    return null;
  }

  // no error
  this._errcnt = 0;
  return r.responseXML.documentElement;
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._reInitStream = function(cb) {
    // tell http binding to reinit stream with/before next request
    this._reinit = true;

    this._sendEmpty(this._prepReInitStreamWait(cb));
};


JSJaCHttpBindingConnection.prototype._prepReInitStreamWait = function(cb) {
    return JSJaC.bind(function(req) {
        this._reInitStreamWait(req, cb);
    }, this);
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._reInitStreamWait = function(req, cb) {
    this.oDbg.log("checking for stream features");
    var doc = req.responseXML.documentElement;
    this.oDbg.log(doc);
    if (doc.getElementsByTagNameNS) {
        this.oDbg.log("checking with namespace");
        var features = doc.getElementsByTagNameNS('http://etherx.jabber.org/streams',
                                                'features').item(0);
        if (features) {
            var bind = features.getElementsByTagNameNS('urn:ietf:params:xml:ns:xmpp-bind',
                                                       'bind').item(0);
        }
    } else {
        var featuresNL = doc.getElementsByTagName('stream:features');
        for (var i=0, l=featuresNL.length; i<l; i++) {
            if (featuresNL.item(i).namespaceURI == 'http://etherx.jabber.org/streams' ||
                featuresNL.item(i).getAttribute('xmlns') == 
                'http://etherx.jabber.org/streams') {
                var features = featuresNL.item(i);
                break;
            }
        }
        if (features) {
            var bind = features.getElementsByTagName('bind');
            for (var i=0, l=bind.length; i<l; i++) {
                if (bind.item(i).namespaceURI == 'urn:ietf:params:xml:ns:xmpp-bind' ||
                    bind.item(i).getAttribute('xmlns') == 
                    'urn:ietf:params:xml:ns:xmpp-bind') {
                    bind = bind.item(i);
                    break;
                }
            }
        }
    }
    this.oDbg.log(features);
    this.oDbg.log(bind);
    
    if (features) {
        if (bind) {
            cb();
        } else {
            this.oDbg.log("no bind feature - giving up",1);
            this._handleEvent('onerror',JSJaCError('503','cancel',"service-unavailable"));
            this._connected = false;
            this.oDbg.log("Disconnected.",1);
            this._handleEvent('ondisconnect');
        }
    } else {
        // wait
        this._sendEmpty(this._prepReInitStreamWait(cb));
    }
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._resume = function() {
  /* make sure to repeat last request as we can be sure that
   * it had failed (only if we're not using the 'pause' attribute
   */
  if (this._pause == 0 && this._rid >= this._last_rid)
    this._rid = this._last_rid-1;

  this._process();
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._setHold = function(hold)  {
  if (!hold || isNaN(hold) || hold < 0)
    hold = 0;
  else if (hold > JSJACHBC_MAX_HOLD)
    hold = JSJACHBC_MAX_HOLD;
  this._hold = hold;
  return this._hold;
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._setupRequest = function(async) {
  var req = new Object();
  var r = XmlHttp.create();
  try {
    r.open("POST",this._httpbase,async);
    r.setRequestHeader('Content-Type','text/xml; charset=utf-8');
  } catch(e) { this.oDbg.log(e,1); }
  req.r = r;
  this._rid++;
  req.rid = this._rid;
  return req;
};

/**
 * @private
 */
JSJaCHttpBindingConnection.prototype._suspend = function() {
  if (this._pause == 0)
    return; // got nothing to do

  var slot = this._getFreeSlot();
  // Intentionally synchronous
  this._req[slot] = this._setupRequest(false);

  var reqstr = "<body xml:lang='"+XML_LANG+"' pause='"+this._pause+"' xmlns='http://jabber.org/protocol/httpbind' sid='"+this._sid+"' rid='"+this._rid+"'";
  if (JSJAC_HAVEKEYS) {
    reqstr += " key='"+this._keys.getKey()+"'";
    if (this._keys.lastKey()) {
      this._keys = new JSJaCKeys(hex_sha1,this.oDbg);
      reqstr += " newkey='"+this._keys.getKey()+"'";
    }

  }
  reqstr += ">";

  while (this._pQueue.length) {
    var curNode = this._pQueue[0];
    reqstr += curNode;
    this._pQueue = this._pQueue.slice(1,this._pQueue.length);
  }

  //reqstr += "<presence type='unavailable' xmlns='jabber:client'/>";
  reqstr += "</body>";

  this.oDbg.log("Disconnecting: " + reqstr,4);
  this._req[slot].r.send(reqstr);
};
