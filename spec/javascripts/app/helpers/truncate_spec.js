describe("app.helpers.truncate", function() {
  it("handles null values", function() {
    expect(app.helpers.truncate(null, 123)).toEqual(null);
  });

  it("handles undefined", function() {
    expect(app.helpers.truncate(undefined, 123)).toEqual(undefined);
  });

  it("returns a short string", function() {
    expect(app.helpers.truncate("Some text", 10)).toEqual("Some text");
  });

  it("trims a long string at a space", function() {
    expect(app.helpers.truncate("Some very long text", 10)).toEqual("Some very ...");
  });

  it("returns a string", function() {
    expect(typeof app.helpers.truncate("Some very long text", 10)).toEqual("string");
  });
});
