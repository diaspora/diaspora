/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  Diaspora.Widgets.AspectNavigation = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, aspectNavigation) {
      $.extend(self, {
        aspectNavigation: aspectNavigation,
        aspectSelectors: aspectNavigation.find("a.aspect_selector[data-guid]"),
        aspectLis: aspectNavigation.find("li[data-aspect_id]"),
        toggleSelector: aspectNavigation.find("a.toggle_selector")
      });

      self.calculateToggleText();
      self.aspectSelectors.click(self.toggleAspect);
      self.toggleSelector.click(self.toggleAll);
    });

    this.selectedAspects = function() {
      return self.aspectNavigation.find("li.active[data-aspect_id]").map(function() { return $(this).data('aspect_id') });
    };

    this.toggleAspect = function(evt) {
      evt.preventDefault();

      $(this).parent().toggleClass("active");
      self.perform();
    };

    this.toggleAll = function(evt) {
      evt.preventDefault();

      if (self.allSelected()) {
        self.aspectLis.removeClass("active");
      } else {
        self.aspectLis.addClass("active");
      }
      self.perform();
    };

    this.perform = function() {
      if (self.noneSelected()) {
        self.abortAjax();
        Diaspora.page.stream.empty();
        Diaspora.page.stream.setHeaderTitle(Diaspora.I18n.t('aspect_navigation.no_aspects'));
        self.fadeIn();
      } else {
        self.performAjax();
      }
      self.calculateToggleText();
    };

    this.calculateToggleText = function() {
      if (self.allSelected()) {
        self.toggleSelector.text(Diaspora.I18n.t('aspect_navigation.deselect_all'));
      } else {
        self.toggleSelector.text(Diaspora.I18n.t('aspect_navigation.select_all'));
      }
    };

    this.generateURL = function() {
      var baseURL = 'aspects';

      // generate new url
      baseURL = baseURL.replace('#','');
      baseURL += '?';

      self.aspectLis.each(function() {
        var aspectLi = $(this);
        if (aspectLi.hasClass("active")) {
          baseURL += "a_ids[]=" + aspectLi.data("aspect_id") + "&";
        }
      });

      if(!$("#publisher").hasClass("closed")) {
        // open publisher
        baseURL += "op=true";
      } else {
        // slice last '&'
        baseURL = baseURL.slice(0,baseURL.length-1);
      }
      return baseURL;
    };

    this.performAjax = function() {
      var post = $("#publisher textarea#status_message_fake_text").val(),
        newURL = self.generateURL(),
        photos = {};

      //pass photos
   	  $('#photodropzone img').each(function() {
        var img = $(this);
        photos[img.attr("data-id")] = img.attr("src");
      });

      self.abortAjax();
      self.fadeOut();

      self.jXHR = $.getScript(newURL, function(data) {
        if (typeof(history.pushState) == 'function') {
          history.pushState(null, document.title, newURL);
        }

        var textarea = $("#publisher textarea#status_message_fake_text"),
          photozone = $("#photodropzone");

        if( post !== "" ) {
          textarea.val(post).focus();
        }

        $.each(photos, function(GUID, URL) {
          photozone.append([
            '<li style="position: relative;">',
              '<img src="' + URL + ' data-id="' + GUID + '/>',
            '</li>'
          ].join(""));
        });

        self.globalPublish("stream/reloaded");
        if( post !== "" ) {
          Publisher.open();
        }
        self.fadeIn();
      });
    };

    this.abortAjax = function() {
      if (self.jXHR) {
        self.jXHR.abort();
        self.jXHR = null;
      }
    };

    this.noneSelected = function() {
      return self.aspectLis.filter(".active").length === 0;
    }

    this.allSelected = function() {
      return self.aspectLis.not(".active").length === 0;
    }

    this.fadeOut = function() {
      $("#aspect_stream_container").fadeTo(100, 0.4);
      $("#selected_aspect_contacts").fadeTo(100, 0.4);
    };

    this.fadeIn = function() {
      $("#aspect_stream_container").fadeTo(100, 1);
      $("#selected_aspect_contacts").fadeTo(100, 1);
    };
  };
})();
