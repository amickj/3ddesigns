@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl -w
#line 15
# $Id: use-devel-checklib,v 1.9 2008/03/12 19:52:50 drhyde Exp $

use strict;

$/ = undef;

use File::Spec;
use Devel::CheckLib;

warn "----------------------- [WARNING] --------\n";
warn "THIS SCRIPT WAS DEPRECATED.\n";
warn "YOU SHOULD USE configure_requires INSTEAD.\n";
warn "---------- [/WARNING] --------------------\n";

my @files = grep { -f $_ } qw(Makefile.PL Build.PL);
push @files, 'Makefile.PL' unless(@files);

my @libs = @ARGV;

mkdir 'inc';
mkdir 'inc/Devel';

open(CHECKLIBPM, $INC{'Devel/CheckLib.pm'}) ||
    die("Can't read $INC{'Devel/CheckLib.pm'}: $!");
(my $checklibpm = <CHECKLIBPM>) =~ s/package Devel::CheckLib/package #\nDevel::CheckLib/;
close(CHECKLIBPM);
open(CHECKLIBPM, '>'.File::Spec->catfile(qw(inc Devel CheckLib.pm))) ||
    die("Can't write inc/Devel/CheckLib.pm: $!");
print CHECKLIBPM $checklibpm;
close(CHECKLIBPM);

print "Copied Devel::CheckLib to inc/ directory\n";

foreach my $file (@files) {
    open(FILE, $file) || next;
    my $contents = <FILE>;
    close(FILE);
    open(FILE, ">$file") || die("Can't write $file\n");
    print FILE q{use lib qw(inc);
use Devel::CheckLib;

# Prompt the user here for any paths and other configuration

check_lib_or_exit(
    # fill in what you prompted the user for here
    lib => [qw(}.join(' ', @libs).q{)]
);
};
    print FILE "\n\n$contents";
    close(FILE);
    print "Updated/created $file\n";
}

open(MANIFEST, 'MANIFEST') || warn("Couldn't read MANIFEST, will create one\n");
my $manifest = <MANIFEST>;
close(MANIFEST);
open(MANIFEST, '>MANIFEST') || die("Couldn't write MANIFEST\n");
print MANIFEST "inc/Devel/CheckLib.pm\n$manifest";
close(MANIFEST);
print "Updated/created MANIFEST\n";

=head1 NAME

use-devel-checklib - (DEPRECATED)a script to package Devel::CheckLib with your code.

=head1 DESCRIPTION

This script was DEPRECATED.

If you need to depend on this library, you should use `configure_requires` in Makefile.PL or Build.PL instead.

=head1 WARNINGS, BUGS and FEEDBACK

This script has not been thoroughly tested.  You should check by
hand that it has done what you expected after running it.

If you use Module::Build::Compat to write a Makefile.PL, then you
will need to re-run this script whenever you have generated a new
Makefile.PL.

I welcome feedback about my code, including constructive criticism.
Bug reports should be made using L<http://rt.cpan.org/> or by email.

=head1 SEE ALSO

L<Devel::CheckLib>

=head1 AUTHOR

David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

=head1 COPYRIGHT and LICENCE

Copyright 2007 David Cantrell

This software is free-as-in-speech software, and may be used,
distributed, and modified under the same conditions as perl itself.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

__END__
:endofperl
