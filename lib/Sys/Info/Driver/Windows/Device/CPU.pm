package Sys::Info::Driver::Windows::Device::CPU;
use strict;
use vars     qw( $VERSION @ISA $Registry );
use base qw(
    Sys::Info::Driver::Unknown::Device::CPU::Env
    Sys::Info::Driver::Windows::Device::CPU::WMI
);
use Sys::Info::Constants qw( :windows_reg );
use Carp qw( croak );

$VERSION = '0.69_10';

my $REG;
TRY_TO_LOAD: {
    # SetDualVar req. in Win32::TieRegistry breaks any handler
    local $SIG{__DIE__};
    local $@;
    eval {
        require Win32::TieRegistry;
        Win32::TieRegistry->import(Delimiter => '/');
    };
    if ( ! $@ && defined $Registry->{+WIN_REG_HW_KEY} ) {
        $REG = $Registry->{ +WIN_REG_CPU_KEY };
    }
}

sub load {
    my $self = shift;
    my @cpu  = $self->identify;
    return $cpu[0]->{load};
}

# XXX: interface is unclear. return data based on context !!!
# Take a parameter named cpu_num and return properties based on that
# ... else: add a method named properties() !!!
sub identify {
    my $self = shift;
    if ( ! $self->{META_DATA} ) {
        my @cache = $self->_from_wmi 
                    or $self->_from_registry
                    or $self->SUPER::identify(@_)
                    or croak("Failed to identify CPU");
        $self->{META_DATA} = [ @cache ];
    }
    return $self->_serve_from_cache(wantarray);
}

# ------------------------[ P R I V A T E ]------------------------ #

# $REG->{'0/FeatureSet'}
# $REG->{'0/Update Status'}
sub _from_registry {
    my $self = shift;
    return +() if not $self->_registry_is_ok;
    my(@cpu);

    foreach my $k (keys %{ $REG }) {
        my $name = $REG->{ $k . '/ProcessorNameString' };
        $name =~ s{\s+}{ }xmsg;
        $name =~ s{\A \s+}{}xms;
        my $id = $REG->{ $k . '/Identifier' };

        push @cpu, {
            name          => $name,
            speed         => hex( $REG->{ $k . '/~MHz' } ),
            architecture  => ($id =~ m{ \A (.+?) \s? Family }xmsi),
            data_width    => undef,
            bus_speed     => undef,
            address_width => undef,
        };
    }

    return @cpu;
}

sub _registry_is_ok {
    my $self = shift;
    return if not $REG;
    return if not $REG->{'0/'};
    return if not $REG->{'0/ProcessorNameString'};
    return 1;
}

# may be called from ::Env
sub __env_pi { # XXX: remove this thing
    my $self = shift;
    return if not $REG;
    return $REG->{'0/Identifier'}.', '.$REG->{'0/VendorIdentifier'};
}

1;

__END__

=head1 NAME

Sys::Info::Driver::Windows::Device::CPU - Windows CPU Device Driver

=head1 SYNOPSIS

-

=head1 DESCRIPTION

Uses C<WMI>, C<Registry> and C<ENV> to identify the CPU.

=head1 METHODS

=head2 identify

See identify in L<Sys::Info::Device::CPU>.

=head2 load

See load in L<Sys::Info::Device::CPU>.

=head1 SEE ALSO

L<Sys::Info>,
L<Sys::Info::Device::CPU>.

=head1 AUTHOR

Burak G�rsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006-2009 Burak G�rsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.10.0 or, 
at your option, any later version of Perl 5 you may have available.

=cut