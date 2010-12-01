Simple Authentication and Security Layer (RFC 4422) for Ruby
============================================================

Goal
----

Have a reusable library for client implementations that need to do
authentication over SASL, mainly targeted at Jabber/XMPP libraries.

All class carry just state, are thread-agnostic and must also work in
asynchronous environments.

Usage
-----

Derive from **SASL::Preferences** and overwrite the methods. Then,
create a mechanism instance:
    # mechanisms => ['DIGEST-MD5', 'PLAIN']
    sasl = SASL.new(mechanisms, my_preferences)
    content_to_send = sasl.start
    # [...]
    content_to_send = sasl.challenge(received_content)
