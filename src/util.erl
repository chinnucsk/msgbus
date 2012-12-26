-module(util).

-compile(export_all).

uuid() ->
    uuid(32).
uuid(16) ->
    T = term_to_binary({make_ref(), now()}),
    <<I:160/integer>> = crypto:sha(T),
    string:to_lower(lists:flatten( io_lib:format("~16..0s", [erlang:integer_to_list(I, 16)]) ));
uuid(32) ->
    T = term_to_binary({make_ref(), now()}),
    <<I:160/integer>> = crypto:sha(T),
    string:to_lower(lists:flatten( io_lib:format("~32..0s", [erlang:integer_to_list(I, 16)]) )).
