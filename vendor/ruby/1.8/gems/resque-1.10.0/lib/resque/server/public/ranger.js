$(function() {
  var poll_interval = 2

  var relatizer = function(){
    var dt = $(this).text(), relatized = $.relatizeDate(this)
    if ($(this).parents("a").length > 0 || $(this).is("a")) {
      $(this).relatizeDate()
      if (!$(this).attr('title')) {
        $(this).attr('title', dt)
      }
    } else {
      $(this)
        .text('')
        .append( $('<a href="#" class="toggle_format" title="' + dt + '" />')
        .append('<span class="date_time">' + dt +
                '</span><span class="relatized_time">' +
                relatized + '</span>') )
    }
  };

  $('.time').each(relatizer);

  $('.time a.toggle_format .date_time').hide()

  var format_toggler = function(){
    $('.time a.toggle_format span').toggle()
    $(this).attr('title', $('span:hidden',this).text())
    return false
  };

  $('.time a.toggle_format').click(format_toggler);

  $('.backtrace').click(function() {
    $(this).next().toggle()
    return false
  })

  $('a[rel=poll]').click(function() {
    var href = $(this).attr('href')
    $(this).parent().text('Starting...')
    $("#main").addClass('polling')

    setInterval(function() {
      $.ajax({dataType: 'text', type: 'get', url: href, success: function(data) {
        $('#main').html(data)
        $('#main .time').relatizeDate()
      }})
    }, poll_interval * 1000)

    return false
  })

  $('ul.failed a[rel=retry]').click(function() {
    var href = $(this).attr('href');
    $(this).text('Retrying...');
    var parent = $(this).parent();
    $.ajax({dataType: 'text', type: 'get', url: href, success: function(data) {
      parent.html('Retried <b><span class="time">' + data + '</span></b>');
      relatizer.apply($('.time', parent));
      $('.date_time', parent).hide();
      $('a.toggle_format span', parent).click(format_toggler);
    }});
    return false;
  })


})