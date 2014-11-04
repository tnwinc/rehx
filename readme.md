# rehx
Another REST-ish client for Haxe. This one gives you instances, promises, and solves some content negotiation problems.

## Thank-You
This library started out as a pull-request for [tbrosman/haxe-rest-client](https://github.com/tbrosman/haxe-rest-client), but I wanted it go in a direction beyond what was appropriate for that library. Thanks to tbrosman for the head-start!

## Platforms
This has been unit tested on the Neko and Flash targets. It utilizes HTTP Method Overriding (AKA MEthod Tunneling) on Flash as needed. (eg. when setting custom headers, but using the GET Verb.)

If you find any issues using this library with your platform of choice, feel free to open an issue/make a pull request.

## Limitations
* Currently only GET and POST are supported. But there is a nice `.getJson` method that knows you want JSON.
* Currently only really tested with Flash... Sorry. Let me know if it needs changes for you!

## X-HTTP-Method-Override
When a request is made that can't be done on the target platform, such as sending custom headers on a GET request while in Flash, an `X-HTTP-Method-Override` header is sent and the most capable _actual_ method is used. In Flash, this means POST. 

A server will need to respond to one of the following method override headers in these cases: `X-HTTP-Method`, `X-HTTP-Method-Override`, `X-Method-Override`, `X-METHOD-OVERRIDE`. 

This technique has been tested with a node.js / express server utilizing [expressjs/method-override](https://github.com/expressjs/method-override). The technique should also work with ASP.NET servers. See what Mr. Hanselman has to [say](http://www.hanselman.com/blog/HTTPPUTOrDELETENotAllowedUseXHTTPMethodOverrideForYourRESTServiceWithASPNETWebAPI.aspx).

## Configuration
The constructor accepts a structure for configuration: 

```
var client = new Client({
  urlRoot: "http://api.rehx.dev"
});
```

Option                               | Description
-------------------------------------|:-----------
`urlRoot`                            | Will be prepended to any URLs requested. 
`defaultContentType`                 | The default content type used for `.get` and `.post`. `text/plain` unless specified. 

## Usage
The request methods all fulfil, both the success callback and the `.then` on the promise, with this structure: `{data:Dynamic|String, statusCode:Int}`.
The `.getJson` will have a Dynamic for `data`, the others will have a String.

`statusCode` is the status code returned from the server for that request. Note that, currently, even a 500 series status code will call the success callbacks.
