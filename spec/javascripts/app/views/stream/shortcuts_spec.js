describe("app.views.StreamShortcuts", function () {

  beforeEach(function() {
    this.post1 = factory.post({author : factory.author({name : "Rebecca Black", id : 1492})});
    this.post2 = factory.post({author : factory.author({name : "John Stamos", id : 1987})});

    this.stream = new app.models.Stream();
    this.stream.add([this.post1, this.post2]);
    this.view = new app.views.Stream({model : this.stream});

    this.view.render();
    expect(this.view.$('div.stream_element.loaded').length).toBe(2);
  });

  describe("loading the stream", function(){
    it("should setup the shortcuts", function(){
      spyOn(this.view, 'setupShortcuts');
      this.view.initialize();
      expect(this.view.setupShortcuts).toHaveBeenCalled();
    });
  });

  describe("pressing 'j'", function(){

    it("should call 'gotoNext' if not pressed in an input field", function(){
      spyOn(this.view, 'gotoNext');
      this.view.initialize();
      var e = $.Event("keydown", { which: 74, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('j');
      this.view._onHotkeyDown(e);
      expect(this.view.gotoNext).toHaveBeenCalled();
    });

    it("'gotoNext' should call 'selectPost'", function(){
      spyOn(this.view, 'selectPost');
      this.view.gotoNext();
      expect(this.view.selectPost).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'gotoNext');
      spyOn(this.view, 'selectPost');
      this.view.initialize();
      var e = $.Event("keydown", { which: 74, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('j');
      this.view._onHotkeyDown(e);
      expect(this.view.gotoNext).not.toHaveBeenCalled();
      expect(this.view.selectPost).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'k'", function(){

    it("should call 'gotoPrev' if not pressed in an input field", function(){
      spyOn(this.view, 'gotoPrev');
      this.view.initialize();
      var e = $.Event("keydown", { which: 75, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('k');
      this.view._onHotkeyDown(e);
      expect(this.view.gotoPrev).toHaveBeenCalled();
    });

    it("'gotoPrev' should call 'selectPost'", function(){
      spyOn(this.view, 'selectPost');
      this.view.gotoPrev();
      expect(this.view.selectPost).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'gotoPrev');
      spyOn(this.view, 'selectPost');
      this.view.initialize();
      var e = $.Event("keydown", { which: 75, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('k');
      this.view._onHotkeyDown(e);
      expect(this.view.gotoPrev).not.toHaveBeenCalled();
      expect(this.view.selectPost).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'c'", function(){

    it("should click on the comment-button if not pressed in an input field", function(){
      spyOn(this.view, 'commentSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 67, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('c');
      this.view._onHotkeyUp(e);
      expect(this.view.commentSelected).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'commentSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 67, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('c');
      this.view._onHotkeyUp(e);
      expect(this.view.commentSelected).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'l'", function(){

    it("should click on the like-button if not pressed in an input field", function(){
      spyOn(this.view, 'likeSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 76, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('l');
      this.view._onHotkeyUp(e);
      expect(this.view.likeSelected).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'likeSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 76, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('l');
      this.view._onHotkeyUp(e);
      expect(this.view.likeSelected).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'r'", function(){

    it("should click on the reshare-button if not pressed in an input field", function(){
      spyOn(this.view, 'reshareSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 82, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('r');
      this.view._onHotkeyUp(e);
      expect(this.view.reshareSelected).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'reshareSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 82, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('r');
      this.view._onHotkeyUp(e);
      expect(this.view.reshareSelected).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'm'", function(){

    it("should click on the more-button if not pressed in an input field", function(){
      spyOn(this.view, 'expandSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 77, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('m');
      this.view._onHotkeyUp(e);
      expect(this.view.expandSelected).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'expandSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 77, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('m');
      this.view._onHotkeyUp(e);
      expect(this.view.expandSelected).not.toHaveBeenCalled();
    });
  });

  describe("pressing 'o'", function(){

    it("should click on the more-button if not pressed in an input field", function(){
      spyOn(this.view, 'openFirstLinkSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 79, target: {type: "div"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('o');
      this.view._onHotkeyUp(e);
      expect(this.view.openFirstLinkSelected).toHaveBeenCalled();
    });

    it("shouldn't do anything if the user types in an input field", function(){
      spyOn(this.view, 'openFirstLinkSelected');
      this.view.initialize();
      var e = $.Event("keyup", { which: 79, target: {type: "textarea"} });
      //verify that the test is correct
      expect(String.fromCharCode( e.which ).toLowerCase()).toBe('o');
      this.view._onHotkeyUp(e);
      expect(this.view.openFirstLinkSelected).not.toHaveBeenCalled();
    });
  });
});
