// TODO this is a temporary fix
// remove it as soon as markdown-it fixes its autolinking feature

/*! markdown-it-diaspora-linkify 0.1.0 https://github.com/diaspora/markdown-it-diaspora-linkify @license MIT */!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.markdownitDiasporaLinkify=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

var ip = require('ip-regex').v4().source;
var tlds = require('./tlds.json').join('|');

/**
 * Regular expression for matching URLs
 *
 * @param {Object} opts
 * @api public
 */

module.exports = function (opts) {
	opts = opts || {};

	var auth = '(?:\\S+(?::\\S*)?@)?';
	var domain = '(?:\\.(?:xn--[a-z0-9\\-]{1,59}|(?:[a-z\\u00a1-\\uffff0-9]+-?){0,62}[a-z\\u00a1-\\uffff0-9]{1,63}))*';
	var host = '(?:xn--[a-z0-9\\-]{1,59}|(?:(?:[a-z\\u00a1-\\uffff0-9]+-?){0,62}[a-z\\u00a1-\\uffff0-9]{1,63}))';
	var path = '(?:\/[^\\s]*)?';
	var port = '(?::\\d{2,5})?';
	var protocol = '(?:(?:(?:\\w)+:)?\/\/)?';
	var tld = '(?:\\.(?:xn--[a-z0-9\\-]{1,59}|' + tlds + '+))';

	var regex = [
		protocol + auth + '(?:' + ip + '|',
		'(?:localhost)|' + host + domain + tld + ')' + port + path
	].join('');

	return opts.exact ? new RegExp('(?:^' + regex + '$)', 'i') :
						new RegExp('(?:^|\\s)(["\'])?' + regex + '\\1', 'ig');
};

},{"./tlds.json":3,"ip-regex":2}],2:[function(require,module,exports){
'use strict';

var v4 = '(?:25[0-5]|2[0-4][0-9]|1?[0-9][0-9]{1,2}|[0-9]){1,}(?:\\.(?:25[0-5]|2[0-4][0-9]|1?[0-9]{1,2}|0)){3}';
var v6 = '(?:(?:[0-9a-fA-F:]){1,4}(?:(?::(?:[0-9a-fA-F]){1,4}|:)){2,7})+';

var ip = module.exports = function (opts) {
	opts = opts || {};
	return opts.exact ? new RegExp('(?:^' + v4 + '$)|(?:^' + v6 + '$)') :
	                    new RegExp('(?:' + v4 + ')|(?:' + v6 + ')', 'g');
};

ip.v4 = function (opts) {
	opts = opts || {};
	return opts.exact ? new RegExp('^' + v4 + '$') : new RegExp(v4, 'g');
};

ip.v6 = function (opts) {
	opts = opts || {};
	return opts.exact ? new RegExp('^' + v6 + '$') : new RegExp(v6, 'g');
};

},{}],3:[function(require,module,exports){
module.exports=["vermögensberatung","vermögensberater","cancerresearch","international","versicherung","construction","contractors","engineering","motorcycles","சிங்கப்பூர்","accountants","investments","enterprises","williamhill","photography","blackfriday","productions","properties","healthcare","immobilien","university","republican","consulting","technology","industries","creditcard","cuisinella","foundation","restaurant","bnpparibas","associates","management","vlaanderen","furniture","bloomberg","equipment","melbourne","financial","education","directory","solutions","allfinanz","institute","christmas","community","vacations","marketing","training","capetown","pharmacy","partners","delivery","democrat","diamonds","software","discount","السعودية","saarland","catering","airforce","mortgage","attorney","services","engineer","supplies","cleaning","property","clothing","lighting","exchange","feedback","boutique","flsmidth","brussels","plumbing","budapest","computer","builders","business","yokohama","bargains","holdings","ventures","graphics","pictures","whoswho","dentist","recipes","digital","neustar","schmidt","realtor","shiksha","domains","network","support","android","youtube","college","cologne","surgery","capital","company","caravan","இந்தியா","abogado","academy","limited","careers","spiegel","lacaixa","exposed","cooking","finance","country","fishing","fitness","flights","florist","reviews","kitchen","channel","forsale","cricket","frogans","cruises","systems","الجزائر","gallery","science","auction","organic","okinawa","hosting","holiday","website","wedding","hamburg","rentals","singles","guitars","travel","google","hiphop","global","онлайн","москва","insure","futbol","joburg","juegos","kaufen","امارات","expert","lawyer","events","london","estate","luxury","maison","الاردن","market","energy","emerck","monash","moscow","المغرب","museum","nagoya","durban","direct","dental","degree","webcam","مليسيا","voyage","dating","otsuka","gratis","credit","photos","physio","condos","coffee","clinic","quebec","claims","reisen","vision","church","repair","report","chrome","center","villas","viajes","ryukyu","career","camera","இலங்கை","schule","فلسطين","yachts","social","yandex","berlin","bayern","supply","suzuki","sydney","alsace","taipei","tattoo","agency","active","tienda","voting","globo","mango","ایران","pizza","place","سورية","poker","praxi","press","jetzt","codes","media","vodka","homes","click","miami","citic","rehab","reise","works","horse","email","భారత్","بھارت","house","cheap","koeln","world","संगठन","rocks","rodeo","glass","nexus","cards","lease","gives","ninja","build","deals","black","shoes","بازار","watch","loans","solar","wales","vegas","space","guide","autos","lotto","audio","archi","green","gifts","paris","dance","tatar","parts","gripe","actor","cymru","photo","tirol","today","tokyo","tools","gmail","trade","party","aero","ভারত","شبكة","kiwi","pics","club","pink","army","kred","casa","pohl","land","post","cash","ਭਾਰਤ","vote","prod","lgbt","prof","life","भारत","ભારત","qpon","limo","link","buzz","ලංකා","arpa","تونس","luxe","reit","cern","fail","farm","desi","blue","rest","guru","diet","rich","meet","haus","meme","menu","rsvp","ruhr","fish","help","sarl","mini","mobi","moda","work","here","scot","beer","sexy","дети","asia","camp","best","cool","sohu","name","navy","wiki","host","coop","wien","yoga","dvag","surf","сайт","immo","city","عمان","info","bike","wang","fund","zone","voto","组织机构","tips","موقع","band","care","gbiz","jobs","town","toys","gent","gift","ltda","top","tel","uno","uol","tax","soy","scb","sca","vet","rip","rio","ren","red","pub","pro","ovh","org","ooo","onl","ong","nyc","nrw","nra","wed","nhk","ngo","new","net","mov","wme","moe","mil","krd","wtc","wtf","kim","int","我爱你","ink","қаз","ing","ibm","срб","орг","tui","hiv","мкд","中文网","gov","gop","gmx","gmo","gle","укр","мон","gal","frl","foo","fly","eus","esq","edu","eat","dnp","day","dad","crs","ไทย","com","рус","ceo","みんな","cat","cal","cab","مصر","قطر","bzh","boo","新加坡","bmw","xxx","xyz","biz","bio","bid","bar","axa","zip","how","pk","pl","er","hr","pm","pn","ht","hu","es","pr","id","ie","il","im","ca","ae","in","et","ps","pt","eu","pw","py","qa","as","al","re","bf","bg","bh","bi","zw","io","iq","ir","is","it","je","at","jm","jo","fi","af","jp","cr","ro","au","ke","rs","kg","ru","kh","rw","ki","sa","bj","am","sb","sc","fj","km","kn","fk","kp","kr","sd","se","an","ag","sg","sh","kw","ky","si","kz","sj","sk","sl","sm","sn","so","la","cu","aw","fm","lb","lc","fo","cv","sr","st","su","li","cw","cx","fr","cy","cc","sv","sx","sy","lk","cz","sz","cd","bm","lr","ls","tc","td","lt","ga","tf","tg","th","lu","ax","bn","tj","tk","tl","tm","tn","to","lv","ly","ac","gb","de","gd","tp","tr","ge","cf","mc","tt","md","tv","tw","tz","ua","ug","uk","me","gf","gg","us","uy","uz","va","gh","vc","ve","gi","cg","mg","mh","vg","vi","ch","ao","gl","mk","vn","ml","mm","mn","mo","bo","vu","az","ba","br","gm","ci","aq","bs","wf","mp","mq","mr","ms","mt","mu","gn","mv","ws","mw","mx","佛山","集团","在线","한국","my","八卦","mz","公益","公司","移动","na","ck","cl","dj","nc","ne","gp","삼성","gq","商标","商城","gr","dk","dm","中信","中国","中國","nf","ng","bt","do","ni","网络","gs","香港","台湾","台灣","手机","nl","no","np","nr","gt","gu","nu","ar","nz","ad","om","ai","გე","机构","gw","gy","dz","bb","рф","ec","bd","世界","pa","网址","游戏","cm","ee","企业","eg","hk","广东","pe","pf","pg","ph","政务","hm","hn","cn","co","ye","bv","bw","by","yt","za","bz","zm","be","ma"]
},{}],4:[function(require,module,exports){
// Replace link-like texts with link nodes.
//
'use strict';

var urlRegex = require('url-regex');
var LINK_SCAN_RE = /www|@|\:\/\//;

function isLinkOpen(str) {
  return /^<a[>\s]/i.test(str);
}
function isLinkClose(str) {
  return /^<\/a\s*>/i.test(str);
}

module.exports = function linkify_plugin(md) {
  var arrayReplaceAt = md.utils.arrayReplaceAt;

  function linkify(state) {
    var i, j, l, tokens, token, text, nodes, ln, pos, level, htmlLinkLevel,
        blockTokens = state.tokens, links, href;

    if (!state.md.options.linkify) { return; }

    for (j = 0, l = blockTokens.length; j < l; j++) {
      if (blockTokens[j].type !== 'inline') { continue; }
      tokens = blockTokens[j].children;

      htmlLinkLevel = 0;

      // We scan from the end, to keep position when new tags added.
      // Use reversed logic in links start/end match
      for (i = tokens.length - 1; i >= 0; i--) {
        token = tokens[i];

        // Skip content of markdown links
        if (token.type === 'link_close') {
          i--;
          while (tokens[i].level !== token.level && tokens[i].type !== 'link_open') {
            i--;
          }
          continue;
        }

        // Skip content of html tag links
        if (token.type === 'html_inline') {
          if (isLinkOpen(token.content) && htmlLinkLevel > 0) {
            htmlLinkLevel--;
          }
          if (isLinkClose(token.content)) {
            htmlLinkLevel++;
          }
        }
        if (htmlLinkLevel > 0) { continue; }

        if (token.type === 'text' && LINK_SCAN_RE.test(token.content)) {

          text = token.content;
          links = text.match(urlRegex());

          if (links === null || !links.length) { continue; }

          // Now split string to nodes
          nodes = [];
          level = token.level;

          for (ln = 0; ln < links.length; ln++) {

            if (!state.md.inline.validateLink(links[ln])) { continue; }

            pos = text.indexOf(links[ln]);

            href = links[ln];

            if (pos) {
              level = level;
              nodes.push({
                type: 'text',
                content: text.slice(0, pos),
                level: level
              });
            }
            nodes.push({
              type: 'link_open',
              href: href,
              target: '',
              title: '',
              level: level++
            });
            nodes.push({
              type: 'text',
              content: links[ln],
              level: level
            });
            nodes.push({
              type: 'link_close',
              level: --level
            });
            text = text.slice(pos + links[ln].length);
          }
          if (text.length) {
            nodes.push({
              type: 'text',
              content: text,
              level: level
            });
          }

          // replace current node
          blockTokens[j].children = tokens = arrayReplaceAt(tokens, i, nodes);
        }
      }
    }
  }

  md.core.ruler.at('linkify', linkify);
};

},{"url-regex":1}]},{},[4])(4)
});
