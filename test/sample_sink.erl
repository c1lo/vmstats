-module(sample_sink).
-behaviour(vmstats_sink).

-export([collect/3, start_link/0, called/0, stop/0]).

collect(Type, Key, Value) when Type =:= timing; Type =:= gauge; Type =:= counter ->
    K = lists:flatten(Key),
    call({store, K, Value}).

start_link() ->
    spawn_link(fun() -> init() end).

called() -> call(called).

stop() -> call(stop).

init() ->
    register(?MODULE, self()),
    loop([]).

loop(Stack) ->
    receive
        {From, {store, K, D}} ->
            reply(From, ok),
            loop([{K,D}|Stack]);
        {From, called} ->
            reply(From, lists:reverse(Stack)),
            loop([]);
        {From, stop} ->
            reply(From, ok)
    end.


call(Msg) ->
    Ref = make_ref(),
    ?MODULE ! {{self(), Ref}, Msg},
    receive
        {Ref, Reply} -> Reply
    end.

reply({Pid, Ref}, Reply) ->
    Pid ! {Ref, Reply}.
