package Curry::Site;

use Carp;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Data::Dumper;
use Moment;
use JSON qw();

use lib::abs qw(
    ../../lib
);

my $wordlist = '/usr/share/dict/words';
# open my $WORDS, '<', $wordlist or die "Cannot open $wordlist:$!";
# chomp(my @words = <$WORDS>);
# close $WORDS;



#
# hook 'before' => sub {
#
#     if ($ENV{TOKEN}) {
#
#         my $auth = request->{headers}->{authorization} // '';
#         $auth =~ /^TOKEN key="(.*?)"$/;
#         my $got_token = $1 // '';
#         print "got_token: [$got_token] ";
#
#         if ( $ENV{TOKEN} eq $got_token ) {
#             # auth is correct
#             print "auth is correct";
#         } else {
#             content_type('application/json');
#             print "auth is correct";
#             my $content = JSON::to_json({
#                 success => JSON::false,
#                 error_message => 'No access',
#             });
#
#             return halt($content);
#         }
#     }
# };

get '/' => sub {
    return '
      <div style="font-family:Arial; height:100%; padding:0; margin:30; display:-webkit-box; display:-moz-box; display:-ms-flexbox; display: -webkit-flex; display: flex; align-items: flex-start; justify-content: center; flex-direction:column">
        <h1>Submission to strategicdata/recruitment <a href="https://github.com/strategicdata/recruitment/wiki/Coding-task---BE">coding task</a></h1>
        <b>Response API</b>
        <ol type="1">
          <li><a href="/wordfinder/dgo">Wordfinder API</a></li>
          <li><a href="/ping">Ping</a></li>
        </ol>
        <b>For local installation</b>
        <ol type="1">
          <li>Download repo with `>git clone https://github.com/shotlom/strat-dat && cd strat-dat`</li>
          <li>Ensure docker-compose is installed</li>
          <li>Run `>docker-compose up`</li>
        </ol>
      </div>
    ';
};

get '/wordfinder/:input' => sub {
    my $letters = param('input');
    my @matches;
    open WORDS, '<', $wordlist or die "Cannot open $wordlist:$!";
    while (<WORDS>) {
        chomp;
        push @matches, $_ if /^(?:([$letters])(?!.*\1))*$/g;
    }

    my $json = to_json(\@matches, {utf8 => 1, pretty => 1});
    return "<div style=\"font-family:Arial; height: 100%;    padding: 0;    margin: 0;    display: -webkit-box;    display: -moz-box;    display: -ms-flexbox;    display: -webkit-flex;    display: flex;    align-items: center;    justify-content: center;\">$json</div>";
};

get '/ping' => sub {
    return "<div style=\"font-family:Arial; height: 100%;    padding: 0;    margin: 0;    display: -webkit-box;    display: -moz-box;    display: -ms-flexbox;    display: -webkit-flex;    display: flex;    align-items: center;    justify-content: center;\"><h1>200 OK</h1></div>";
};
