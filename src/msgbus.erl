%Last modified: 2012-05-07 11:11:02
%Author: BlackAnimal <ronalfei@qq.com>
%Create by vim: ts=4


-module(msgbus).
-compile(export_all).
-include("msgbus.hrl").


start() ->
	lager:start(),
	application:start(crypto),
	application:start(msgbus),
	?MODULE:log_level(info),
	ok.




stop() ->
	msgbus_worker_sup:stop().

restart() ->
	msgbus_worker_sup:restart().

reload() ->
	msgbus_worker_sup:reload().

alived(PidList) ->
	Pid = list_to_pid(PidList),
	is_process_alive(Pid).

log_level(debug) ->
	lager:set_loglevel(lager_console_backend, debug);
log_level(info) ->
	lager:set_loglevel(lager_console_backend, info);
log_level(warning) ->
	lager:set_loglevel(lager_console_backend, warning);
log_level(error) ->
	lager:set_loglevel(lager_console_backend, error).
