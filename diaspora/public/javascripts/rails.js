/* Clear form plugin - called using $("elem").clearForm(); */
$.fn.clearForm = function() {
  return this.each(function() {
    if ($(this).is('form')) {
      return $(':input', this).clearForm();
    }
    if ($(this).hasClass('clear_on_submit') || $(this).is(':text') || $(this).is(':password') || $(this).is('textarea')) {
      $(this).val('');
    } else if ($(this).is(':checkbox') || $(this).is(':radio')) {
      $(this).attr('checked', false);
    } else if ($(this).is('select')) {
      this.selectedIndex = -1;
    } else if ($(this).attr('name') == 'photos[]') {
      $(this).val('');
    }
    $(this).blur();
  });
};

/**
 * Unobtrusive scripting adapter for jQuery
 *
 * Requires jQuery 1.4.3 or later.
 * https://github.com/rails/jquery-ujs
 */

(function($) {
  // Make sure that every Ajax request sends the CSRF token
  function CSRFProtection(fn) {
    var token = $('meta[name="csrf-token"]').attr('content');
    if (token) fn(function(xhr) { xhr.setRequestHeader('X-CSRF-Token', token) });
  }
  if ($().jquery == '1.5') { // gruesome hack
    var factory = $.ajaxSettings.xhr;
    $.ajaxSettings.xhr = function() {
      var xhr = factory();
      CSRFProtection(function(setHeader) {
        var open = xhr.open;
        xhr.open = function() { open.apply(this, arguments); setHeader(this) };
      });
      return xhr;
    };
  }
  else $(document).ajaxSend(function(e, xhr) {
    CSRFProtection(function(setHeader) { setHeader(xhr) });
  });

  // Triggers an event on an element and returns the event result
  function fire(obj, name, data) {
    var event = new $.Event(name);
    obj.trigger(event, data);
    return event.result !== false;
  }

  // Submits "remote" forms and links with ajax
  function handleRemote(element) {
    var method, url, data,
      dataType = element.attr('data-type') || ($.ajaxSettings && $.ajaxSettings.dataType);

    if (element.is('form')) {
      method = element.attr('method');
      url = element.attr('action');
      data = element.serializeArray();
      // memoized value from clicked submit button
      var button = element.data('ujs:submit-button');
      if (button) {
        data.push(button);
        element.data('ujs:submit-button', null);
      }
    } else {
      method = element.attr('data-method');
      url = element.attr('href');
      data = null;
    }

    $.ajax({
      url: url, type: method || 'GET', data: data, dataType: dataType,
      // stopping the "ajax:beforeSend" event will cancel the ajax request
      beforeSend: function(xhr, settings) {
        if (settings.dataType === undefined) {
          xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
        }
        return fire(element, 'ajax:beforeSend', [xhr, settings]);
      },
      success: function(data, status, xhr) {
        element.trigger('ajax:success', [data, status, xhr]);
      },
      complete: function(xhr, status) {
        element.trigger('ajax:complete', [xhr, status]);
      },
      error: function(xhr, status, error) {
        element.trigger('ajax:error', [xhr, status, error]);
      }
    });
  }

  // Handles "data-method" on links such as:
  // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
  function handleMethod(link) {
    var href = link.attr('href'),
      method = link.attr('data-method'),
      csrf_token = $('meta[name=csrf-token]').attr('content'),
      csrf_param = $('meta[name=csrf-param]').attr('content'),
      form = $('<form method="post" action="' + href + '"></form>'),
      metadata_input = '<input name="_method" value="' + method + '" type="hidden" />',
      form_params = link.data('form-params');

    if (csrf_param !== undefined && csrf_token !== undefined) {
      metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
    }

    // support non-nested JSON encoded params for links
    if (form_params != undefined) {
      var params = $.parseJSON(form_params);
      for (key in params) {
        form.append($("<input>").attr({"type": "hidden", "name": key, "value": params[key]}));
      }
    }

    form.hide().append(metadata_input).appendTo('body');
    form.submit();
  }

  function disableFormElements(form) {
    form.find('input[data-disable-with]').each(function() {
      var input = $(this);
      input.data('ujs:enable-with', input.val())
        .val(input.attr('data-disable-with'))
        .attr('disabled', 'disabled');
    });
  }

  function enableFormElements(form) {
    form.find('input[data-disable-with]').each(function() {
      var input = $(this);
      input.val(input.data('ujs:enable-with')).removeAttr('disabled');
    });
  }

  function allowAction(element) {
    var message = element.attr('data-confirm');
    return !message || (fire(element, 'confirm') && confirm(message));
  }

  function requiredValuesMissing(form) {
    var missing = false;
    form.find('input[name][required]').each(function() {
      if (!$(this).val()) missing = true;
    });
    return missing;
  }

  $('a[data-confirm], a[data-method], a[data-remote]').live('click.rails', function(e) {
    var link = $(this);
    if (!allowAction(link)) return false;

    if (link.attr('data-remote') != undefined) {
      handleRemote(link);
      return false;
    } else if (link.attr('data-method')) {
      handleMethod(link);
      return false;
    }
  });

  $('form').live('submit.rails', function(e) {
    var form = $(this), remote = form.attr('data-remote') != undefined;
    if (!allowAction(form)) return false;

    // skip other logic when required values are missing
    if (requiredValuesMissing(form)) return !remote;

    if (remote) {
      handleRemote(form);
      return false;
    } else {
      // slight timeout so that the submit button gets properly serialized
      setTimeout(function(){ disableFormElements(form) }, 13);
    }
  });

  $('form input[type=submit], form button[type=submit], form button:not([type])').live('click.rails', function() {
    var button = $(this);
    if (!allowAction(button)) return false;
    // register the pressed submit button
    var name = button.attr('name'), data = name ? {name:name, value:button.val()} : null;
    button.closest('form').data('ujs:submit-button', data);
  });

  $('form').live('ajax:beforeSend.rails', function(event) {
    if (this == event.target) disableFormElements($(this));
  });

  $('form').live('ajax:complete.rails', function(event) {
    if (this == event.target) enableFormElements($(this));
  });
})( jQuery );

