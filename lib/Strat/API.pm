package Curry::Site;

use Carp;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Moment;
use JSON qw();

use lib::abs qw(
    ../../lib
);


hook 'before' => sub {

    if ($ENV{TOKEN}) {

        my $auth = request->{headers}->{authorization} // '';
        $auth =~ /^TOKEN key="(.*?)"$/;
        my $got_token = $1 // '';
        print "got_token: [$got_token] ";

        if ( $ENV{TOKEN} eq $got_token ) {
            # auth is correct
            print "auth is correct";
        } else {
            content_type('application/json');
            print "auth is correct";
            my $content = JSON::to_json({
                success => JSON::false,
                error_message => 'No access',
            });

            return halt($content);
        }
    }
};

get '/' => sub {
    return '<a href="https://github.com/bessarabov/curry">curry</a>';
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
            status => ($data->[-1]->{status} eq 'ok' ? 'ok' : 'fail'),
            path => param('path'),
            expire => $expire,
            history => $data,
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
