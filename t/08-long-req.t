use v6;

use Test;
use lib 't/lib';
use Test::TCP;

use HTTP::Server::Tiny;
use HTTP::Tinyish;

plan 1;

my $CRLF = "\x0d\x0a";
my $port = 15555;

my $server = HTTP::Server::Tiny.new(host => '127.0.0.1', port => $port);

Thread.start({
    $server.run(sub ($env) {
        my $body = $env<p6sgi.input>.slurp-rest: :bin;
        return 200, ['Content-Type' => 'text/plain'], [$body]
    });
});

wait_port($port);
my $sock = IO::Socket::INET.new(host => '127.0.0.1', port => $port);
$sock.print(
    "GET / HTTP/1.0$CRLF"
    ~ "content-type: application/octet-stream$CRLF"
    ~ "content-length: 6000$CRLF"
    ~ "$CRLF"
    ~ ("hello\n" x 1000));
my $buf;
while my $got = $sock.recv {
    $buf ~= $got;
}
my ($headers, $body) = $buf.split(/$CRLF$CRLF/, 2);
is $body, "hello\n" x 1000;

exit 0; # There is no way to kill the server thread.
