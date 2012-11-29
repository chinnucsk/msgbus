#!/bin/sh
NAME="msgbus"
screen -dmS $NAME
screen -S $NAME -X screen erl -sname msgbus@127.0.0.1 -pa ebin -pa deps/*/ebin -s msgbus -s reloader +K true -setcookie msgbus\
    -eval "io:format(\"* msg bus was started!!!~n~n\"). "
