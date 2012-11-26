-module(msgbus_smtp_client).

-compile(export_all).

-include("msgbus.hrl").



send(MailFormat, Options, Callback) ->
	
	Mail = compile_mail_format(MailFormat),
	gen_smtp_client:send(Mail, Options, Callback).



encode("subject", Subject) ->
	"Subject: =?utf-8?B?" ++ base64:encode_to_string(Subject) ++ "?=";

encode("display_from", DisplayFrom) ->
	"From: =?utf-8?B?" ++ base64:encode_to_string(DisplayFrom) ++ "?=";
	%"From: =?utf-8?B?" ++ DisplayFrom ++ "?=";

encode("display_to", DisplayTo) ->
	"To: =?utf-8?B?" ++ base64:encode_to_string(DisplayTo) ++ "?=";

encode("body", Body) ->
	list_to_binary(Body).

compile_mail_format(MailFormat) ->
	From			= MailFormat#mail_format.from,
	To				= MailFormat#mail_format.to,
	Subject			= encode("subject", MailFormat#mail_format.subject),
	DisplayFrom		= encode("display_from", MailFormat#mail_format.display_from) ++ "<" ++ From ++ ">",
	DisplayTo		= encode("display_to", MailFormat#mail_format.display_to),
	ContentType		= MailFormat#mail_format.content_type,
	ContentEncode	= MailFormat#mail_format.content_encode,
	Body			= encode("body", MailFormat#mail_format.body),
	
	Content = io_lib:format("~s\r\n~s\r\n~s\r\n~s\r\n~s\r\n\r\n\r\n\r\n~s", 
				[Subject, DisplayFrom, DisplayTo, ContentType, ContentEncode, Body]
	),
	{From, To, Content}.

%%---------------------------------------------------------------
test1() ->
	From = "system5@vips100.com",
	To	 = ["ronalfei@sohu.com", "ronalfei@qq.com", "ronalfei@163.com"], 

	Subject = "Subject: =?utf-8?B?"++ base64:encode_to_string("This a testing 邮件") ++ "?=",
	DisplayFrom = "From: =?utf-8?B?"++base64:encode_to_string("联想网盘")++"?=BlackAnimal <system5@vips100.com>",
	DisplayTo = "To: Some Dude",
	MailFormatType = "MailFormat-Type: text/html; charset=utf-8",
	MailFormatEncode = "MailFormat-Transfer-Encoding: binary",

	%MailBody = "=?utf-8?B?" ++ base64:encode_to_string("邮件正文啥都有啊")++"?=,mail body include anything",
	
	MailBody = list_to_binary("邮件正文啥都有啊mail body include anything"),
	
	Content = io_lib:format("~s\r\n~s\r\n~s\r\n~s\r\n~s\r\n\r\n\r\n\r\n~s", [Subject, DisplayFrom, DisplayTo, MailFormatType, MailFormatEncode, MailBody]),
	
	Options = [   
		{relay, "smtp.qiye.163.com"}, 
		{username, "system5@vips100.com"},
		{password, "vips100"},
		{port, 25}, 
		{hostname, "test"},
		{retries, 3},
		{ssl, false}
    ],



	Callback = fun(X) ->
		case X of
			{ok, _} -> 
				lager:info("Send Mail Success");
			{error, Reason} ->
				lager:info("A error occur:~p", [Reason]);
			{error, Reason1, Reason2} ->
				lager:info("A error occur:~p Reason: ~p ->>>>>~p", [Reason1, Reason2])
		end
	end,


	gen_smtp_client:send({From, To, Content},Options, Callback).




test() ->
	{H, M, S} = time(),
	Time = io_lib:format("~s : ~s : ~s", [integer_to_list(H), integer_to_list(M), integer_to_list(S)]),
	MailFormat = #mail_format{
		from="system1@vips100.com",
		to=["ronalfei@sohu.com", "ronalfei@qq.com", "ronalfei@163.com"],
		subject = "这是一封测试邮件,do you know?",
		display_from = "黑野兽 blackanimal",
		display_to = "伙计,要光盘么? do you want disk?",
		body = "当前时间, 你看欧洲杯吗?" ++ Time
	},
	Options = [   
		{relay, "smtp.qiye.163.com"}, 
		{username, "system1@vips100.com"},
		{password, "vips100"},
		{port, 25}, 
		{hostname, "test"},
		{retries, 3},
		{ssl, false}
    ],

	Callback = fun(X) ->
		case X of
			{ok, _} -> 
				lager:info("Send Mail Success");
			{error, Reason} ->
				lager:info("A error occur:~p", [Reason]);
			{error, Reason1, Reason2} ->
				lager:info("A error occur:~p Reason: ~p ->>>>>~p", [Reason1, Reason2])
		end
	end,


	?MODULE:send( MailFormat, Options, Callback	).
