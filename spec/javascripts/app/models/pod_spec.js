describe("app.model.Pod", function() {
  var podId = 123;

  beforeEach(function() {
    this.pod = new app.models.Pod({
      id: podId,
      host: "pod.example.com",
      status: "unchecked",
      /* jshint camelcase: false */
      checked_at: null
      /* jshint camelcase: true */
    });
  });

  describe("recheck", function() {
    var newAttributes = {
      id: podId,
      status: "no_errors",
      /* jshint camelcase: false */
      checked_at: new Date()
      /* jshint camelcase: true */
    };
    var ajaxSuccess = {
      status: 200,
      responseText: JSON.stringify(newAttributes)
    };

    it("calls the recheck action on the server", function() {
      var expected = Routes.adminPodRecheck(podId);
      this.pod.recheck();
      expect(jasmine.Ajax.requests.mostRecent().url).toEqual(expected);
    });

    it("updates the model attributes from the response", function() {
      spyOn(this.pod, "set").and.callThrough();
      expect(this.pod.get("status")).toEqual("unchecked");
      this.pod.recheck();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);

      expect(this.pod.set).toHaveBeenCalled();
      expect(this.pod.get("status")).toEqual("no_errors");
      expect(this.pod.get("checked_at")).not.toEqual(null);
    });
  });
});
