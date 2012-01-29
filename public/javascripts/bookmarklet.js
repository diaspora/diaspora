javascript:

/*  Copyright (c) 2012, Jairo Llopis. This file is licensed under the
 *  Affero General Public License version 3 or later.
 *  See the COPYRIGHT file.
 */

/* All in a lambda to avoid polluting the current page */
(function(){
  /* This should be defined from the server */
  var url = 'https://joindiaspora.com/bookmarklet',

    /* Get user's selection */
    sel = window.getSelection ? window.getSelection() :
        document.getSelection ? document.getSelection() :
        document.selection.createRange().text,
    notes = '',

    /* Make a paragraph a blockquote using Diaspora*'s Markdown */
    blockquote = function(text) {
      return text.trim().replace(/\n{2,}/g, '\n\n').replace(/^/gm, '>');
    },

    /* Remove newlines from given text */
    removeNewLines = function(text) {
      return text.replace(/\n/g, ' ');
    },

    /* Recursively extract selection text */
    extract = function(node) {
      var text  = '',
        /* Quit quotes from node's title (if it has one) */
        title = (!node.title ? '' :
          ' "' + node.title.replace(/"/g, '`') + '"');

      switch (node.nodeType) {

        /* Avoid comment nodes */
        case Node.COMMENT_NODE:
        case Node.CDATA_SECTION_NODE:
          return '';

        /* When getting to a text node, don't recurse anymore */
        case Node.TEXT_NODE:
          if (!node.isElementContentWhitespace)
            return node.textContent;

        default:
          /* Get node's text content recursively */
          for (var n in node.childNodes) {
            text += extract(node.childNodes[n]);
          }

          /* Special cases for some types of nodes */
          switch (node.localName){
            case 'img':
              text = '\n\n!['
                + (removeNewLines(node.alt) || '')
                + ']('
                + removeNewLines(node.src)
                + removeNewLines(title)
                + ')\n\n';
            break;

            case 'a':
              text = ' ['
                + removeNewLines(text)
                + ']('
                + removeNewLines(node.href)
                + removeNewLines(title)
                + ') ';
            break;

            case 'br':
              text = '\n\n';
            break;

            case 'pre':
              text = '```\n' + text.trim() + '\n```';
            break;

            case 'code':
              text = '`' + text + '`';
            break;

            case 'i':
            case 'em':
              text = '*' + text + '*';
            break;

            case 'b':
            case 'strong':
              text = '**' + text + '**';
            break;

            case 'blockquote':
              text = blockquote(text) + '\n\n';
            break;
          }

          /* Separate in paragraphs if the node is not inline */
          try {
            if (
              window.getComputedStyle(node, null)
              .getPropertyCSSValue('display').cssText
              != 'inline'
            ) {
              text += '\n\n';
            }
          } finally{
            return text;
          }
      }
    };

  /* Get selection's text */
  for (var r = 0; r < sel.rangeCount; r++) {
    notes += extract(sel.getRangeAt(r).cloneContents());
  }

  /* Add ">" at the beginning of each line to make it become a blockquote */
  if (notes) notes = blockquote(notes);

  /*console.log(notes); /* Uncomment to debug */

  /* Generate URL */
  url += '?url='
    + encodeURIComponent(window.location.href)
    + '&title='
    + encodeURIComponent(document.title)
    + '&notes='
    + encodeURIComponent(notes)
    + '&v=1&noui=1&jump=';

  /* Open the bookmarklet window */
  if (!window.open(
    url + 'doclose',
    'diasporav1',
    'location=yes,links=no,scrollbars=no,toolbar=no,width=620,height=250'
  )) {
    location.href = url + 'yes';
  }

  return undefined;
})();
