describe("app.helpers.timeago", function() {
  beforeEach(function(){
    this.date = '2015-02-08T13:37:42.000Z';
    this.datestring = new Date(this.date).toLocaleString();
    var html = '<time class="timeago" datetime="' + this.date + '"></time>';
    this.content = spec.content().html(html);
  });

  it("converts the date into a locale string for the tooltip", function() {
    var timeago = this.content.find('time.timeago');
    expect(timeago.attr('datetime')).toEqual(this.date);
    expect(timeago.data('original-title')).toEqual(undefined);

    app.helpers.timeago(this.content);

    timeago = this.content.find('time.timeago');
    expect(timeago.attr('datetime')).toEqual(this.date);
    expect(timeago.data('original-title')).toEqual(this.datestring);
  });
});
