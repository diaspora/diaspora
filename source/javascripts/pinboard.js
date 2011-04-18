var count = pinboard_count;
var linkroll = 'pinboard_linkroll';
function pinboardNS_fetch_script(url) {
  document.writeln('<s'+'cript type="text/javascript" src="' + url + '"></s'+'cript>');
}

function pinboardNS_show_bmarks(r) {
  var lr = new Pinboard_Linkroll();
  lr.set_items(r);
  lr.show_bmarks();
}

var json_URL = "http://feeds.pinboard.in/json/v1/u:"+pinboard_user+"/?cb=pinboardNS_show_bmarks\&count=" + count;
pinboardNS_fetch_script(json_URL);

function Pinboard_Linkroll() {
  var items;

  this.set_items = function(i) {
    this.items = i;
  }
  this.show_bmarks = function() {
    var lines = [];
    for (var i = 0; i < this.items.length; i++) {
      var item = this.items[i];
      var str = this.format_item(item);
      lines.push(str);
    }
    $(linkroll).set('html', lines.join("\n"));
  }
  this.cook = function(v) {
    return v.replace('<', '&lt;').replace('>', '&gt>');
  }

  this.format_item = function(it) {
    var str = "<li class=\"pin-item\">";
    if (!it.d) { return; }
    str += "<p><a class=\"pin-title\" href=\"" + this.cook(it.u) + "\">" + this.cook(it.d) + "</a>";
    if (it.n) {
      str += "<span class=\"pin-description\">" + this.cook(it.n) + "</span>\n";
    }
    if (it.t.length > 0) {
      for (var i = 0; i < it.t.length; i++) {
        var tag = it.t[i];
        str += " <a class=\"pin-tag\" href=\"http://pinboard.in/u:"+ this.cook(it.a) + "/t:" + this.cook(tag) + "\">" + this.cook(tag) + "</a>  ";
      }
    }
    str += "</p></li>\n";
    return str;
  }
}
Pinboard_Linkroll.prototype = new Pinboard_Linkroll();
