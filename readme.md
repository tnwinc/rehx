# rehx
Another REST-ish client for Haxe. This one gives you instances, promises, and solves some content negotiation problems.

## Thank-You
This library started out as a pull-request for [tbrosman/haxe-rest-client](https://github.com/tbrosman/haxe-rest-client), but I wanted it go in a direction beyond what was appropriate for that library. Thanks to tbrosman for the head-start!


## Platforms
This has been tested on the Neko and Flash targets. There are a couple of different options available for dealing with "Accept" headers for content negotiation. One of them or the other is needed in Flash.

If you find any issues using this library with your platform of choice, feel free to open an issue/make a pull request.

## Limitations
* Currently only GET and POST are supported. But there is a nice `.getJson` method that knows you want JSON.


## Configuration
The constructor accepts a structure for configuration: 

```
var client = new Client({
  urlRoot: "http://api.rehx.dev",
  parameterStyleContentNegotiation: true
});
```

Option                               | Description
-------------------------------------|:-----------
`urlRoot`                            | Will be prepended to any URLs requested. 
`parameterStyleContentNegotiation`   | Put Accept header values on the query string.
`extensionStyleContentNegotiation`   | Append a file extension instead of using an Accept header.
`defaultContentType`                 | The default content type used for `.get` and `.post`. `text/plain` unless specified. 

## Usage
The request methods all fulfil, both the success callback and the `.then` on the promise, with this structure: `{data:Dynamic|String, statusCode:Int}`.
The `.getJson` will have a Dynamic for `data`, the others will have a String.

`statusCode` is the status code returned from the server for that request. Note that, currently, even a 500 series status code will call the success callbacks.
