use v6;

use Test;
use lib 't/lib';
use Test::TCP;

use HTTP::Server::Tiny;
use HTTP::Tinyish;

plan 1;

my $port = 15555;

my $server = HTTP::Server::Tiny.new(host => '127.0.0.1', port => $port);

Thread.start({
    $server.run(sub ($env) {
        my $body = $env<p6sgi.input>.slurp-rest: :bin;
        return 200, ['Content-Type' => 'text/plain'], [$body]
    });
});

wait_port($port);
my $resp = HTTP::Tinyish.new.post("http://127.0.0.1:$port/",
   headers => { 
        'content-type' => 'application/x-www-form-urlencoded'
    },
    content => 'foo=bar');
is($resp<content>, "foo=bar");

exit 0; # There is no way to kill the server thread.
