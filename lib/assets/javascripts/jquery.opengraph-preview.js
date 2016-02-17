/*************************************************************
 * Use:                                                      *
 * $("#link").linkpreview({                                  *
 *     url: "https://diasporafoundation.org/",  //optional   *
 *     previewContainerClass: "jq-opengraph-preview"         *
 *     proxy: example.com?%QUERY                             *
 *     preProcess: function() {                 //optional   *
 *         console.log("preProcess");                        *
 *     },                                                    *
 *     onSuccess: function(data) {              //optional   *
 *         console.log("onSuccess");                         *
 *     },                                                    *
 *     onError: function() {                    //optional   *
 *         console.log("onError");                           *
 *     },                                                    *
 *     onParseError: function() {               //optional   *
 *         console.log("onError");                           *
 *     },                                                    *
 *     onComplete: function() {                 //optional   *
 *         console.log("onComplete");                        *
 *     },                                                    *
 *     template: function(data) {               //optional   *
 *         // render template                                *
 *     }                                                     *
 * });                                                       *
 *************************************************************/

(function($){
  var OpengraphPreview = function(element, options){
    this.initialize(element, options);
  };

  OpengraphPreview.prototype = {
    constructor: OpengraphPreview,

    options: {
      previewContainerClass: "jq-opengraph-preview",
      proxy: undefined,
      onError: function(){
        console.log("Error fetching opengraph");
      } ,
      onSuccess: function(){},
      preProcess: function(){},
      onComplete: function(){},
      onParseError: function(){}
    },

    initialize: function(element, options){
      this.options.previewContainer = $(element);
      this.options = $.extend(this.options, options);
      this.options.previewContainer.addClass(this.options.previewContainerClass);
      this.options.template = this.template;

      this.getSource();
    },

    getSource: function(){
      this.options.preProcess();
      var self = this;
      var url = this.options.url;

      if(this.options.proxy){
        url = this.options.proxy.replace("%QUERY", encodeURI(this.options.url));
      }

      console.log(url);

      $.ajax({
        url: url,
        type: "GET",
        success: function(data){
          self.renderPreview(data, self);
          self.options.onSuccess(data);
        },
        error: self.options.onError,
        complete: self.options.onComplete
      });
    },

    renderPreview: function(data, self){
      self.options.previewContainer.empty();

      data = data.replace(/<\/?[A-Z]+[\w\W]*?>/g, function(m){
        return m.toLowerCase();
      });

      var dom = document.implementation.createHTMLDocument("");
      dom.body.innerHTML = data;
      var $dom = $(dom);

      var metadata = self.parseContent($dom);
      if(!metadata){
        self.options.onParseError();
        return;
      }

      var result = self.options.template(metadata);
      self.options.previewContainer.append(result);
    },

    template: function(data){
      var result = $("<div></div>");
      var link = $("<a class='og-url'></a>").attr({target: "_blank", href: data.url});
      var img = $("<img class='og-image'/>").attr("src", data.image).css({
        "margin": "5px 5px 5px 0px",
        "float": "left",
        "max-width": "150px",
        "padding-right": "5px"
      });

      var title = $("<p class='og-title'></p>").text(data.title);
      link.append(img).append(title);
      result.append(link);

      if(data.description){
        result.append($("<p class='og-description'></p>").text(data.description));
      }

      return result.html();
    },

    parseContent: function($dom){
      var findMeta = function(name){
        return $dom.find("meta[property='og:" + name + "']")
            .attr("content") || undefined;
      };

      var metadata = {
        title: findMeta("title"),
        type: findMeta("type"),
        url: findMeta("url"),
        image: findMeta("image")
      };

      for(meta in metadata){
        if(!metadata[meta]){
          return undefined;
        }
      }

      $.extend(metadata, {
        description: findMeta("description")
      });

      return metadata;
    }
  };

  $.fn.opengraphPreview = function(options){
    return this.each(function(){
      var $this = $(this);
      options.url = options.url || $this.href ||
        $this.attr("src") || $this.text() || $this.val();

      if(!options.url){
        throw "URL required";
      }

      new OpengraphPreview($this, options);
    });
  };
})(window.jQuery);
