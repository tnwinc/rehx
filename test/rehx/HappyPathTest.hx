package rehx;

import buddy.*;
import rehx.Client;

using buddy.Should;

class HappyPathTest extends BuddySuite
{
    public function new()
    {
        describe("Happy Path", {
            var c:Client;
            var unauthorizedCalled:Bool;

            before({
                unauthorizedCalled = false;
                c = new Client({
                    urlRoot: "http://api.rehx.dev",
                    unauthorizedHandler: function() {
                        unauthorizedCalled = true;
                    }
                });
            });

            it("should make a GET request", function(done) {
                c.get("/hello_world", null, null, function(r) {
                    r.statusCode.should.be(200);
                    r.data.should.be('Hello World');
                    done();
                });
            });

            xit("should make a GET request with promise", function(done) {
                c.get("/hello_world").then(function(r) {
                    r.statusCode.should.be(200);
                    r.data.should.be('Hello World');
                    done();
                });
            });

            it("should POST to the server", function(done) {
                c.post("/hello_world", "boo", null, null, function(r) {
                    r.statusCode.should.be(200);
                    r.data.should.be('Hello World');
                    done();
                });
            });

            it("should call the unathorized handler if unauthorized", function (done) {
                c.get("/unauthorized", null, null, null, function (r) {
                    unauthorizedCalled.should.be(true);
                    done();
                });
            });

            xit("should POST to the server with promise", function(done) {
                c.post("/hello_world", "boo").then(function(r) {
                    r.statusCode.should.be(200);
                    r.data.should.be('Hello World');
                    done();
                });
            });
        });
    }
}
