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
      <div style="font-family:Arial; height:100%; padding:0; margin:0; display:-webkit-box; display:-moz-box; display:-ms-flexbox; display: -webkit-flex; display: flex; align-items: center; justify-content: center;">
        <h3>Submission to strategicdata/recruitment</h3>
        <a href="https://github.com/strategicdata/recruitment/wiki/Coding-task---BE">Coding task</a>
        <h3>Response API</h3>
        <ol type="1">
          <li><a href="/wordfinder/dgo">Wordfinder API</a></li>
          <li><a href="/ping">Ping</a></li>
        </ol>
        <h3>For local installation</h3>
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
    return "<div style=\"font-family:Arial; height: 100%;    padding: 0;    margin: 0;    display: -webkit-box;    display: -moz-box;    display: -ms-flexbox;    display: -webkit-flex;    display: flex;    align-items: center;    justify-content: center;\">200 OK</div>";
};


get '/user/:name' => sub {
    my $username = param('name');
    return "Hello $username!";
};


=head2 /api/1/version

Get API Version

=cut

ajax '/api/1/version' => sub {

    content_type('application/json');

    return JSON::to_json({
        success => JSON::true,
        result => {
            version => '1.0.0',
        },
    });
};


=head2 /api/1/get_object
=cut

ajax '/api/1/get_object' => sub {

    if (not defined param('path')) {
        return JSON::to_json({
             success => JSON::false,
             error_message => "You must specify 'path'",
        });
    }

    if (not is_path_valid(param('path'))) {
        return JSON::to_json({
             success => JSON::false,
             error_message => sprintf("Incorrect value for 'path': '%s'", param('path')),
        });
    }

    mark_expired();

    content_type('application/json');

    # my $expire = get_db()->get_one(
    #     'select value from settings where path = ? and type = "expire"',
    #     param('path'),
    # );
    #
    # my $data = get_db()->get_data(
    #     'select dt, status from history where path = ? order by dt',
    #     param('path'),
    # );
    #
    # if (@{$data} == 0) {
    #     return JSON::to_json({
    #          success => JSON::false,
    #          error_message => sprintf("Parameter 'path' got unknown value '%s'", param('path')),
    #     });
    # }

    return JSON::to_json({
         success => JSON::true,
         result => {
            status => 'ok',
            path => param('path'),
        }
    });
};

=head2 /api/1/get
=cut

ajax '/api/1/get' => sub {

    mark_expired();

    content_type('application/json');

    return JSON::to_json({
        success => JSON::true,
        result => get_data(
            path => param('path'),
            type => 'get',
        ),
    });
};

=head2 /api/1/get_all
=cut

ajax '/api/1/get_all' => sub {

    mark_expired();

    content_type('application/json');

    return JSON::to_json({
        success => JSON::true,
        result => get_data(
            path => param('path'),
            type => 'get_all',
        ),
    });
};
