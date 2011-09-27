/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
/* Modified version of https://gitorious.org/statusnet/mainline/blobs/master/plugins/DirectionDetector/jquery.DirectionDetector.js */
(function() {
  var DirectionDetector = function() {
    var self = this;
    this.binds = [];
    this.cleaner = new RegExp("@[^ ]+|^RT[: ]{1}| RT | RT: |[♺♻:]+", "g");

    this.subscribe("widget/ready", function() {
      self.updateBinds();
    
      self.globalSubscribe("stream/scrolled", function() {
				self.updateBinds();
      });
    });

    this.isRTL = function(str) {
      if(typeof str !== "string" || str.length < 1) {
				return false;
      }

      var charCode = str.charCodeAt(0);
      if(charCode >= 1536 && charCode <= 1791) // Sarabic, Persian, ...
				return true;

      else if(charCode >= 65136 && charCode <= 65279) // Arabic present 1
				return true;

      else if(charCode >= 64336 && charCode <= 65023) // Arabic present 2
				return true;
      
      else if(charCode>=1424 && charCode<=1535) // Hebrew
				return true;

      else if(charCode>=64256 && charCode<=64335) // Hebrew present
				return true;

      else if(charCode>=1792 && charCode<=1871) // Syriac
				return true;

      else if(charCode>=1920 && charCode<=1983) // Thaana
				return true;

      else if(charCode>=1984 && charCode<=2047) // NKo
				return true;

      else if(charCode>=11568 && charCode<=11647) // Tifinagh
				return true;

      return false;
    };

    this.updateBinds = function() {
      $.each(self.binds, function(index, bind) {
				bind.unbind("keyup", self.updateDirection);
      });

      self.binds = [];

      $("textarea, input[type='text'], input[type='search']").each(self.bind);
    };

    this.bind = function() {
      self.binds.push(
				$(this).bind("keyup", self.updateDirection)
      );
    };

    this.updateDirection = function() {
      var textArea = $(this),
				cleaned = textArea.val().replace(self.cleaner, "").replace(/^[ ]+/, "");

      if(self.isRTL(cleaned)) {
				textArea.css("direction", "rtl");
      }
      else {
				textArea.css("direction", "ltr");
      }
    };
  };

  Diaspora.Widgets.DirectionDetector = DirectionDetector;
})();
