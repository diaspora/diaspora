#!/usr/bin/perl -wT
#
# Simple Flash Socket Policy Server
# http://www.lightsphere.com/dev/articles/flash_socket_policy.html
#
# Copyright (C) 2008 Jacqueline Kira Hamilton
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


use Socket;
use IO::Handle;

my $should_be_logging = 0;  # change to 0 to turn off logging.

my $logfile = 'log';

if ($should_be_logging) {
    open(LOG, ">$logfile") or warn "Can't open $logfile: $!\n";
    LOG->autoflush(1);
}

my $port = 843;
my $proto = getprotobyname('tcp');

# start the server:

      &log("Starting server on port $port");
    socket(Server, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
setsockopt(Server, SOL_SOCKET, SO_REUSEADDR, 1 ) or die "setsockopt: $!";
      bind(Server,sockaddr_in($port,INADDR_ANY)) or die "bind: $!";
    listen(Server,SOMAXCONN) or die "listen: $!";

    Server->autoflush( 1 );

my $paddr;
&log("Server started. Waiting for connections.");

$/ = "\0";      # reset terminator to null char

# listening loop.

for ( ; $paddr = accept(Client,Server); close Client) {
    Client->autoflush(1);
    my($port,$iaddr) = sockaddr_in($paddr);
    my $ip_address   = inet_ntoa($iaddr);
    my $name         = gethostbyaddr($iaddr,AF_INET) || $ip_address;
    &log( scalar localtime() . ": Connection from $name" );
 
    my $line = <Client>;
    &log("Input: $line");

    if ($line =~ /.*policy\-file.*/i) {
        print Client &xml_policy;
    }
}

sub xml_policy {
    my $str = qq(<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>\0);
    return $str;
}

sub log {
    my($msg) = @_;
    if ($should_be_logging) {
        print LOG $msg,"\n";
    }
}
