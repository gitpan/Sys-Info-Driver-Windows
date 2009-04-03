#!/usr/bin/perl
die "OS unsupported\n" if $^O !~ m{ \A MSWin }xmsi;

use strict;
use vars qw(%PREREQ %RECOMMEND %BUILD_REQ);
use ExtUtils::MakeMaker;

do 'PREREQ' or die "Error including PREREQ: $!";

WriteMakefile(
    NAME         => 'Sys::Info::Driver::Windows',
    VERSION_FROM => 'lib/Sys/Info/Driver/Windows.pm',
    PREREQ_PM    => { %PREREQ, %RECOMMEND, %BUILD_REQ },
    ($] >= 5.005 ? (
    AUTHOR       => 'Burak Gursoy <burak@cpan.org>',
    ABSTRACT     => 'Windows driver for Sys::Info',
    ) : ()),
    PL_FILES     => {},
);
