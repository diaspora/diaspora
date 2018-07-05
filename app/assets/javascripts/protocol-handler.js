// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

function registerDiasporaLinksProtocol() {
  var protocol = location.protocol;
  var slashes = protocol.concat("//");
  var host = slashes.concat(window.location.hostname);

  if (location.port) {
    host = host.concat(":" + location.port);
  }

  window.navigator.registerProtocolHandler("web+diaspora", host.concat("/link?q=%s"), document.title);
}

if (typeof (window.navigator.registerProtocolHandler) === "function") {
  registerDiasporaLinksProtocol();
}
