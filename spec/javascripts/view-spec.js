describe("View", function() { 
  it("is the object that helps the UI", function() { 
    expect(typeof View === "object").toBeTruthy();
  });

  describe("initialize", function() {
    it("is called on DOM ready", function() {
      spyOn(View, "initialize");
      $(View.initialize);
      expect(View.initialize).toHaveBeenCalled();
    });
  });


  describe("debug", function() {
    describe("click", function() {
      beforeEach(function() {
        jasmine.Clock.useMock();
        $("#jasmine_content").html(
          '<div id="debug_info">' +
            '<h5>DEBUG INFO</h5>' +
            '<div id="debug_more" style="display: none;">' +
              'DEBUG INFO' +
            '</div>' +
          '</div>'
        );
      });

      it("is called when the user clicks an element matching the selector", function() {
        spyOn(View.debug, "click");
        View.initialize();
        $(View.debug.selector).click();
        jasmine.Clock.tick(200);
        expect(View.debug.click).toHaveBeenCalled();
        expect($(View.debug.selector).css("display")).toEqual("block");
      });
    });
  });

  describe("flashes", function() {
    describe("animate", function() {
      beforeEach(function() {
        $("#jasmine_content").html(
          '<div id="flash_notice">' +
            'flash! flash! flash!' +
          '</div>'
        );
      });

      it("is called when the DOM is ready", function() {
        spyOn(View.flashes, "animate").andCallThrough();
        View.initialize();
        expect(View.flashes.animate).toHaveBeenCalled();
      });
    });
    describe("render", function() {
      it("creates a new div and calls flashes.animate", function() {
        spyOn(View.flashes, "animate");
        View.flashes.render({
          success: true,
          message: "success!"
        });
        expect(View.flashes.animate).toHaveBeenCalled();
      });
    });
  });

  describe("newRequest", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<div id="user@joindiaspora.com">' +
          '<form accept-charset="UTF-8" action="/requests" class="new_request" data-remote="true" id="new_request" method="post">' +
            '<div style="margin:0;padding:0;display:inline">' +
            '<input id="request_to" name="request[to]" type="hidden" value="user@joindiaspora.com">' +
            '<input data-disable-with="Sending" id="request_submit" name="commit" type="submit" value="add contact" class="button">' +
          '</form>' +
          '<div class="message hidden">' +
            '<i>sent!</i>' +
         '</div>' +
        '</div>'
      );
    });

    describe("submit", function() {
      it("is called when the user submits the form", function() {
        spyOn(View.newRequest, "submit").andCallThrough();
        View.initialize();
        $(View.newRequest.selector).submit(function(evt) { evt.preventDefault(); });
        $(View.newRequest.selector).trigger("submit");
        expect(View.newRequest.submit).toHaveBeenCalled();
        expect($(View.newRequest.selector + " .message").css("display")).toEqual("block");
      });
    });
  });

  describe("publisher", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<div id="publisher">' +
          '<form action="/status_messages" class="new_status_message" id="new_status_message" method="post">' +
            '<textarea id="status_message_text" name="status_message[text]"></textarea>' +
          '</form>' +
        '</div>'
      );
    });
  });

  describe("search", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<input id="q" name="q" placeholder="Search" results="5" type="search" class="">'
      );
    });
    describe("focus", function() {
      it("adds the class 'active' when the user focuses the text field", function() {
        View.initialize();
        $(View.search.selector).focus();
        expect($(View.search.selector)).toHaveClass("active");
      });
    });
    describe("blur", function() {
      it("removes the class 'active' when the user blurs the text field", function() {
        View.initialize();
        $(View.search.selector).focus().blur();
        expect($(View.search.selector)).not.toHaveClass("active");
      });
    });
  });

  describe("tooltips", function() {
    describe("bindAll", function() {
      //Someone shorten this plz <3
      it("enumerates through the tooltips object, called the method 'bind' on any sibling that is not the bindAll method", function() {
        spyOn($, "noop");
        View.initialize();
        View.tooltips.myToolTip = { bind: $.noop };
        View.tooltips.bindAll();
        expect($.noop).toHaveBeenCalled();
      });
    });
  });

  describe("userMenu", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<ul id="user_menu">' +
          '<li>' +
            '<div class="right">' +
              '.' +
            '</div>' +
            '<div class="avatar">' +
              '<img alt="Jasmine Specson" class="avatar" title="Jasmine Specson">' +
            '</div>' +
            '<a href="#">Jasmine Specson</a>' +
          '</li>'+
        '</ul>'
      );
    });
    describe("click", function() {
      it("adds the class 'active' when the user clicks the ul", function() {
        View.initialize();
        $(View.userMenu.selector).click();
        expect($(View.userMenu.selector).parent()).toHaveClass("active");
      });
    });
    describe("removeFocus", function() {
      it("removes the class 'active' if the user clicks anywhere that isnt the userMenu", function() {
        View.initialize();
        $(View.userMenu.selector).click();
        expect($(View.userMenu.selector).parent()).toHaveClass("active");
        var event = $.Event("click");
        event.target = document.body;
        $(document.body).trigger(event);
        expect($(View.userMenu.selector).parent()).not.toHaveClass("active");
      });
    });
  });

  describe("webFingerForm", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<div class="span-7 last">' +
          '<h4>' +
            'Add a new contact' +
          '</h4>' +
          '<form accept-charset="UTF-8" action="/people/by_handle" class="webfinger_form" data-remote="true"  method="post">' +
            '<input name="diaspora_handle" placeholder="diaspora@handle.org" results="5" type="search" value="">' +
            '<input name="commit" type="submit" value="Find by Diaspora handle" class="button">' +
          '</form>' +

          '<div class="hidden" id="loader">' +
            '<img alt="Ajax-loader" src="/images/ajax-loader.gif?1290478032">' +
          '</div>' +
          '<ul id="request_result">' +
            '<li class="error hidden">' +
              '<div id="message">' +
                '<a href="/users/invitation/new">Know their email address? You should invite them</a>' +
              '</div>' +
            '</li>' +
          '</ul>' +
        '</div>'
      );

      // Prevent the form from being submitted
      $(View.webFingerForm.selector).submit(function(evt) { evt.preventDefault(); });
    });
    describe("submit", function() {
      it("shows the ajax loader after the user submits the form", function() {
        View.initialize();
        $(View.webFingerForm.selector).submit();
        expect($(View.webFingerForm.selector).siblings("#loader").css("display")).toEqual("block");
      });

      it("hides the first list item in the result ul after the user submits the form", function() {
        View.initialize();
        $(View.webFingerForm.selector).submit();
        expect($("#request_result li:first").css("display")).toEqual("none");
      });
    });
  });
});
