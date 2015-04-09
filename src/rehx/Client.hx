package rehx;

import haxe.Http;
import haxe.io.BytesOutput;

import promhx.*;

typedef RestClientJsonPayload = {data:Dynamic, statusCode:Int}
typedef RestClientPayload = {data:String, statusCode:Int}
typedef RestClientConfiguration = {
    ?urlRoot:String,
    ?defaultContentType:String
}

enum Verb {
    POST;
    GET;
}

class Client {
    public function new(cfg:RestClientConfiguration = null) {
        if (cfg != null) {
            if (cfg.urlRoot != null) urlRoot = cfg.urlRoot;
            if (cfg.defaultContentType != null) defaultContentType = cfg.defaultContentType;
        }
    }

    var urlRoot:String = "";
    var defaultContentType:String = 'text/plain';

    public var lastStatusCode:Int;

    private function updateHeadersToAccept(headers:Map<String, String>, types:String):Map<String, String> {
        if (headers == null) headers = new Map<String, String>();

        if (headers.get('Accept') == null) {
            headers.set('Accept', types);
        }
        return headers;
    }

    public function post(url:String, data:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload> {
        var deferred = new Deferred<RestClientPayload>();
        headers = updateHeadersToAccept(headers, defaultContentType);

        buildHttpRequest(
                Verb.POST,
                url,
                deferred,
                data,
                parameters,
                headers,
                onSuccess,
                onError,
                makeStringResult);

        return deferred.promise();
    }

    public function getJson(url:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientJsonPayload->Void = null, onError:String->Void = null):Promise<RestClientJsonPayload> {
        var deferred = new Deferred<RestClientJsonPayload>();
        headers = updateHeadersToAccept(headers, 'application/json;text/json;text/javascript');

        buildHttpRequest(
                Verb.GET,
                url,
                deferred,
                null,
                parameters,
                headers,
                onSuccess,
                onError,
                makeJsonResult);

        return deferred.promise();
    }

    public function get(url:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload> {
        var deferred = new Deferred<RestClientPayload>();
        headers = updateHeadersToAccept(headers, defaultContentType);

        buildHttpRequest(
                Verb.GET,
                url,
                deferred,
                null,
                parameters,
                headers,
                onSuccess,
                onError,
                makeStringResult);

        return deferred.promise();
    }

    private function makeStringResult(r:String):Dynamic {
        return {data: r, statusCode:lastStatusCode}
    }

    private function makeJsonResult(r:String):Dynamic {
        return {data: haxe.Json.parse(r), statusCode:lastStatusCode};
    }

    private function determinePostOrGetFlagAndSetOverrideHeaders(verb:Verb, headers:Map<String, String>):Bool {
        var isPost = true;
        var isGet = false;
        var needsMethodTunneling = false;

#if flash
        needsMethodTunneling = headers.keys().hasNext();
#end
        if (needsMethodTunneling) {
            for(header in ["X-HTTP-Method", "X-HTTP-Method-Override", "X-Method-Override", "X-METHOD-OVERRIDE"]){
                headers.set(header, verb.getName());
            }
        }

        if (needsMethodTunneling) return isPost;

        return switch(verb) {
            case POST   : isPost;
            case GET    : isGet;
        }
    }

    private function buildHttpRequest<TPayloadType>(verb:Verb, url:String, deferred:Deferred<TPayloadType>, data:String = null, parameters:Map<String, String> = null, headers:Map<String, String>, onSuccess:TPayloadType->Void = null, onError:String->Void = null, resultMap:String->Dynamic = null):Void {
        try {
            if (headers == null) headers = new Map<String, String>();
            if (resultMap == null) resultMap = function(s) return s;

            var postOrGetFlag:Bool = determinePostOrGetFlagAndSetOverrideHeaders(verb, headers);

            url = urlRoot + url;

            var http = new Http(url);
#if js
            http.async = true;
#end
            http.onError = function(msg) {
                trace('onError: $msg');
                if (onError != null) onError(msg);
                deferred.throwError(msg);
            }

            http.onData = function(data) {
                try {
                    var r = resultMap(data);
                    if (onSuccess != null) onSuccess(r);
                    deferred.resolve(r);
                } catch(e:Dynamic) {
                    deferred.throwError(e);
                    throw e;
                }
            }

            http.onStatus = function(status) {
                lastStatusCode = status;
            }

            if (data != null) http.setPostData(data);

            if (headers != null) {
                for(key in headers.keys()) {
                    http.setHeader(key, headers.get(key));
                }
            }
            if (parameters != null) {
                for(key in parameters.keys()) {
                    http.setParameter(key, parameters.get(key));
                }
            }

#if flash
            // Disable caching
            http.setParameter("_nocache", Std.string(Date.now().getTime()));
#end
            http.request(postOrGetFlag);
        } catch(e:Dynamic) {
            deferred.throwError(e);
        }
    }
}
