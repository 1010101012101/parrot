#! perl
# Copyright (C) 2010, Parrot Foundation.

use strict;
use warnings;

use Test::More;
if (-e 'DEVELOPING' and ! -e 'Makefile') {
    plan tests =>  7;
}
else {
    plan skip_all =>
        q{Relevant only when working in checkout from repository and prior to configuration};
}
use Carp;
use Cwd;
use File::Copy;
use File::Path ();
use File::Temp qw| tempdir |;
use lib qw( lib );

my $cwd = cwd();
{
    my $sha1 = "35e413d801cc4fc8ba9175b7f0c0007804824311";
    my ($cache, $libdir) = setup_cache($sha1, $cwd);
    require Parrot::SHA1;
    no warnings 'once';
    is($Parrot::SHA1::current, $sha1,
        "Got expected sha1ision number from cache");
    use warnings;
    unlink qq{$libdir/Parrot/SHA1.pm}
        or croak "Unable to delete file after testing";
    ok( chdir $cwd, "Able to change back to starting directory");
}

pass("Completed all tests in $0");

##### SUBROUTINES #####

sub setup_cache {
    my ($sha1, $cwd) = @_;
    my $tdir = tempdir( CLEANUP => 1 );
    ok( chdir $tdir, "Changed to temporary directory for testing" );
    my $libdir = qq{$tdir/lib};
    ok( (File::Path::mkpath( [ $libdir ], 0, 0777 )), "Able to make libdir");
    local @INC;
    unshift @INC, $libdir;
    ok( (File::Path::mkpath( [ qq{$libdir/Parrot} ], 0, 0777 )), "Able to make Parrot dir");
    ok( (copy qq{$cwd/lib/Parrot/SHA1.pm},
            qq{$libdir/Parrot}), "Able to copy Parrot::SHA1");
    my $cache = q{.parrot_current_sha1};
    open my $FH, ">", $cache
        or croak "Unable to open $cache for writing";
    print $FH qq{$sha1\n};
    close $FH or croak "Unable to close $cache after writing";
    return ($cache, $libdir);
}

################### DOCUMENTATION ###################

=head1 NAME

064-sha1_from_cache.t - test Parrot::SHA1

=head1 SYNOPSIS

    % prove t/configure/064-sha1_from_cache.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::SHA1 (F<lib/Parrot/SHA1.pm>).

=head1 AUTHOR

Jonathan "Duke" Leto

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
