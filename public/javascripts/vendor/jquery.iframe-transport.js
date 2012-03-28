// This [jQuery](http://jquery.com/) plugin implements an `<iframe>`
// [transport](http://api.jquery.com/extending-ajax/#Transports) so that
// `$.ajax()` calls support the uploading of files using standard HTML file
// input fields. This is done by switching the exchange from `XMLHttpRequest` to
// a hidden `iframe` element containing a form that is submitted.

// The [source for the plugin](http://github.com/cmlenz/jquery-iframe-transport)
// is available on [Github](http://github.com/) and dual licensed under the MIT
// or GPL Version 2 licenses.

// ## Usage

// To use this plugin, you simply add a `iframe` option with the value `true`
// to the Ajax settings an `$.ajax()` call, and specify the file fields to
// include in the submssion using the `files` option, which can be a selector,
// jQuery object, or a list of DOM elements containing one or more
// `<input type="file">` elements:

//     $("#myform").submit(function() {
//         $.ajax(this.action, {
//             files: $(":file", this),
//             iframe: true
//         }).complete(function(data) {
//             console.log(data);
//         });
//     });

// The plugin will construct a hidden `<iframe>` element containing a copy of
// the form the file field belongs to, will disable any form fields not
// explicitly included, submit that form, and process the response.

// If you want to include other form fields in the form submission, include them
// in the `data` option, and set the `processData` option to `false`:

//     $("#myform").submit(function() {
//         $.ajax(this.action, {
//             data: $(":text", this).serializeArray(),
//             files: $(":file", this),
//             iframe: true,
//             processData: false
//         }).complete(function(data) {
//             console.log(data);
//         });
//     });

// ### The Server Side

// If the response is not HTML or XML, you (unfortunately) need to apply some
// trickery on the server side. To send back a JSON payload, send back an HTML
// `<textarea>` element with a `data-type` attribute that contains the MIME
// type, and put the actual payload in the textarea:

//     <textarea data-type="application/json">
//       {"ok": true, "message": "Thanks so much"}
//     </textarea>

// The iframe transport plugin will detect this and attempt to apply the same
// conversions that jQuery applies to regular responses. That means for the
// example above you should get a Javascript object as the `data` parameter of
// the `complete` callback, with the properties `ok: true` and
// `message: "Thanks so much"`.

// ### Compatibility

// This plugin has primarily been tested on Safari 5, Firefox 4, and Internet
// Explorer all the way back to version 6. While I haven't found any issues with
// it so far, I'm fairly sure it still doesn't work around all the quirks in all
// different browsers. But the code is still pretty simple overall, so you
// should be able to fix it and contribute a patch :)

// ## Annotated Source

(function($, undefined) {

  // Register a prefilter that checks whether the `iframe` option is set, and
  // switches to the iframe transport if it is `true`.
  $.ajaxPrefilter(function(options, origOptions, jqXHR) {
    if (options.iframe) {
      return "iframe";
    }
  });

  // Register an iframe transport, independent of requested data type. It will
  // only activate when the "files" option has been set to a non-empty list of
  // enabled file inputs.
  $.ajaxTransport("iframe", function(options, origOptions, jqXHR) {
    var form = null,
        iframe = null,
        origAction = null,
        origTarget = null,
        origEnctype = null,
        addedFields = [],
        disabledFields = [],
        files = $(options.files).filter(":file:enabled");

    // This function gets called after a successful submission or an abortion
    // and should revert all changes made to the page to enable the
    // submission via this transport.
    function cleanUp() {
      $(addedFields).each(function() {
        this.remove();
      });
      $(disabledFields).each(function() {
        this.disabled = false;
      });
      form.attr("action", origAction || "")
          .attr("target", origTarget || "")
          .attr("enctype", origEnctype || "");
      iframe.attr("src", "javascript:false;").remove();
    }

    // Remove "iframe" from the data types list so that further processing is
    // based on the content type returned by the server, without attempting an
    // (unsupported) conversion from "iframe" to the actual type.
    options.dataTypes.shift();

    if (files.length) {
      // Determine the form the file fields belong to, and make sure they all
      // actually belong to the same form.
      files.each(function() {
        if (form !== null && this.form !== form) {
          jQuery.error("All file fields must belong to the same form");
        }
        form = this.form;
      });
      form = $(form);

      // Store the original form attributes that we'll be replacing temporarily.
      origAction = form.attr("action");
      origTarget = form.attr("target");
      origEnctype = form.attr("enctype");

      // We need to disable all other inputs in the form so that they don't get
      // included in the submitted data unexpectedly.
      form.find(":input:not(:submit)").each(function() {
        if (!this.disabled && (this.type != "file" || files.index(this) < 0)) {
          this.disabled = true;
          disabledFields.push(this);
        }
      });

      // If there is any additional data specified via the `data` option,
      // we add it as hidden fields to the form. This (currently) requires
      // the `processData` option to be set to false so that the data doesn't
      // get serialized to a string.
      if (typeof(options.data) === "string" && options.data.length > 0) {
        jQuery.error("data must not be serialized");
      }
      $.each(options.data || {}, function(name, value) {
        if ($.isPlainObject(value)) {
          name = value.name;
          value = value.value;
        }
        addedFields.push($("<input type='hidden'>").attr("name", name)
          .attr("value", value).appendTo(form));
      });

      // Add a hidden `X-Requested-With` field with the value `IFrame` to the
      // field, to help server-side code to determine that the upload happened
      // through this transport.
      addedFields.push($("<input type='hidden' name='X-Requested-With'>")
        .attr("value", "IFrame").appendTo(form));

      // Borrowed straight from the JQuery source
      // Provides a way of specifying the accepted data type similar to HTTP_ACCEPTS
      accepts = options.dataTypes[ 0 ] && options.accepts[ options.dataTypes[0] ] ?
        options.accepts[ options.dataTypes[0] ] + ( options.dataTypes[ 0 ] !== "*" ? ", */*; q=0.01" : "" ) :
        options.accepts[ "*" ]

      addedFields.push($("<input type='hidden' name='X-Http-Accept'>")
        .attr("value", accepts).appendTo(form));

      return {

        // The `send` function is called by jQuery when the request should be
        // sent.
        send: function(headers, completeCallback) {
          iframe = $("<iframe src='javascript:false;' name='iframe-" + $.now()
            + "' style='display:none'></iframe>");

          // The first load event gets fired after the iframe has been injected
          // into the DOM, and is used to prepare the actual submission.
          iframe.bind("load", function() {

            // The second load event gets fired when the response to the form
            // submission is received. The implementation detects whether the
            // actual payload is embedded in a `<textarea>` element, and
            // prepares the required conversions to be made in that case.
            iframe.unbind("load").bind("load", function() {

              var doc = this.contentWindow ? this.contentWindow.document :
                (this.contentDocument ? this.contentDocument : this.document),
                root = doc.documentElement ? doc.documentElement : doc.body,
                textarea = root.getElementsByTagName("textarea")[0],
                type = textarea ? textarea.getAttribute("data-type") : null;

              var status = textarea ? parseInt(textarea.getAttribute("response-code")) : 200,
                statusText = "OK",
                responses = { text: type ? textarea.value : root ? root.innerHTML : null },
                headers = "Content-Type: " + (type || "text/html")

              completeCallback(status, statusText, responses, headers);

              setTimeout(cleanUp, 50);
            });

            // Now that the load handler has been set up, reconfigure and
            // submit the form.
            form.attr("action", options.url)
              .attr("target", iframe.attr("name"))
              .attr("enctype", "multipart/form-data")
              .get(0).submit();
          });

          // After everything has been set up correctly, the iframe gets
          // injected into the DOM so that the submission can be initiated.
          iframe.insertAfter(form);
        },

        // The `abort` function is called by jQuery when the request should be
        // aborted.
        abort: function() {
          if (iframe !== null) {
            iframe.unbind("load").attr("src", "javascript:false;");
            cleanUp();
          }
        }

      };
    }
  });

})(jQuery);
