/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("app.views.Publisher", function() {
  context("standalone", function() {
    beforeEach(function() {
      // TODO should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher({
        standalone: true
      });
    });

    it("hides the close button in standalone mode", function() {
      expect(this.view.$("#hide_publisher").is(":visible")).toBeFalsy();
    });

    it("hides the post preview button in standalone mode", function() {
      expect(this.view.$(".post_preview_button").is(":visible")).toBeFalsy();
    });

    it("hides the manage services link in standalone mode", function() {
      expect(this.view.$(".question_mark").is(":visible")).toBeFalsy();
    });

    describe("createStatusMessage", function(){
      it("doesn't add the status message to the stream", function() {
        app.stream = { addNow: $.noop };
        spyOn(app.stream, "addNow");
        this.view.createStatusMessage($.Event());
        jasmine.Ajax.requests.mostRecent().respondWith({ status: 200, responseText: "{\"id\": 1}" });
        expect(app.stream.addNow).not.toHaveBeenCalled();
      });
    });
  });

  context("plain publisher", function() {
    beforeEach(function() {
      // TODO should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe("#open", function() {
      it("removes the 'closed' class from the publisher element", function() {
        expect($(this.view.el)).toHaveClass("closed");
        this.view.open($.Event());
        expect($(this.view.el)).not.toHaveClass("closed");
      });

      it("won't open when disabled", function() {
        this.view.disabled = true;
        this.view.open($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      });
    });

    describe("#close", function() {
      beforeEach(function() {
        this.view.open($.Event());
      });

      it("removes the 'active' class from the publisher element", function(){
        this.view.close($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      });

      it("resets the element's height", function() {
        $(this.view.el).find("#status_message_fake_text").height(100);
        this.view.close($.Event());
        expect($(this.view.el).find("#status_message_fake_text").attr("style")).not.toContain("height");
      });
    });

    describe("#clear", function() {
      it("calls close", function(){
        spyOn(this.view, "close");

        this.view.clear($.Event());
        expect(this.view.close).toHaveBeenCalled();
      });

      it("calls removePostPreview", function(){
        spyOn(this.view, "removePostPreview");

        this.view.clear($.Event());
        expect(this.view.removePostPreview).toHaveBeenCalled();
      });

      it("clears all textareas", function(){
        _.each(this.view.$("textarea"), function(element){
          $(element).val('this is some stuff');
          expect($(element).val()).not.toBe("");
        });

        this.view.clear($.Event());

        _.each(this.view.$("textarea"), function(element){
          expect($(element).val()).toBe("");
        });
      });

      it("removes all photos from the dropzone area", function(){
        var self = this;
        _.times(3, function(){
          self.view.photozoneEl.append($("<li>"));
        });

        expect(this.view.photozoneEl.html()).not.toBe("");
        this.view.clear($.Event());
        expect(this.view.photozoneEl.html()).toBe("");
      });

      it("removes all photo values appended by the photo uploader", function(){
        $(this.view.el).prepend("<input name='photos[]' value='3'/>");
        var photoValuesInput = this.view.$("input[name='photos[]']");

        photoValuesInput.val("3");
        this.view.clear($.Event());
        expect(this.view.$("input[name='photos[]']").length).toBe(0);
      });

      it("destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});

        expect($("#location").length).toBe(1);
        this.view.clear($.Event());
        expect($("#location").length).toBe(0);
      });
    });

    describe("createStatusMessage", function(){
      it("calls handleTextchange to complete missing mentions", function(){
        spyOn(this.view, "handleTextchange");
        this.view.createStatusMessage($.Event());
        expect(this.view.handleTextchange).toHaveBeenCalled();
      });

      it("adds the status message to the stream", function() {
        app.stream = { addNow: $.noop };
        spyOn(app.stream, "addNow");
        this.view.createStatusMessage($.Event());
        jasmine.Ajax.requests.mostRecent().respondWith({ status: 200, responseText: "{\"id\": 1}" });
        expect(app.stream.addNow).toHaveBeenCalled();
      });
    });

    describe("createPostPreview", function(){
      beforeEach(function() {
        app.stream = { addNow: $.noop };
      });

      it("calls handleTextchange to complete missing mentions", function(){
        spyOn(this.view, "handleTextchange");
        this.view.createPostPreview($.Event());
        expect(this.view.handleTextchange).toHaveBeenCalled();
      });

      it("calls removePostPreview to remove the last preview", function(){
        spyOn(this.view, "removePostPreview");
        this.view.createPostPreview($.Event());
        expect(this.view.removePostPreview).toHaveBeenCalled();
      });

      it("adds the status message to the stream", function() {
        spyOn(app.stream, "addNow");
        this.view.createPostPreview($.Event());
        expect(app.stream.addNow).toHaveBeenCalled();
      });

      it("sets recentPreview", function(){
        expect(this.view.recentPreview).toBeUndefined();
        this.view.createPostPreview($.Event());
        expect(this.view.recentPreview).toBeDefined();
      });

      it("calls modifyPostPreview to apply the preview style to the post", function(){
        spyOn(this.view, "modifyPostPreview");
        this.view.createPostPreview($.Event());
        expect(this.view.modifyPostPreview).toHaveBeenCalled();
      });
    });

    describe('#setText', function() {
      it("sets the content text", function() {
        this.view.setText("FOO bar");

        expect(this.view.inputEl.val()).toEqual("FOO bar");
        expect(this.view.hiddenInputEl.val()).toEqual("FOO bar");
      });
    });

    describe('#setEnabled', function() {
      it("disables the publisher", function() {
        expect(this.view.disabled).toBeFalsy();
        this.view.setEnabled(false);

        expect(this.view.disabled).toBeTruthy();
        expect(this.view.inputEl.prop("disabled")).toBeTruthy();
        expect(this.view.hiddenInputEl.prop("disabled")).toBeTruthy();
      });

      it("disables submitting", function() {
        this.view.setText("TESTING");
        expect(this.view.submitEl.prop("disabled")).toBeFalsy();
        expect(this.view.previewEl.prop("disabled")).toBeFalsy();

        this.view.setEnabled(false);
        expect(this.view.submitEl.prop("disabled")).toBeTruthy();
        expect(this.view.previewEl.prop("disabled")).toBeTruthy();
      });
    });

    describe("publishing a post with keyboard", function(){
      it("should submit the form when ctrl+enter is pressed", function(){
        this.view.render();
        var form = this.view.$("form");
        var submitCallback = jasmine.createSpy().and.returnValue(false);
        form.submit(submitCallback);

        var e = $.Event("keydown", { keyCode: 13 });
        e.ctrlKey = true;
        this.view.keyDown(e);

        expect(submitCallback).toHaveBeenCalled();
        expect($(this.view.el)).not.toHaveClass("closed");
      });
    });

    describe("_beforeUnload", function(){
      beforeEach(function(){
        Diaspora.I18n.load({ confirm_unload: "Please confirm that you want to leave this page - data you have entered won't be saved."});
      });

      it("calls _submittable", function(){
        spyOn(this.view, "_submittable");
        $(window).trigger('beforeunload');
        expect(this.view._submittable).toHaveBeenCalled();
      });

      it("returns a confirmation if the publisher is submittable", function(){
        spyOn(this.view, "_submittable").and.returnValue(true);
        var e = $.Event();
        expect(this.view._beforeUnload(e)).toBe(Diaspora.I18n.t('confirm_unload'));
        expect(e.returnValue).toBe(Diaspora.I18n.t('confirm_unload'));
      });

      it("doesn't ask for a confirmation if the publisher isn't submittable", function(){
        spyOn(this.view, "_submittable").and.returnValue(false);
        var e = $.Event();
        expect(this.view._beforeUnload(e)).toBe(undefined);
        expect(e.returnValue).toBe(undefined);
      });
    });
  });

  context("services", function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
      this.view = new app.views.Publisher();
    });

    it("toggles the 'dim' class on a clicked item", function() {
      var first = $(".service_icon").eq(0);
      var second = $(".service_icon").eq(1);

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeFalsy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();
    });

    it("creates a counter element", function(){
      expect(this.view.$('.counter').length).toBe(0);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('.counter').length).toBe(1);
    });

    it("removes any old counters", function(){
      spyOn($.fn, "remove");
      $(".service_icon").first().trigger('click');
      expect($.fn.remove).toHaveBeenCalled();
    });

    it("toggles the hidden input field", function(){
      expect(this.view.$('input[name="services[]"]').length).toBe(0);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('input[name="services[]"]').length).toBe(1);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('input[name="services[]"]').length).toBe(0);
    });

    it("toggles the correct input", function() {
      var first = $(".service_icon").eq(0);
      var second = $(".service_icon").eq(1);

      first.trigger('click');
      second.trigger('click');

      expect(this.view.$('input[name="services[]"]').length).toBe(2);

      first.trigger('click');

      var prov1 = first.attr('id');
      var prov2 = second.attr('id');

      expect(this.view.$('input[name="services[]"][value="'+prov1+'"]').length).toBe(0);
      expect(this.view.$('input[name="services[]"][value="'+prov2+'"]').length).toBe(1);
    });

    describe("#clear", function() {
      it("resets the char counter", function() {
        this.view.$(".service_icon").first().trigger("click");
        expect(parseInt(this.view.$(".counter").text(), 10)).toBeGreaterThan(0);
        this.view.$(".counter").text("0");
        expect(parseInt(this.view.$(".counter").text(), 10)).not.toBeGreaterThan(0);
        this.view.clear($.Event());
        expect(parseInt(this.view.$(".counter").text(), 10)).toBeGreaterThan(0);
      });
    });
  });

  context("aspect selection", function(){
    beforeEach( function(){
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
      spec.loadFixture("status_message_new");
      Diaspora.I18n.load({ stream: { public: 'Public' }});

      this.viewAspectSelector = new app.views.PublisherAspectSelector({
        el: $(".public_toggle .aspect_dropdown"),
        form: $(".content_creation form")
      });

      this.view = new app.views.Publisher();
      this.view.open();
    });

    it("initializes with 'all_aspects'", function(){
      expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
      expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
    });

    describe("toggles the selected entry visually", function(){
      it("click on the first aspect", function(){
        this.view.$(".aspect_dropdown li.aspect_selector:first").click();
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
      });

      it("click on public", function(){
        this.view.$(".aspect_dropdown li.public").click();
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-lock");
      });

      it("click on 'all aspects'", function(){
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
      });
    });

    describe("hidden form elements", function(){
      beforeEach(function(){
        $('.dropdown-menu').append('<li data-aspect_id="42" class="aspect_selector" />');
      });

      it("removes a previous selection and inserts the current one", function() {
        var selected = $('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('all_aspects');

        var evt = $.Event("click", { target: $('.aspect_dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);

        selected = $('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('42');
      });

      it("toggles the same item", function() {
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(0);

        var evt = $.Event("click", { target: $('.aspect_dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(1);

        evt = $.Event("click", { target: $('.aspect_dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(0);
      });

      it("keeps other fields with different values", function() {
        $('.dropdown-menu').append('<li data-aspect_id="99" class="aspect_selector" />');
        var evt = $.Event("click", { target: $('.aspect_dropdown li.aspect_selector:eq(-2)') });
        this.view.viewAspectSelector.toggleAspect(evt);
        evt = $.Event("click", { target: $('.aspect_dropdown li.aspect_selector:eq(-1)') });
        this.view.viewAspectSelector.toggleAspect(evt);

        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(1);
        expect($('input[name="aspect_ids[]"][value="99"]').length).toBe(1);
      });
    });
  });

  context("locator", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe('#showLocation', function(){
      it("Show location", function(){

        // inserts location to the DOM; it is the location's view element
        setFixtures('<div id="location_container"></div>');

        // creates a fake Locator
        OSM = {};
        OSM.Locator = function(){return { getAddress:function(){}}};

        // validates there is not location
        expect($("#location").length).toBe(0);

        // this should create a new location
        this.view.showLocation();

        // validates there is one location created
        expect($("#location").length).toBe(1);
      });
    });

    describe('#destroyLocation', function(){
      it("Destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});
        this.view.destroyLocation();

        expect($("#location").length).toBe(0);
      });
    });

    describe('#avoidEnter', function(){
      it("Avoid submitting the form when pressing enter", function(){
        // simulates the event object
        var evt = {};
        evt.keyCode = 13;

        // should return false in order to avoid the form submition
        expect(this.view.avoidEnter(evt)).toBeFalsy();
      });
    });
  });

  context('uploader', function() {
    beforeEach(function() {
      jQuery.fx.off = true;
      setFixtures(
        '<div id="publisher">'+
        '  <div class="content_creation"><form>'+
        '    <div id="publisher_textarea_wrapper"></div>'+
        '    <div id="photodropzone"></div>'+
        '    <input type="submit" />'+
        '    <button class="post_preview_button" />'+
        '  </form></div>'+
        '</div>'
      );
    });

    it('initializes the file uploader plugin', function() {
      spyOn(qq, 'FileUploaderBasic');
      new app.views.Publisher();

      expect(qq.FileUploaderBasic).toHaveBeenCalled();
    });

    context('event handlers', function() {
      beforeEach(function() {
        this.view = new app.views.Publisher();

        // replace the uploader plugin with a dummy object
        var upload_view = this.view.viewUploader;
        this.uploader = {
          onProgress: _.bind(upload_view.progressHandler, upload_view),
          onSubmit:   _.bind(upload_view.submitHandler, upload_view),
          onComplete: _.bind(upload_view.uploadCompleteHandler, upload_view)
        };
        upload_view.uploader = this.uploader;
      });

      context('progress', function() {
        it('shows progress in percent', function() {
          this.uploader.onProgress(null, 'test.jpg', 20, 100);

          var info = this.view.viewUploader.info;
          expect(info.text()).toContain('test.jpg');
          expect(info.text()).toContain('20%');
        });
      });

      context('submitting', function() {
        beforeEach(function() {
          this.uploader.onSubmit(null, 'test.jpg');
        });

        it('adds a placeholder', function() {
          expect(this.view.wrapperEl.attr("class")).toContain("with_attachments");
          expect(this.view.photozoneEl.find("li").length).toBe(1);
        });

        it('disables the publisher buttons', function() {
          expect(this.view.submitEl.prop("disabled")).toBeTruthy();
          expect(this.view.previewEl.prop("disabled")).toBeTruthy();
        });
      });

      context('successful completion', function() {
        beforeEach(function() {
          Diaspora.I18n.load({ photo_uploader: { completed: '<%= file %> completed' }});
          $('#photodropzone').html('<li class="publisher_photo loading"><img src="" /></li>');

          this.uploader.onComplete(null, 'test.jpg', {
            data: { photo: {
              id: '987',
              unprocessed_image: { url: 'test.jpg' }
            }},
            success: true });
        });

        it('shows it in text form', function() {
          var info = this.view.viewUploader.info;
          expect(info.text()).toBe(Diaspora.I18n.t('photo_uploader.completed', {file: 'test.jpg'}));
        });

        it('adds a hidden input to the publisher', function() {
          var input = this.view.$('input[type="hidden"][value="987"][name="photos[]"]');
          expect(input.length).toBe(1);
        });

        it('replaces the placeholder', function() {
          var li  = this.view.photozoneEl.find("li");
          var img = li.find('img');

          expect(li.attr('class')).not.toContain('loading');
          expect(img.attr('src')).toBe('test.jpg');
          expect(img.attr('data-id')).toBe('987');
        });

        it('re-enables the buttons', function() {
          expect(this.view.submitEl.prop("disabled")).toBeFalsy();
          expect(this.view.previewEl.prop("disabled")).toBeFalsy();
        });
      });

      context('unsuccessful completion', function() {
        beforeEach(function() {
          Diaspora.I18n.load({ photo_uploader: { completed: '<%= file %> completed' }});
          $('#photodropzone').html('<li class="publisher_photo loading"><img src="" /></li>');

          this.uploader.onComplete(null, 'test.jpg', {
            data: { photo: {
              id: '987',
              unprocessed_image: { url: 'test.jpg' }
            }},
            success: false });
        });

        it('shows error message', function() {
          var info = this.view.viewUploader.info;
          expect(info.text()).toBe(Diaspora.I18n.t('photo_uploader.error', {file: 'test.jpg'}));
        });
      });
    });

    context('photo removal', function() {
      beforeEach(function() {
        this.view = new app.views.Publisher();
        this.view.wrapperEl.addClass("with_attachments");
        this.view.photozoneEl.html(
          "<li class=\"publisher_photo\">."+
          "  <img data-id=\"444\" />"+
          "  <div class=\"x\">X</div>"+
          "  <div class=\"circle\"></div>"+
          "</li>"
        );

        spyOn(jQuery, 'ajax').and.callFake(function(opts) { opts.success(); });
        this.view.photozoneEl.find(".x").click();
      });

      it('removes the element', function() {
        var photo = this.view.photozoneEl.find("li.publisher_photo");
        expect(photo.length).toBe(0);
      });

      it('sends an ajax request', function() {
        expect($.ajax).toHaveBeenCalled();
      });

      it('removes class on wrapper element', function() {
        expect(this.view.wrapperEl.attr("class")).not.toContain("with_attachments");
      });
    });
  });

});

