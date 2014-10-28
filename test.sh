#!/usr/bin/env sh
rm -f ./build/*
haxe build.hxml

neko ./build/TestMain.n
