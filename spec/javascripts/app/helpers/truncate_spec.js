describe("app.helpers.truncate", function() {
  it("handles null values", function() {
    expect(app.helpers.truncate(null, 123)).toEqual(null);
  });

  it("handles undefined", function() {
    expect(app.helpers.truncate(undefined, 123)).toEqual(undefined);
  });
});
