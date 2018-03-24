
describe("app.views.PodEntry", function() {
  beforeEach(function() {
    this.pod = factory.pod();
    this.view = new app.views.PodEntry({
      model: this.pod,
      parent: document.createDocumentFragment()
    });
  });

  describe("className", function() {
    it("returns danger bg when offline", function() {
      this.pod.set("offline", true);
      expect(this.view.className()).toEqual("bg-danger");
    });

    it("returns warning bg when version unknown", function() {
      this.pod.set("status", "version_failed");
      expect(this.view.className()).toEqual("bg-warning");
    });

    it("returns success bg for no errors", function() {
      this.pod.set("status", "no_errors");
      expect(this.view.className()).toEqual("bg-success");
    });
  });

  describe("presenter", function() {
    it("contains calculated attributes", function() {
      this.pod.set({
        status: "no_errors",
        ssl: true,
        host: "pod.example.com"
      });
      var actual = this.view.presenter();
      expect(actual).toEqual(jasmine.objectContaining({
        /* jshint camelcase: false */
        is_unchecked: false,
        has_no_errors: true,
        has_errors: false,
        status_text: jasmine.anything(),
        response_time_fmt: jasmine.anything(),
        pod_url: "https://pod.example.com"
        /* jshint camelcase: true */
      }));
    });
  });

  describe("postRenderTemplate", function() {
    it("appends itself to the parent", function() {
      var childCount = $(this.view.parent).children().length;
      this.view.render();
      expect($(this.view.parent).children().length).toEqual(childCount+1);
    });
  });

  describe("recheckPod", function() {
    var ajaxSuccess = { status: 200, responseText: "{}" };
    var ajaxFail = { status: 400 };
    beforeEach(function(){
      this.view.render();
      this.view.$el.append($("<div id='flash-container'/>"));
      app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
    });

    it("calls .recheck() on the model", function() {
      spyOn(this.pod, "recheck").and.returnValue($.Deferred());
      this.view.recheckPod();
      expect(this.pod.recheck).toHaveBeenCalled();
    });

    it("renders a success flash message", function() {
      this.view.recheckPod();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.view.$(".flash-message")).toBeSuccessFlashMessage();
    });

    it("renders an error flash message", function() {
      this.view.recheckPod();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxFail);
      expect(this.view.$(".flash-message")).toBeErrorFlashMessage();
    });

    it("sets the appropriate CSS class", function() {
      this.view.$el.addClass("bg-danger");
      this.pod.set({ offline: false, status: "no_errors" });

      this.view.recheckPod();
      expect(this.view.$el.attr("class")).toContain("checking");
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.view.$el.attr("class")).toContain("bg-success");
      expect(this.view.$el.attr("class")).not.toContain("checking");
      expect(this.view.$el.attr("class")).not.toContain("bg-danger");
    });
  });
});
