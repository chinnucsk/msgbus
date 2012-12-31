%Last modified: 2012-07-31 23:11:20
%Author: BlackAnimal <ronalfei@gmaill.com>
%Create by vim: ts=4

-module(create_preview_worker).
-include("../msgbus.hrl").
-include_lib("kernel/include/file.hrl").
-include_lib("stdlib/include/zip.hrl").

-behaviour(msgbus_work_handler).

-export([run/1]).

run(ArgTuple) ->
	{_Connect, _Channel, _QueueName, Msg} = ArgTuple,
	{FilePath, Ext, TargetPath, Option} = decode_msg(Msg),

	%sample(Ext, FilePath, TargetPath, Option).
	try
		sample(Ext, FilePath, TargetPath, Option)
	catch _A:_B ->
		lager:error("!!!Error!!!!!!!!!!!!!!!~n~p!!!!~n~p~n", [_A, _B]),
		callback(ArgTuple)
	end.

%%return Record Mail_format and Options
decode_msg(Msg) ->
	{struct, List} = mochijson2:decode(Msg),
	FilePath	= get_value(<<"filepath">>, List),
	Ext			= get_value(<<"ext">>, List),
	TargetPath	= get_value(<<"targetpath">>, List),
	Option		= get_value(<<"option">>, List),
	{FilePath, Ext, TargetPath, Option}.

callback(ArgTuple) ->
	% todo
	% this will be send this msg to an another queue
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


%%----------------sample---------

sample("rar", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 ./script/rarConvert ~s ~s", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );


sample("zip", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 ./script/zipConvert ~s ~s", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );

%%	{ok, [{zip_comment, _ } | ZipList]} = zip:table(Src),
%%	lager:debug("~n zip list is ~p ", [ZipList]),
%%	Result = lists:foldl(
%%		fun(X, Result) ->
%%			Name = list_to_binary(os:cmd("iconv -f gbk -t utf8 X#zip_file.name, latin1")),
%%			FileInfo = X#zip_file.info,
%%			[[{<<"filename">>, Name}, {<<"filetype">>, FileInfo#file_info.type}, {<<"filesize">>, FileInfo#file_info.size}] | Result]
%%		end,
%%		[], ZipList),
%%	Json = mochijson2:encode(Result),
%%	%Json = "[]",
%%	lager:debug("zip list json is :~p", [Json]),
%%	file:write_file(Trg++".preview", Json);
	
sample("jpeg", Src, Trg, Option) ->
	sample("image", Src, Trg, Option);

sample("jpg", Src, Trg, Option) ->
	sample("image", Src, Trg, Option);

sample("png", Src, Trg, Option) ->
	sample("image", Src, Trg, Option);

sample("gif", Src, Trg, Option) ->
	sample("image", Src, Trg, Option);

sample("image", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".thumb",
	Trg2 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 ./script/imgConvert ~s ~s ~s", [Src, Trg1, Trg2]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );

sample("ogg", Src, Trg, Option) ->
	sample("audio", Src, Trg, Option);

sample("ra", Src, Trg, Option) ->
	sample("audio", Src, Trg, Option);

sample("mid", Src, Trg, Option) ->
	sample("audio", Src, Trg, Option);

sample("midi", Src, Trg, Option) ->
	sample("audio", Src, Trg, Option);

sample("kar", Src, Trg, Option) ->
	sample("audio", Src, Trg, Option);

sample("mp3", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 cp ~s ~s", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );

sample("audio", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 ./script/ffConvert ~s ~s", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );

sample("rm", Src, Trg, Option) ->
	sample("rmvb", Src, Trg, Option);

sample("rmvb", Src, Trg, _Option) ->
	UUID = util:uuid(),
    Tmp = io_lib:format("/dev/shm/~s~s", [UUID, ".avi"]),
    Command1 = io_lib:format("./script/timeout.sh -t 300 ./script/menConvert ~s ~s", [Src, Tmp]),
    lager:debug("command1: ~s", [Command1]),
	Trg1 = Trg ++ ".preview",
	Trg2 = Trg ++ ".thumb",
    Command2 = io_lib:format("./script/timeout.sh -t 300 ./script/ffConvert ~s ~s ~s", [Tmp, Trg1, Trg2]),
    lager:debug("command2: ~s", [Command2]),
    Command3 = io_lib:format("rm -rf ~s", [Tmp]),
    lager:debug("command3: ~s", [Command3]),
    [ os:cmd(Command) || Command<-[Command1, Command2, Command3] ];

sample("mpeg", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("mpg", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("mp4", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("3gpp", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("3gp", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("mov", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("mng", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("asf", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("asx", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("wmv", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("avi", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("m4v", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("mkv", Src, Trg, Option) ->
	sample("video", Src, Trg, Option);

sample("video", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
	Trg2 = Trg ++ ".thumb",
    Command = io_lib:format("./script/timeout.sh -t 300 ./script/ffConvert ~s ~s ~s", [Src, Trg1, Trg2]),
    lager:debug("command: ~s", [Command]),
    os:cmd ( Command );

sample("flv", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 120 cp ~s ~s", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd( Command );

sample("pdf", Src, Trg, _Option) ->
	Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 300 ./script/pdfConvert ~s ~s ", [Src, Trg1]),
    lager:debug("command: ~s", [Command]),
    os:cmd ( Command );

sample("txt", Src, Trg, _Option) ->
	sample_office("txt", Src, Trg);
	%%Trg1 = Trg ++ ".preview",
    %%Command = io_lib:format("./script/timeout.sh -t 120 cp ~s ~s", [Src, Trg1]),
    %%lager:debug("command: ~s", [Command]),
    %%os:cmd( Command );


%%office farmily-------------------
sample("docx", Src, Trg, _Option) ->
	sample_office("docx", Src, Trg);

sample("doc", Src, Trg, _Option) ->
	sample_office("doc", Src, Trg);

sample("xls", Src, Trg, _Option) ->
    sample_office("xls", Src, Trg);

sample("csv", Src, Trg, _Option) ->
    sample_office("csv", Src, Trg);

sample("xlsm", Src, Trg, _Option) ->
    sample_office("xlsm", Src, Trg);

sample("ppt", Src, Trg, _Option) ->
    sample_office("ppt", Src, Trg);

sample("pptx", Src, Trg, _Option) ->
    sample_office("pptx", Src, Trg);

sample("rtf", Src, Trg, _Option) ->
    sample_office("rtf", Src, Trg);
%%----------------------------------

sample(_AnyExt, _Src, _Trg, _Option) ->
	lager:warning("----------------------------------nothing to need sample ~s ~n", [_AnyExt]).


%%-------------------------------------
%%------this is sample for office family
sample_office(FileType, Src, Trg) ->
    Trg1 = Trg ++ ".preview",
    Command = io_lib:format("./script/timeout.sh -t 300 ./script/docConvert ~s ~s ~s", [Src, Trg1, FileType]),
    lager:debug("command: ~s", [Command]),
    os:cmd ( Command ).


