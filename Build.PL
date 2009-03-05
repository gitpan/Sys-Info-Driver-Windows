die "OS unsupported\n" if $^O !~ m{ \A MSWin }xmsi;

use strict;
use vars qw(%PREREQ %RECOMMEND);
use Cwd;
use Module::Build;

do 'PREREQ' or die "Error including PREREQ: $!";

my $mb = Module::Build->new(
    module_name    => 'Sys::Info::Driver::Windows',
    license        => 'perl',
    requires       => \%PREREQ,
    recommends     => \%RECOMMEND,
    sign           => 0,
    dist_author    => 'Burak Gursoy <burak@cpan.org>',
    include_dirs   => [ '.' ],
    xs_files       => { 'Windows.xs' => 'lib/Sys/Info/Driver/Windows.xs' },
);

$mb->create_build_script;
