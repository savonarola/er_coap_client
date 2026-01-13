%
% The contents of this file are subject to the Mozilla Public License
% Version 1.1 (the "License"); you may not use this file except in
% compliance with the License. You may obtain a copy of the License at
% http://www.mozilla.org/MPL/
%
% Copyright (c) 2015 Petr Gotthard <petr.gotthard@centrum.cz>
%

% dispatcher for UDP communication
-module(er_coap_udp_socket).
-behaviour(gen_server).

-export([connect/2, connect/3, close/1, get_channel/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {sock, channel}).

connect(Host, Port) ->
    connect(Host, Port, []).

connect(Host, Port, ConnectOpts) ->
    {ok, Socket} = gen_server:start_link(?MODULE, [connect, Host, Port, ConnectOpts], []),
    {ok, Channel} = get_channel(Socket),
    {ok, Socket, Channel}.

close(Pid) ->
    gen_server:cast(Pid, shutdown).

get_channel(Pid) ->
    gen_server:call(Pid, get_channel).


init([connect, Host, Port, ConnectOpts]) ->
    {ok, Socket} = gen_udp:open(0, [binary, {active, true}, {reuseaddr, true} | ConnectOpts]),
    ChId = {Host, Port},
    {ok, Pid} = er_coap_channel:start_link(self(), ChId),
    {ok, #state{sock=Socket, channel=Pid}}.


handle_call(get_channel, _From, State=#state{channel=Chan}) ->
    {reply, {ok, Chan}, State};
handle_call(_Unknown, _From, State) ->
    {reply, unknown_call, State}.

handle_cast(shutdown, State) ->
    {stop, normal, State};
handle_cast(Request, State) ->
    io:fwrite("coap_udp_socket unknown cast ~p~n", [Request]),
    {noreply, State}.

handle_info({udp, _Socket, _PeerIP, _PeerPortNo, Data}, State=#state{channel=Chan}) ->
    Chan ! {datagram, Data},
    {noreply, State};
handle_info({datagram, {PeerIP, PeerPortNo}, Data}, State=#state{sock=Socket}) ->
    ok = gen_udp:send(Socket, PeerIP, PeerPortNo, Data),
    {noreply, State};
handle_info(Info, State) ->
    io:fwrite("coap_udp_socket unexpected ~p~n", [Info]),
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, #state{sock=Sock}) ->
    gen_udp:close(Sock),
    ok.
