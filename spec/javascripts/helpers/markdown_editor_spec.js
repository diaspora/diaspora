describe("Diaspora.MarkdownEditor", function() {
  beforeEach(function() {
    spec.content().html("<textarea id='fake-textarea'></textarea>");
    this.$el = $("#fake-textarea");
  });

  describe("constructor", function() {
    it("calls initialize", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "initialize");
      new Diaspora.MarkdownEditor(this.$el, {});
      expect(Diaspora.MarkdownEditor.prototype.initialize).toHaveBeenCalledWith(this.$el, {});
    });
  });

  describe("initialize", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor($("<textarea></textarea>"), {});
    });

    it("calls localize", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "localize");
      this.target.initialize(this.$el, {});
      expect(Diaspora.MarkdownEditor.prototype.localize).toHaveBeenCalled();
    });

    it("calls onShow", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "onShow");
      this.target.initialize(this.$el, {});
      expect(Diaspora.MarkdownEditor.prototype.onShow).toHaveBeenCalled();
    });

    it("call $.fn.markdown with correct default options", function() {
      spyOn($.fn, "markdown");
      spyOn(autosize, "update");
      this.target.initialize(this.$el, {});
      expect($.fn.markdown).toHaveBeenCalled();
      var args = $.fn.markdown.calls.mostRecent().args[0];
      expect(args.resize).toBe("none");
      expect(args.language).toBe("en");
      expect(args.onHidePreview).toBe($.noop);
      expect(args.onPostPreview).toBe($.noop);
      expect(args.fullscreen).toEqual({enable: false, icons: {}});
      expect(args.hiddenButtons).toEqual(["cmdPreview"]);

      args.onChange({$textarea: "el"});
      expect(autosize.update).toHaveBeenCalledWith("el");
    });

    it("overrides fullscreen, hiddenButtons, language and onShow options", function() {
      spyOn($.fn, "markdown").and.callThrough();
      spyOn(Diaspora.MarkdownEditor.prototype, "onShow");
      spyOn(Diaspora.MarkdownEditor.prototype, "localize").and.callThrough();
      this.target.initialize(this.$el, {
        fullscreen: {enabled: true, icons: {somekey: "somevalue"}},
        hiddenButtons: [],
        language: "fr",
        onShow: $.noop
      });
      var args = $.fn.markdown.calls.mostRecent().args[0];
      expect(args.fullscreen).toEqual({enable: false, icons: {}});
      expect(args.hiddenButtons).toEqual(["cmdPreview"]);
      expect(args.language).toBe("en");
      expect(args.onShow).not.toBe($.noop);
      expect(Diaspora.MarkdownEditor.prototype.onShow).toHaveBeenCalled();
      expect(Diaspora.MarkdownEditor.prototype.localize).toHaveBeenCalled();
    });
  });

  describe("onShow", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {});
      this.$el.find(".md-header").remove(".write-preview-tabs");
      this.$el.find(".md-header").remove(".md-cancel");
    });

    it("retreives the $.fn.markdown instance back", function() {
      var fakeInstance = {$editor: $("body")};
      this.target.onShow(fakeInstance);
      expect(this.target.instance).toBe(fakeInstance);
    });

    it("calls createTabsElement createCloseElement if preview and close functions are given", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "createTabsElement");
      spyOn(Diaspora.MarkdownEditor.prototype, "createCloseElement");
      this.target.options.onPreview = $.noop;
      this.target.options.onClose = $.noop;
      this.target.onShow(this.target.instance);
      expect(Diaspora.MarkdownEditor.prototype.createTabsElement).toHaveBeenCalled();
      expect(Diaspora.MarkdownEditor.prototype.createCloseElement).toHaveBeenCalled();
    });

    it("does not call createTabsElement createCloseElement if no preview and close functions are given", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "createTabsElement");
      spyOn(Diaspora.MarkdownEditor.prototype, "createCloseElement");
      delete this.target.options.onPreview;
      delete this.target.options.onClose;
      this.target.onShow(this.target.instance);
      expect(Diaspora.MarkdownEditor.prototype.createCloseElement).not.toHaveBeenCalled();
      expect(Diaspora.MarkdownEditor.prototype.createTabsElement).not.toHaveBeenCalled();
    });

    it("creates the preview and write tabs", function() {
      this.target.options.onPreview = $.noop;
      this.target.onShow(this.target.instance);
      expect($(".md-header .write-preview-tabs").length).toBe(1);
    });

    it("removes preview tabs if already existing", function() {
      this.target.options.onPreview = $.noop;
      this.$el.find(".md-header").prepend("<div id='fake-write-preview-tabs' class='write-preview-tabs'/>");
      this.target.onShow(this.target.instance);
      expect($(".md-header .write-preview-tabs").length).toBe(1);
      expect($("#fake-write-preview-tabs").length).toBe(0);
    });

    it("creates the cancel button", function() {
      this.target.options.onClose = $.noop;
      this.target.onShow(this.target.instance);
      expect($(".md-header .md-cancel").length).toBe(1);
    });

    it("removes cancel button if already existing", function() {
      this.target.options.onClose = $.noop;
      this.$el.find(".md-header").prepend("<div id='fake-md-cancel' class='md-cancel'/>");
      this.target.onShow(this.target.instance);
      expect($(".md-header .md-cancel").length).toBe(1);
      expect($("#fake-md-cancel").length).toBe(0);
    });
  });

  describe("createTabsElement", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {});
    });

    it("correctly creates the preview tabs", function() {
      var tabsElement = this.target.createTabsElement();
      expect(tabsElement).toHaveClass("write-preview-tabs");
      expect(tabsElement.find("> li > a.md-write-tab").attr("title")).toBe("Edit message");
      expect(tabsElement.find("> li > a.md-write-tab > i.diaspora-custom-compose").length).toBe(1);
      expect(tabsElement.find("> li > a.md-write-tab > span.tab-help-text").length).toBe(1);
      expect(tabsElement.find("> li > a.md-write-tab > span.tab-help-text").text()).toBe("Write");
      expect(tabsElement.find("> li > a.md-preview-tab").attr("title")).toBe("Preview message");
      expect(tabsElement.find("> li > a.md-preview-tab > i.entypo-search").length).toBe(1);
      expect(tabsElement.find("> li > a.md-preview-tab > span.tab-help-text").length).toBe(1);
      expect(tabsElement.find("> li > a.md-preview-tab > span.tab-help-text").text()).toBe("Preview");
    });

    it("correctly binds onclick events", function() {
      var tabsElement = this.target.createTabsElement();
      spyOn(Diaspora.MarkdownEditor.prototype, "hidePreview");
      spyOn(Diaspora.MarkdownEditor.prototype, "showPreview");
      tabsElement.find("> li > a.md-write-tab").click();
      expect(Diaspora.MarkdownEditor.prototype.hidePreview).toHaveBeenCalled();
      tabsElement.find("> li > a.md-preview-tab").click();
      expect(Diaspora.MarkdownEditor.prototype.showPreview).toHaveBeenCalled();
    });
  });

  describe("createCloseElement", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {});
    });

    it("correctly creates the close button", function() {
      var closeElement = this.target.createCloseElement();
      expect(closeElement).toHaveClass("md-cancel");
      expect(closeElement.get(0).tagName).toBe("A");
      expect(closeElement.attr("title")).toBe("Cancel message");
      expect(closeElement.find("> i.entypo-cross").length).toBe(1);
    });

    it("correctly binds onclick events", function() {
      this.target.options.onClose = jasmine.createSpy();
      var closeElement = this.target.createCloseElement();
      closeElement.click();
      expect(this.target.options.onClose).toHaveBeenCalled();
    });
  });

  describe("hidePreview", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {onPreview: $.noop, onHidePreview: jasmine.createSpy()});
      spyOn(this.target.instance, "hidePreview");
      spyOn(this.target.writeLink, "tab");
    });

    it("calls writeLink.tab", function() {
      this.target.hidePreview();
      expect(this.target.writeLink.tab).toHaveBeenCalledWith("show");
    });

    it("calls instance.hidePreview", function() {
      this.target.hidePreview();
      expect(this.target.instance.hidePreview).toHaveBeenCalled();
    });

    it("calls instance.onHidePreview", function() {
      this.target.hidePreview();
      expect(this.target.options.onHidePreview).toHaveBeenCalled();
    });
  });

  describe("showPreview", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {onPreview: $.noop, onPostPreview: jasmine.createSpy()});
      spyOn(this.target.instance, "showPreview");
      spyOn(this.target.previewLink, "tab");
    });

    it("calls previewLink.tab", function() {
      this.target.showPreview();
      expect(this.target.previewLink.tab).toHaveBeenCalledWith("show");
    });

    it("calls instance.showPreview", function() {
      this.target.showPreview();
      expect(this.target.instance.showPreview).toHaveBeenCalled();
    });

    it("calls instance.onPostPreview", function() {
      this.target.showPreview();
      expect(this.target.options.onPostPreview).toHaveBeenCalled();
    });
  });

  describe("isPreviewMode", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {onPreview: $.noop, onPostPreview: $.noop()});
    });

    it("return false if editor is not visible yet", function() {
      this.target.instance = undefined;
      expect(this.target.isPreviewMode()).toBe(false);
    });

    it("returns false if the editor is in write (default) mode", function() {
      expect(this.target.instance).toBeDefined();
      expect(this.target.isPreviewMode()).toBe(false);
    });

    it("returns true if editor is in preview mode", function() {
      this.target.showPreview();
      expect(this.target.isPreviewMode()).toBe(true);
    });
  });

  describe("userInputEmpty", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {onPreview: $.noop, onPostPreview: $.noop()});
    });

    it("return true if editor is not visible yet", function() {
      this.target.instance = undefined;
      expect(this.target.userInputEmpty()).toBe(true);
    });

    it("returns true if editor has no content", function() {
      $("textarea").text("");
      expect(this.target.userInputEmpty()).toBe(true);
    });

    it("returns false if editor has content", function() {
      $("textarea").text("Yolo");
      expect(this.target.userInputEmpty()).toBe(false);
    });
  });

  describe("localize", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {});
    });

    it("returns the correct locale", function() {
      expect(this.target.localize()).toBe(Diaspora.I18n.language);
    });

    it("creates translation messages for the current locale", function() {
      this.target.localize();
      expect($.fn.markdown.messages[Diaspora.I18n.language]).toBeDefined();
    });
  });

  describe("simplePreview", function() {
    beforeEach(function() {
      this.target = new Diaspora.MarkdownEditor(this.$el, {});
    });

    it("generates HTML for preview", function() {
      spyOn(app.helpers, "textFormatter").and.callThrough();
      this.$el[0].value = "<p>hello</p>";
      var res = Diaspora.MarkdownEditor.simplePreview(this.target.instance);
      expect(app.helpers.textFormatter).toHaveBeenCalledWith("<p>hello</p>");
      expect(res).toBe("<div class='preview-content'><p>hello</p></div>");
    });
  });
});
