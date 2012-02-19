#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper

  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end

  def bookmarklet
    'javascript:(function(){var a="#{AppConfig[:pod_url]}bookmarklet",b=window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text,c="",d=function(a){return a.trim().replace(/\n{2,}/g,"\n\n").replace(/^/gm,">")},e=function(a){return a.replace(/\n/g," ")},f=function(a){var b="",c=!a.title?"":\' "\'+a.title.replace(/"/g,"`")+\'"\';switch(a.nodeType){case Node.COMMENT_NODE:case Node.CDATA_SECTION_NODE:return"";case Node.TEXT_NODE:if(!a.isElementContentWhitespace)return a.textContent;default:for(var g in a.childNodes){b+=f(a.childNodes[g])}switch(a.localName){case"img":b="\n\n!["+(e(a.alt)||"")+"]("+e(a.src)+e(c)+")\n\n";break;case"a":b=" ["+e(b)+"]("+e(a.href)+e(c)+") ";break;case"br":b="\n\n";break;case"pre":b="```\n"+b.trim()+"\n```";break;case"code":b="`"+b+"`";break;case"i":case"em":b="*"+b+"*";break;case"b":case"strong":b="**"+b+"**";break;case"blockquote":b=d(b)+"\n\n";break}try{if(window.getComputedStyle(a,null).getPropertyCSSValue("display").cssText!="inline"){b+="\n\n"}}finally{return b}}};for(var g=0;g<b.rangeCount;g++){c+=f(b.getRangeAt(g).cloneContents())}if(c)c=d(c);a+="?url="+encodeURIComponent(window.location.href)+"&title="+encodeURIComponent(document.title)+"&notes="+encodeURIComponent(c)+"&v=1&noui=1&jump=";if(!window.open(a+"doclose","diasporav1","location=yes,links=no,scrollbars=no,toolbar=no,width=620,height=250")){location.href=a+"yes"}return undefined})()'
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      community_spotlight_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig[:configured_services].size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to(image_tag('deletelabel.png'), "#", :class => 'close')
  end

  def diaspora_id_host
    User.diaspora_id_host
  end

  def jquery_include_tag
    "<script src='//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js' type='text/javascript'></script>".html_safe +
    content_tag(:script) do
      "!window.jQuery && document.write(unescape(\"#{escape_javascript(include_javascripts(:jquery))}\")); jQuery.ajaxSetup({'cache': false});".html_safe
    end
  end
end
