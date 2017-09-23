use Test::More;
use Test::Exception;

use Test::Mock::One;
use Dist::Zilla::Plugin::UploadToStratopan;

plan( skip_all => 'Only run these tests on when networking is enabled' ) if $ENV{NO_NETWORK};

my $pluginname = "UploadToStratopan";
my $username   = $ENV{STRATOPAN_USERNAME};
my $password   = $ENV{STRATOPAN_PASSWORD};
my $repo       = $ENV{STRATOPAN_REPO};
my $tarball    = $ENV{STRATOPAN_TARBALL};

my $zilla    = Test::Mock::One->new(
    'X-Mock-Strict' => 1,
    chrome          => {
        prompt_str => 1,
        logger     => {
            proxy => {
                log_fatal => sub { die @_ },
                #log_info  => sub { push(@info,  @_) },
                log => sub {
                    ::diag ::explain \@_;
                }
            },
        },
    },
);

{
    note "failure testing";
    # Skip on no network testing
    my $stratopan = Dist::Zilla::Plugin::UploadToStratopan->new(
        zilla       => $zilla,
        repo        => $pluginname,
        plugin_name => $pluginname,
        _username   => 'username',
        _password   => 'password',
    );

    throws_ok(
        sub {
            $stratopan->_login;
        },
        qr/Incorrect login or password/,
        "Unable to login",
    );
}

SKIP: {

    if (!$username && !$password && !$repo) {
        skip("Skipping live tests: login", 1);
    }

    my $stratopan = Dist::Zilla::Plugin::UploadToStratopan->new(
        zilla       => $zilla,
        repo        => $repo,
        plugin_name => $pluginname,
        _username   => $username,
        _password   => $password,
    );

    lives_ok(
        sub {
            $stratopan->_login;
        },
        "Login succesfull"
    );
}

SKIP: {
    if (!$username && !$password && !$repo && !$tarball) {
        skip("Skipping live tests: uploading tarball", 1);
    }

    my $stratopan = Dist::Zilla::Plugin::UploadToStratopan->new(
        zilla       => $zilla,
        repo        => $repo,
        plugin_name => $pluginname,
        _username   => $username,
        _password   => $password,
    );

    lives_ok(
        sub {
            $stratopan->release($tarball);
        },
        "Upload succesful"
    );
}


done_testing;
