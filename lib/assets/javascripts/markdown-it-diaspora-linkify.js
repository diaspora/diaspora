// TODO this is a temporary fix
// remove it as soon as markdown-it fixes its autolinking feature

/*! markdown-it-diaspora-linkify 0.1.0 https://github.com/diaspora/markdown-it-diaspora-linkify @license MIT */!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.markdownitDiasporaLinkify=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
// Replace link-like texts with link nodes.
//
'use strict';

var urlRegex = /(?:^|\s)(?:(?:https?|ftp):\/\/|(?:mailto:|xmpp:)\S+@|www[^.\s]*\.)\S*[^.,:;!?\s]/gi;

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
        blockTokens = state.tokens, links, href, url;

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

        if (token.type !== 'text') { continue; }

        links = token.content.match(urlRegex);
        if (links === null || !links.length) { continue; }

        text = token.content;

        // Now split string to nodes
        nodes = [];
        level = token.level;

        for (ln = 0; ln < links.length; ln++) {
          url = links[ln].trim();
          href = url;

          if (/^www/i.test(href)) { href = 'http://' + href; }
          pos = text.indexOf(url);

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
            content: url,
            level: level
          });
          nodes.push({
            type: 'link_close',
            level: --level
          });
          text = text.slice(pos + url.length);
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

  md.core.ruler.at('linkify', linkify);
};

},{}]},{},[1])(1)
});
