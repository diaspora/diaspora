describe("app.views.Notification", function(){
  var pageText = null;


  describe("render regular notifications", function(){
    beforeEach(function(){
      pageText = spec.readFixture("notifications_index");
    });

    it("has two notifications", function(){
      expect( $( pageText ).find('.stream_element').length).toBe(2)
    });
    it("has no aspects menu", function(){
      expect( $( pageText ).find('.dropdown_list').length).toBe(0)
    });

  });
  describe("render a start sharing notification", function(){
    beforeEach(function(){
      pageText = spec.readFixture("notifications_index_with_sharing");
    });

    it("has three notifications", function(){
      expect( $( pageText ).find('.stream_element').length).toBe(3)
    });
    it("has shows an aspect menu for the start sharing item", function(){
      expect( $( pageText ).find('.aspect_membership').length).toBe(1)
    });
  });
})
