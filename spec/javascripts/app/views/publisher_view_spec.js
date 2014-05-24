/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("app.views.Publisher", function() {
  describe("standalone", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher({
        standalone: true
      });
    });

    it("hides the close button in standalone mode", function() {
      expect(this.view.$('#hide_publisher').is(':visible')).toBeFalsy();
    });

    it("hides the post preview button in standalone mode", function() {
      expect(this.view.$('.post_preview_button').is(':visible')).toBeFalsy();
    });
  });

  context("plain publisher", function() {
    beforeEach(function() {
      // should be jasmine helper
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
      })

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
      })

      it("calls removePostPreview", function(){
        spyOn(this.view, "removePostPreview");

        this.view.clear($.Event());
        expect(this.view.removePostPreview).toHaveBeenCalled();
      })

      it("clears all textareas", function(){
        _.each(this.view.$("textarea"), function(element){
          $(element).val('this is some stuff');
          expect($(element).val()).not.toBe("");
        });

        this.view.clear($.Event());

        _.each(this.view.$("textarea"), function(element){
          expect($(element).val()).toBe("");
        });
      })

      it("removes all photos from the dropzone area", function(){
        var self = this;
        _.times(3, function(){
          self.view.el_photozone.append($("<li>"))
        });

        expect(this.view.el_photozone.html()).not.toBe("");
        this.view.clear($.Event());
        expect(this.view.el_photozone.html()).toBe("");
      })

      it("removes all photo values appended by the photo uploader", function(){
        $(this.view.el).prepend("<input name='photos[]' value='3'/>")
        var photoValuesInput = this.view.$("input[name='photos[]']");

        photoValuesInput.val("3")
        this.view.clear($.Event());
        expect(this.view.$("input[name='photos[]']").length).toBe(0);
      })

      it("destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});

        expect($("#location").length).toBe(1);
        this.view.clear($.Event());
        expect($("#location").length).toBe(0);
      })
    });

    describe("createStatusMessage", function(){
      it("calls handleTextchange to complete missing mentions", function(){
        spyOn(this.view, "handleTextchange");
        this.view.createStatusMessage($.Event());
        expect(this.view.handleTextchange).toHaveBeenCalled();
      })
    });

    describe('#setText', function() {
      it('sets the content text', function() {
        this.view.setText('FOO bar');

        expect(this.view.el_input.val()).toEqual('FOO bar');
        expect(this.view.el_hiddenInput.val()).toEqual('FOO bar');
      });
    });

    describe('#setEnabled', function() {
      it('disables the publisher', function() {
        expect(this.view.disabled).toBeFalsy();
        this.view.setEnabled(false);

        expect(this.view.disabled).toBeTruthy();
        expect(this.view.el_input.prop('disabled')).toBeTruthy();
        expect(this.view.el_hiddenInput.prop('disabled')).toBeTruthy();
      });

      it("disables submitting", function() {
        this.view.togglePollCreator();

        this.view.setText('TESTING');
        expect(this.view.el_submit.prop('disabled')).toBeFalsy();
        expect(this.view.el_preview.prop('disabled')).toBeFalsy();

        this.view.setEnabled(false);
        expect(this.view.el_submit.prop('disabled')).toBeTruthy();
        expect(this.view.el_preview.prop('disabled')).toBeTruthy();
      });
    });

    describe("publishing a post with keyboard", function(){
      it("should submit the form when ctrl+enter is pressed", function(){
        this.view.render();
        var form = this.view.$("form")
        var submitCallback = jasmine.createSpy().andReturn(false);
        form.submit(submitCallback);

        var e = $.Event("keydown", { keyCode: 13 });
        e.ctrlKey = true;
        this.view.keyDown(e);

        expect(submitCallback).toHaveBeenCalled();
        expect($(this.view.el)).not.toHaveClass("closed");
      })
    })
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
  });

  context("aspect selection", function(){
    beforeEach( function(){
      spec.loadFixture('status_message_new');

      this.radio_els = $('#publisher .dropdown li.radio');
      this.check_els = $('#publisher .dropdown li.aspect_selector');

      this.view = new app.views.Publisher();
      this.view.open();
    });

    it("initializes with 'all_aspects'", function(){
      expect(this.radio_els.first().hasClass('selected')).toBeFalsy();
      expect(this.radio_els.last().hasClass('selected')).toBeTruthy();

      _.each(this.check_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });
    });

    it("toggles the selected entry visually", function(){
      this.check_els.last().trigger('click');

      _.each(this.radio_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });

      expect(this.check_els.first().hasClass('selected')).toBeFalsy();
      expect(this.check_els.last().hasClass('selected')).toBeTruthy();
    });

    describe("hidden form elements", function(){
      beforeEach(function(){
        this.li = $('<li data-aspect_id="42" />');
        this.view.$('.dropdown_list').append(this.li);
      });

      it("removes a previous selection and inserts the current one", function() {
        var selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('all_aspects');

        this.li.trigger('click');

        selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('42');
      });

      it("toggles the same item", function() {
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(0);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(1);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(0);
      });

      it("keeps other fields with different values", function() {
        var li2 = $("<li data-aspect_id=99></li>");
        this.view.$('.dropdown_list').append(li2);

        this.li.trigger('click');
        li2.trigger('click');

        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(1);
        expect(this.view.$('input[name="aspect_ids[]"][value="99"]').length).toBe(1);
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
      })
    });

    describe('#destroyLocation', function(){
      it("Destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});
        this.view.destroyLocation();

        expect($("#location").length).toBe(0);
      })
    });

    describe('#avoidEnter', function(){
      it("Avoid submitting the form when pressing enter", function(){
        // simulates the event object
        evt = {};
        evt.keyCode = 13;

        // should return false in order to avoid the form submition
        expect(this.view.avoidEnter(evt)).toBeFalsy();
      })
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
      var publisher = new app.views.Publisher();

      expect(qq.FileUploaderBasic).toHaveBeenCalled();
    });

    context('event handlers', function() {
      beforeEach(function() {
        this.view = new app.views.Publisher();

        // replace the uploader plugin with a dummy object
        var upload_view = this.view.view_uploader;
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

          var info = this.view.view_uploader.el_info;
          expect(info.text()).toContain('test.jpg');
          expect(info.text()).toContain('20%');
        });
      });

      context('submitting', function() {
        beforeEach(function() {
          this.uploader.onSubmit(null, 'test.jpg');
        });

        it('adds a placeholder', function() {
          expect(this.view.el_wrapper.attr('class')).toContain('with_attachments');
          expect(this.view.el_photozone.find('li').length).toBe(1);
        });

        it('disables the publisher buttons', function() {
          expect(this.view.el_submit.prop('disabled')).toBeTruthy();
          expect(this.view.el_preview.prop('disabled')).toBeTruthy();
        });
      });

      context('successful completion', function() {
        beforeEach(function() {
          Diaspora.I18n.loadLocale({ photo_uploader: { completed: '<%= file %> completed' }});
          $('#photodropzone').html('<li class="publisher_photo loading"><img src="" /></li>');

          this.uploader.onComplete(null, 'test.jpg', {
            data: { photo: {
              id: '987',
              unprocessed_image: { url: 'test.jpg' }
            }},
            success: true });
        });

        it('shows it in text form', function() {
          var info = this.view.view_uploader.el_info;
          expect(info.text()).toBe(Diaspora.I18n.t('photo_uploader.completed', {file: 'test.jpg'}))
        });

        it('adds a hidden input to the publisher', function() {
          var input = this.view.$('input[type="hidden"][value="987"][name="photos[]"]');
          expect(input.length).toBe(1);
        });

        it('replaces the placeholder', function() {
          var li  = this.view.el_photozone.find('li');
          var img = li.find('img');

          expect(li.attr('class')).not.toContain('loading');
          expect(img.attr('src')).toBe('test.jpg');
          expect(img.attr('data-id')).toBe('987');
        });

        it('re-enables the buttons', function() {
          expect(this.view.el_submit.prop('disabled')).toBeFalsy();
          expect(this.view.el_preview.prop('disabled')).toBeFalsy();
        });
      });

      context('unsuccessful completion', function() {
        beforeEach(function() {
          Diaspora.I18n.loadLocale({ photo_uploader: { completed: '<%= file %> completed' }});
          $('#photodropzone').html('<li class="publisher_photo loading"><img src="" /></li>');

          this.uploader.onComplete(null, 'test.jpg', {
            data: { photo: {
              id: '987',
              unprocessed_image: { url: 'test.jpg' }
            }},
            success: false });
        });

        it('shows error message', function() {
          var info = this.view.view_uploader.el_info;
          expect(info.text()).toBe(Diaspora.I18n.t('photo_uploader.error', {file: 'test.jpg'}))
        });
      });
    });

    context('photo removal', function() {
      beforeEach(function() {
        this.view = new app.views.Publisher();
        this.view.el_wrapper.addClass('with_attachments');
        this.view.el_photozone.html(
          '<li class="publisher_photo">.'+
          '  <img data-id="444" />'+
          '  <div class="x">X</div>'+
          '  <div class="circle"></div>'+
          '</li>'
        );

        spyOn(jQuery, 'ajax').andCallFake(function(opts) { opts.success(); });
        this.view.el_photozone.find('.x').click();
      });

      it('removes the element', function() {
        var photo = this.view.el_photozone.find('li.publisher_photo');
        expect(photo.length).toBe(0);
      });

      it('sends an ajax request', function() {
        expect($.ajax).toHaveBeenCalled();
      });

      it('removes class on wrapper element', function() {
        expect(this.view.el_wrapper.attr('class')).not.toContain('with_attachments');
      });
    });
  });

});

