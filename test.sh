#!/usr/bin/env sh
rm -f ./build/*
haxe build.hxml

neko ./build/TestMain.n
open http://rehx.dev/swf.swf
