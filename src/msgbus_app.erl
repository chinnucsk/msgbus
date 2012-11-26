%%% -------------------------------------------------------------------
%%% Author  :   BlackAnimal  <ronalfei@gmail.com> or <ronalfei@qq.com> 
%%% Description :
%%%
%%% Created : 2012-6-11
%%% -------------------------------------------------------------------
-module(msgbus_app).

-author("BlackAnimal <ronalfei@gmail.com> or <ronalfei@qq.com>").

-behaviour(application).

-include("msgbus.hrl").
%% External exports
-export([start/2, stop/1]).


start(_StartType, _StartArgs) ->
	msgbus_worker_sup:start_link().

stop(_) ->
	supervisor:which_children(?MODULE).


