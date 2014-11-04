
package rehx;

import buddy.*;
import rehx.Client;

using buddy.Should;

class MethodTunnelingTest extends BuddySuite
{
    public function new()
    {
        describe("Method Tunneling", {
            var c:Client;

            before({
                c = new Client({
                    urlRoot: "http://api.rehx.dev",
                    methodTunneling: true
                });
            });

            it("should make a GET request", function(done) {
                c.getJson("/hello_world", null, null, function(r) {
                    r.statusCode.should.be(200);
                    var title:String = r.data.title;
                    title.should.be('Hello World');
                    done();
                });
            });

            xit("should make a GET request with promise", function(done) {
                c.getJson("/hello_world").then(function(r) {
                    r.statusCode.should.be(200);
                    r.data.title.should.be('Hello World');
                    done();
                });
            });
        });
    }
}
