%Last modified: 2012-07-31 23:11:20
%Author: BlackAnimal <ronalfei@gmaill.com>
%Create by vim: ts=4

-module(push_oss_worker).
-include("../msgbus.hrl").

-export([run/2]).

run(Msg, Number) ->
	{MailFormat, Options}= decode_msg(Msg, Number),
	Callback = fun(X) ->
		callback(X)
	end,
	msgbus_smtp_client:send(MailFormat, Options, Callback).


%%return Record Mail_format and Options
decode_msg(Msg, MailNumber) ->
	{struct, List}= mochijson2:decode(Msg),

	Number = integer_to_list((MailNumber rem 5 ) + 1),
	Username = "system" ++ Number ++ "@vips100.com",

	MailFormat = #mail_format{
		%from = get_value(<<"from">>, List),
		from = Username,
		to = get_value(<<"to">>, List),
		subject = get_value(<<"subject">>, List),
		display_from = get_value(<<"display_from">>, List),
		display_to = get_value(<<"display_to">>, List),
		body = get_value(<<"body">>, List)
    },
	Options = [
		{relay, "smtp.qiye.163.com"},
        {username, Username},
        {password, "vips100"},
        {port, 25},
        {hostname, "lenovo"},
        {retries, 3},
        {ssl, false}
	],
	{MailFormat, Options}.
	
callback(X) ->
	case X of
	     {ok, _} ->
	         lager:info("Send Mail Success");
	     {error, Reason} ->
	         lager:error("A error occur:~p", [Reason]);
	     {error, Reason1, Reason2} ->
	         lager:error("A error occur::::: Reason: ~p ->>>>>~p", [Reason1, Reason2])
	end.

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







