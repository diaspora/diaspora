describe("app.pages.AdminDashboard", function(){
  beforeEach(function() {
    spec.loadFixture("admin_dashboard");
    this.view = new app.pages.AdminDashboard();
    gon.podVersion = "0.5.1.2";
  });

  describe("initialize" , function() {
    it("calls updatePodStatus", function() {
      spyOn(this.view, "updatePodStatus");
      this.view.initialize();
      expect(this.view.updatePodStatus).toHaveBeenCalled();
    });
  });

  describe("updatePodStatus" , function() {
    it("sends an ajax request to the github API", function() {
      this.view.updatePodStatus();
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(
        "https://api.github.com/repos/diaspora/diaspora/releases/latest"
      );
    });

    it("calls updatePodStatusFail on a failed request", function() {
      spyOn(this.view, "updatePodStatusFail");
      this.view.updatePodStatus();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(this.view.updatePodStatusFail).toHaveBeenCalled();
    });

    it("calls updatePodStatusFail on a malformed response", function() {
      spyOn(this.view, "updatePodStatusFail");
      spyOn(this.view, "podUpToDate").and.returnValue(true);
      var responses = [
        // no object
        "text",
        // object without tag_name
        "{\"tag\": 0}",
        // tag_name not a string
        "{\"tag_name\": 0}",
        "{\"tag_name\": {\"id\": 0}}",
        // tag_name doesn't start with "v"
        "{\"tag_name\": \"0.5.1.2\"}"
      ];

      for(var i = 0; i < responses.length; i++) {
        this.view.updatePodStatus();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: responses[i]
        });
        expect(this.view.updatePodStatusFail.calls.count()).toEqual(i+1);
      }
    });

    it("sets latestVersion on a correct response", function() {
      this.view.updatePodStatus();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: "{\"tag_name\": \"v0.5.1.2\"}"
      });
      expect(this.view.latestVersion).toEqual([0,5,1,2]);
    });

    it("calls podUpToDate on a correct response", function() {
      spyOn(this.view, "podUpToDate");
      this.view.updatePodStatus();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: "{\"tag_name\": \"v0.5.1.2\"}"
      });
      expect(this.view.podUpToDate).toHaveBeenCalled();
    });

    it("calls updatePodStatusFail if podUpToDate returns null", function() {
      spyOn(this.view, "updatePodStatusFail");
      spyOn(this.view, "podUpToDate").and.returnValue(null);
      this.view.updatePodStatus();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: "{\"tag_name\": \"v0.5.1.2\"}"
      });
      expect(this.view.updatePodStatusFail).toHaveBeenCalled();
    });

    it("calls updatePodStatusSuccess if podUpToDate returns a Boolean", function() {
      spyOn(this.view, "updatePodStatusSuccess");
      spyOn(this.view, "podUpToDate").and.returnValue(false);
      this.view.updatePodStatus();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: "{\"tag_name\": \"v0.5.1.2\"}"
      });
      expect(this.view.updatePodStatusSuccess).toHaveBeenCalled();
    });
  });

  describe("podUpToDate" , function() {
    it("returns null if latestVersion is not long enough", function() {
      this.view.latestVersion = [0, 5, 1];
      expect(this.view.podUpToDate()).toBeNull();
    });

    it("returns true if the pod is up to date", function() {
      var self = this;
      [
        {latest: "0.5.1.2", pod: "0.5.1.2"},
        {latest: "0.5.1.2", pod: "0.5.1.2-abcdefg"},
        {latest: "0.5.1.2", pod: "0.5.1.2-2"},
        {latest: "0.5.1.2", pod: "0.5.1.3"},
        {latest: "0.5.1.2", pod: "0.5.2.1"},
        {latest: "0.5.1.2", pod: "0.6.0.0"},
        {latest: "0.5.1.2", pod: "2.0.0.0"}
      ].forEach(function(version) {
        gon.podVersion = version.pod;
        self.view.latestVersion = version.latest.split(".").map(Number);
        expect(self.view.podUpToDate()).toBeTruthy();
      });
    });

    it("returns false if the pod is outdated", function() {
      var self = this;
      [
        {latest: "0.5.1.2", pod: "0.5.1.1"},
        {latest: "0.5.1.2", pod: "0.5.1.1-abcdefg"},
        {latest: "0.5.1.2", pod: "0.5.1.1-2"},
        {latest: "0.5.1.2", pod: "0.4.99.4"},
        {latest: "2.0.3.5", pod: "1.99.2.1"}
      ].forEach(function(version) {
        gon.podVersion = version.pod;
        self.view.latestVersion = version.latest.split(".").map(Number);
        expect(self.view.podUpToDate()).toBeFalsy();
      });
    });
  });

  describe("updatePodStatusSuccess", function() {
    it("adds a 'success' alert if the pod is up to date", function() {
      spyOn(this.view, "podUpToDate").and.returnValue(true);
      this.view.latestVersion = [0, 5, 1, 1];
      this.view.updatePodStatusSuccess();
      expect($("#pod-status .alert.pod-version")).toHaveClass("alert-success");
      expect($("#pod-status .alert.pod-version").text()).toContain("up to date");
      expect($("#pod-status .alert.pod-version").text()).toContain("release is v0.5.1.1");
      expect($("#pod-status .alert.pod-version").text()).toContain("pod is running v0.5.1.2");
    });

    it("adds a 'danger' alert if the pod is up to date", function() {
      spyOn(this.view, "podUpToDate").and.returnValue(false);
      this.view.latestVersion = [0, 5, 1, 3];
      this.view.updatePodStatusSuccess();
      expect($("#pod-status .alert.pod-version")).toHaveClass("alert-danger");
      expect($("#pod-status .alert.pod-version").text()).toContain("outdated");
      expect($("#pod-status .alert.pod-version").text()).toContain("release is v0.5.1.3");
      expect($("#pod-status .alert.pod-version").text()).toContain("pod is running v0.5.1.2");
    });
  });

  describe("updatePodStatusFail", function() {
    it("adds a 'warning' alert", function() {
      this.view.updatePodStatusFail();
      expect($("#pod-status .alert.pod-version")).toHaveClass("alert-warning");
      expect($("#pod-status .alert.pod-version").text()).toContain("Unable to determine");
    });
  });
});
