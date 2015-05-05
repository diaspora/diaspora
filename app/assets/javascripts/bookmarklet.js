// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

var bookmarklet = function(url, width, height, opts) {
  var maxLen = 1900; // max GET request length, see #3076
  var maxTitleLen = 128; // cut title after this length, if too long

  // calculate popup dimensions & placement
  var dim = function() {
    var  w = window,
    winTop = (w.screenTop ? w.screenTop : w.screenY),
   winLeft = (w.screenLeft ? w.screenLeft : w.screenX),
       top = (winTop + (w.innerHeight / 2) - (height / 2)),
      left = (winLeft + (w.innerWidth / 2) - (width / 2));
    return "width=" + width + ",height=" + height + ",top=" + top + ",left=" + left;
  };

  // prepare url parameters
  var params = function() {
    var w = window,
        d = document,
     href = w.location.href,
    title = d.title,
      sel = w.getSelection ? w.getSelection() :
            d.getSelection ? d.getSelection() :
            d.selection.createRange().text,
    notes = sel.toString(),
      len = maxLen - href.length;

    if( (title+notes).length > len ) {
      // shorten the text to fit in a GET request
      if( title.length > maxTitleLen ) title = title.substr(0, maxTitleLen) + " ...";
      if( notes.length > (len-maxTitleLen) ) notes = notes.substr(0, len-maxTitleLen) + " ...";
    }

    return "url=" + encodeURIComponent(href) +
           "&title=" + encodeURIComponent(title) +
           "&notes=" + encodeURIComponent(notes);
  };

  // popup (or redirect) action
  var act = function() {
    var popupOpts = (opts || "location=yes,links=no,scrollbars=yes,toolbar=no"),
        jumpUrl   = url + "?jump=yes";

    (window.open(url + "?" + params(), "diaspora_bookmarklet", popupOpts + "," + dim()) ||
    (window.location.href = jumpUrl + "&" + params()));
  };

  if( /Firefox/.test(navigator.userAgent) ) {
    setTimeout(act, 0);
  } else {
    act();
  }
};

// @license-end
