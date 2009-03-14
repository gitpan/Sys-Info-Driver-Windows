#/usr/bin/env perl
use strict;
use Test::More qw(no_plan);
use Sys::Info::Driver::Windows qw( :all);
use Data::Dumper;

ok( SM_TABLETPC    == 86, "Got SM_TABLETPC(86=="    . SM_TABLETPC    . ")" );
ok( SM_MEDIACENTER == 87, "Got SM_MEDIACENTER(87==" . SM_MEDIACENTER . ")" );
ok( SM_STARTER     == 88, "Got SM_STARTER(89=="     . SM_STARTER     . ")" );
ok( SM_SERVERR2    == 89, "Got SM_SERVERR2(88=="    . SM_SERVERR2    . ")" );

foreach my $const ( SM_TABLETPC, SM_MEDIACENTER, SM_SERVERR2, SM_STARTER ) {
    # ok if this does not die :)
    GetSystemMetrics( $const );
    ok(1, "Able to call GetSystemMetrics( $const )");
}

ok( my %si = GetSystemInfo(), "Able to get system information" );

my $sid = Data::Dumper->new( [\%si], ['*SYSTEM_INFO'] );
diag $sid->Dump;

diag sprintf("CPU: %s Family %s Model %s Stepping %s\n",
        @si{qw/
            wProcessorArchitecture2
            wProcessorLevel
            wProcessorModel
            wProcessorStepping
        /}
    );

diag sprintf( "Minimum Application Address: %lx\n", $si{lpMinimumApplicationAddress} );
diag sprintf( "Maximum Application Address: %lx\n", $si{lpMaximumApplicationAddress} );

ok( 1, "The END" );

1;

__END__
