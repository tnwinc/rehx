# rehx
Another REST-ish client for Haxe. This one gives you instances, promises, and solves some content negotiation problems.

## Thank-You
This library started out as a pull-request for [tbrosman/haxe-rest-client](https://github.com/tbrosman/haxe-rest-client), but I wanted it go in a direction beyond what was appropriate for that library. Thanks to tbrosman for the head-start!


## Platforms
This has been tested on then Neko and Flash targets. There are a couple of different options available for dealing with "Accept" headers for content negotiation. One of them or the other is needed in Flash.

If you find any issues using this library with your platform of choice, feel free to open an issue/make a pull request.

## Limitations
* Currently only GET and POST are supported. But there is a nice `.getJson` method that knows you want JSON.
