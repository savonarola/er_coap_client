# Generic Erlang CoAP Client [![Build status](https://github.com/emqx/er_coap_client/actions/workflows/main.yml/badge.svg)](https://github.com/emqx/er_coap_client/actions/workflows/main.yml)

Pure Erlang implementation of the Constrained Application Protocol (CoAP) client,
which aims to be conformant with:
 - CoAP core protocol [RFC 7252](https://tools.ietf.org/rfc/rfc7252.txt),
   including (since Erlang/OTP 19.2) the DTLS-Secured CoAP
 - CoAP Observe option [RFC 7641](https://tools.ietf.org/rfc/rfc7641.txt)
 - Block-wise transfers in CoAP [draft-ietf-core-block-18](https://tools.ietf.org/id/draft-ietf-core-block-18.txt)
 - CoRE link format [RFC 6690](https://tools.ietf.org/rfc/rfc6690.txt)

## Usage

### Client API

To make a simple CoAP request:
```erlang
% Simple GET request
{ok, content, Data} = er_coap_client:request(get, "coap://coap.me:5683").

% DTLS/CoAPS request
{ok, content, Data} = er_coap_client:request(get, "coaps://example.com:5684/resource").
```

To observe a resource (get notified on changes):
```erlang
% Start observing
{ok, Pid, N, Code, Content} = er_coap_observer:observe("coap://coap.me:5683/resource").

% Receive notifications
receive
    {coap_notify, Pid, Seq, {ok, Code}, Content} ->
        % Handle notification
        ok
end.

% Stop observing
er_coap_observer:stop(Pid).
```

## Build Instructions

Build using rebar3:

    $ rebar3 compile

## Modules

- `er_coap_client` - Main client API for making CoAP requests
- `er_coap_observer` - Client-side observe functionality for resource subscriptions
- `er_coap_dtls_socket` - DTLS client socket implementation
- `er_coap_udp_socket` - UDP socket implementation
- `er_coap_channel` - CoAP message channel management
- `er_coap_message` - CoAP message construction and parsing
