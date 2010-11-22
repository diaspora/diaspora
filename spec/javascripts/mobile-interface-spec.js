describe("mobile interface", function() {
  describe("initialize", function() {
    it("attaches a change event to the select box", function() {
      spyOn($.fn, 'change');
      Mobile.initialize();
      expect($.fn.change).toHaveBeenCalledWith(Mobile.changeAspect);
      expect($.fn.change.mostRecentCall.object.selector).toEqual("#aspect_picker");
    });
  });
  
  
  describe("change", function() {
    it("changes to the aspect show page", function() {
      $('#jasmine_content').html(
'<select id="aspect_picker" name="aspect_picker" tabindex="-1">' +
'   <option value="family-aspect-id">Family</option>' +
'   <option value="work-aspect-id">Work</option>' +
'</select>');
      spyOn(Mobile, "windowLocation");
      $.proxy(Mobile.changeAspect, $('#aspect_picker > option').first())()
      expect(Mobile.windowLocation).toHaveBeenCalledWith("/aspects/family-aspect-id");
    });
  });
});