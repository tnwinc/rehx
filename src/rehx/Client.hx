package rehx;

import haxe.Http;
import haxe.io.BytesOutput;

import promhx.*;

typedef RestClientJsonPayload = {data:Dynamic, statusCode:Int}
typedef RestClientPayload = {data:String, statusCode:Int}
typedef RestClientConfiguration = {
    ?urlRoot:String,
    ?extensionStyleContentNegotiation:Bool,
    ?parameterStyleContentNegotiation:Bool,
    ?defaultContentType:String
}

class Client {
    public function new(cfg:RestClientConfiguration = null) {
        if (cfg != null) {
            if(cfg.urlRoot != null) urlRoot = cfg.urlRoot;
            if(cfg.extensionStyleContentNegotiation != null) extensionStyleContentNegotiation = cfg.extensionStyleContentNegotiation;
            if(cfg.parameterStyleContentNegotiation != null) parameterStyleContentNegotiation = cfg.parameterStyleContentNegotiation;
            if(cfg.defaultContentType != null) defaultContentType = cfg.defaultContentType;
        }

        if(parameterStyleContentNegotiation && extensionStyleContentNegotiation) throw "Can't use both alternate content negotiation schemes at the same time.";
    }

    var urlRoot:String = "";
    var extensionStyleContentNegotiation:Bool = false;
    var parameterStyleContentNegotiation:Bool = false;
    var defaultContentType:String = 'text/plain';

    public var lastStatusCode:Int;

    private function updateHeadersToAccept(headers:Map<String, String>, types:String):Map<String, String> {
        if (headers == null) headers = new Map<String, String>();
        if (extensionStyleContentNegotiation) return headers;
        if (headers.get('Accept') == null) {
            headers.set('Accept', types);
        }
        return headers;
    }

    private function updateUrlToAccept(url:String, ext:String):String {
        if (extensionStyleContentNegotiation) url = url + '.$ext';
        return url;
    }

    private function updateParametersWithContentNegotiation(parameters:Map<String, String>, headers:Map<String, String>):Map<String, String> {
        if(!parameterStyleContentNegotiation) return parameters;

        if(parameters == null) parameters = new Map<String, String>();

        var contentType = headers.get("Accept");
        parameters.set("_accept", contentType);

        return parameters;
    }

    public function post(url:String, data:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload> {
        var deferred = new Deferred<RestClientPayload>();
        headers = updateHeadersToAccept(headers, defaultContentType);
        url = updateUrlToAccept(url, 'text');

        var r = buildHttpRequest(
                url,
                deferred,
                data,
                parameters,
                headers,
                onSuccess,
                onError,
                makeStringResult);
        r.request(true);

        return deferred.promise();
    }

    public function getJson(url:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientJsonPayload->Void = null, onError:String->Void = null):Promise<RestClientJsonPayload> {
        var deferred = new Deferred<RestClientJsonPayload>();
        headers = updateHeadersToAccept(headers, 'application/json;text/json;text/javascript');
        url = updateUrlToAccept(url, 'json');

        var r = buildHttpRequest(
                url,
                deferred,
                null,
                parameters,
                headers,
                onSuccess,
                onError,
                makeJsonResult);
        r.request(false);

        return deferred.promise();
    }

    public function get(url:String, parameters:Map<String, String> = null, headers:Map<String, String> = null, onSuccess:RestClientPayload->Void = null, onError:String->Void = null):Promise<RestClientPayload> {
        var deferred = new Deferred<RestClientPayload>();
        headers = updateHeadersToAccept(headers, defaultContentType);
        url = updateUrlToAccept(url, 'text');

        var r = buildHttpRequest(
                url,
                deferred,
                null,
                parameters,
                headers,
                onSuccess,
                onError,
                makeStringResult);
        r.request(false);

        return deferred.promise();
    }

    private function makeStringResult(r:String):Dynamic {
        return {data: r, statusCode:lastStatusCode}
    }

    private function makeJsonResult(r:String):Dynamic {
        return {data: haxe.Json.parse(r), statusCode:lastStatusCode};
    }

    private function buildHttpRequest<TPayloadType>(url:String, deferred:Deferred<TPayloadType>, data:String = null, parameters:Map<String, String> = null, headers:Map<String, String>, onSuccess:TPayloadType->Void = null, onError:String->Void = null, resultMap:String->Dynamic = null):Http {
        url = urlRoot + url;
        if (resultMap == null) resultMap = function(s) return s;
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
            var r = resultMap(data);
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
        parameters = updateParametersWithContentNegotiation(parameters, headers);
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
