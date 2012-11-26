#!/bin/sh
#NOTE: mustache templates need \ because they are not awesome.
exec erl -pa ebin edit deps/*/ebin deps/*/deps/*/ebin -boot start_sasl +K true +P 655350 \
    -setcookie msgbus\
    -name msg_dev@127.0.0.1 \
    -s msgbus\
    -s reloader
