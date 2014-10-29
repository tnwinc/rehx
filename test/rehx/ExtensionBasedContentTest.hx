package rehx;

import buddy.*;
import rehx.Client;

using buddy.Should;

class ExtensionBasedContentTest extends BuddySuite
{
    public function new()
    {
        describe("Extension Based Content Type", {
            var c:Client;

            before({
                c = new Client({
                    urlRoot: "http://api.rehx.dev",
                    extensionStyleContentNegotiation: true
                });
            });

            it("should make a GET JSON request", function(done) {
                c.getJson("/hello_world", null, null, function(r) {
                    r.statusCode.should.be(200);
                    var title:String = r.data.title;
                    title.should.be('Hello World');
                    done();
                });
            });

            it("should make a GET request", function(done) {
                c.get("/hello_world", null, null, function(r) {
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
        });
    }
}
