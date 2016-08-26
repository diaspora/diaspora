describe("Keycodes", function() {
  it("sets the correct keycode for letters", function() {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("").forEach(function(c) {
      expect(String.fromCharCode(Keycodes[c])).toBe(c);
    });
  });

  it("sets the correct keycode for digits", function() {
    "0123456789".split("").forEach(function(c) {
      expect(String.fromCharCode(Keycodes[c])).toBe(c);
    });
  });
});
