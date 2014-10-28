package rehx;

import haxe.Http;
import haxe.io.BytesOutput;

import promhx.*;

typedef RestClientPayload = {data:String, statusCode:Int}
typedef RestClientConfiguration = {
    ?urlRoot:String
}

class Client {
    public function new(cfg:RestClientConfiguration = null) {
        if (cfg != null) {
            if(cfg.urlRoot != null) urlRoot = cfg.urlRoot;
        }
    }

    var urlRoot:String = "";

    public var lastStatusCode:Int;

    public function post(url:String, data:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload>
    {
        var deferred = new Deferred<RestClientPayload>();
        var r = buildHttpRequest(
                url,
                data,
                parameters,
                headers,
                onSuccess,
                onError,
                deferred);
        r.request(true);

        return deferred.promise();
    }

    public function get(url:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload>
    {
        var deferred = new Deferred<RestClientPayload>();
        var r = buildHttpRequest(
                url,
                null,
                parameters,
                headers,
                onSuccess,
                onError,
                deferred);
        r.request(false);

        return deferred.promise();
    }

    private function buildHttpRequest(url:String, data:String = null, parameters:Map<String, String> = null, headers:Map<String, String>, onSuccess:RestClientPayload->Void = null, onError:String->Void = null, deferred:Deferred<RestClientPayload>):Http
    {
        var http = new Http(urlRoot + url);
#if js
        http.async = true;
#end
        http.onError = function(msg) {
            trace('onError: $msg');
            if (onError != null) onError(msg);
            deferred.throwError(msg);
        }

        http.onData = function(data) {
            var r = {data: data, statusCode:lastStatusCode};
            if (onSuccess != null) onSuccess(r);
            deferred.resolve(r);
        }

        http.onStatus = function(status) {
            lastStatusCode = status;
        }

        if (data != null) http.setPostData(data);

        if (headers != null)
        {
            for (key in headers.keys())
            {
                http.setHeader(key, headers.get(key));
            }
        }

        if (parameters != null)
        {
            for (key in parameters.keys())
            {
                http.setParameter(key, parameters.get(key));
            }
        }

#if flash
        // Disable caching
        http.setParameter("_nocache", Std.string(Date.now().getTime()));
#end

        return http;
    }
}
