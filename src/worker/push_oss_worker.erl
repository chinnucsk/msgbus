%Last modified: 2012-07-31 23:11:20
%Author: BlackAnimal <ronalfei@gmaill.com>
%Create by vim: ts=4

-module(push_oss_worker).
-include("../msgbus.hrl").

-behaviour(msgbus_work_handler).

-export([run/1]).

run(ArgTuple) ->
	{_Connect, _Channel, _QueueName, Msg} = ArgTuple,
	{FilePath, Bucket, Key} = decode_msg(Msg),
	Cmd = io_lib:format("/opt/oss_python_cmd/osscmd put ~s oss://~s/~s", [FilePath, Bucket, Key]),
	try
		os:cmd(Cmd),
		lager:info("Command: ~s ...............~n", [Cmd])
	catch _A:_B ->
		lager:error("!!!Error!!!!!!!!!!!!!!!1~p!!!!~p", [_A, _B]),
		callback(ArgTuple)
	end.

%%return Record Mail_format and Options
decode_msg(Msg) ->
	{struct, List}= mochijson2:decode(Msg),
	FilePath= get_value(<<"filepath">>, List),
	Bucket	= get_value(<<"bucket">>, List),
	Key		= get_value(<<"key">>, List),
	{FilePath, Bucket, Key}.

callback(ArgTuple) ->
	% todo
	% i will be send this msg to an another queue
	{_Connect, Channel, QueueName, Msg} = ArgTuple,
	rabbitc:push_message(Channel, QueueName, Msg),
	lager:error("!!!An error occured !!! Msg: ~p", [Msg]).

get_value(Key, List) ->
	Value = proplists:get_value(Key, List),
	b_to_l(Value).


b_to_l(Value) ->
    if
        is_binary(Value) -> binary_to_list(Value);
        %is_list(Value)	 -> lists:flatten([b_to_l(X) ||X<- Value]);
        is_list(Value)	 -> [b_to_l(X) ||X<- Value];
        true             -> Value
    end.
