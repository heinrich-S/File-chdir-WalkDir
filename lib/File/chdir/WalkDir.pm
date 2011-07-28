package File::chdir::WalkDir;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT = ( qw/walkdir/ );

use File::Spec::Functions 'no_upwards';
use File::chdir;

sub walkdir {

  my ($dir, $code_ref, @excluded_patterns) = @_;

  local $CWD = $dir;
  opendir( my $dh, $CWD);
  #print "In: $CWD\n";

  FILE: while ( my $entry = readdir $dh ) {
    
    # next if the $entry refers to a '.' or '..' like construct
    next unless no_upwards( $entry );
    
    foreach my $pattern (@excluded_patterns) {
      next FILE if ($entry =~ $pattern);
    }  

    if (-d $entry) {
      next if (-l $entry); # skip linked directories
      walkdir($entry, $code_ref, @excluded_patterns);
    } else {
      $code_ref->($entry, $CWD);
    }

  }

}

1;

__END__
__POD__

=head1 NAME

File::chdir::WalkDir

=head1 SYNOPSIS

 use File::chdir::WalkDir

 my $do_something = sub {
   my ($filename, $directory) = @_;

   ...
 }

 walkdir( $dir, $do_something, qr/^\./ );
 # executes $do_something->($filename, $directory) [$directory is the folder
 # containing $filename] for all files within the directory and all 
 # subdirectories. In this case excluding all files and folders that 
 # are named with a leading `.'.

=head1 DESCRIPTION

This module is a wrapper around David Golden's excellent module L<File::chdir> for walking directories and all subdirectories and executing code on all files which meet certain criteria.

=head1 FUNCTION

=head2 walkdir( $dir, $code_ref [, @exclusion_patterns ]);

C<walkdir> takes a base directory (either absolute or relative to the current working directory) and a code reference to be executed for each (qualifing) file. This code reference will by called with the arguments (i.e. C<@_>) containing the filename and the full folder that contains it. Through the magic of C<File::chdir>, the working directory when the code is executed will also be the folder containing the file.

Optionally exclusion patterns (i.e. C<qr//>) may by passed which will exclude BOTH files AND directories (and hence all subfiles/subdirectories) which match any of the patterns. This is a coarse exclusion. Fine detail may be used in excluding files by returning early from the code reference.

Note: C<walkdir> will act on symlinked files but not on symlinked folders to prevent unwanted actions outside the folder and to prevent infinite loops. To exclude symlinked files too add a line like C<return if (-l $filename);> near the top of the code to be executed; this is an example of the fine exclusion mentioned above.

=head1 SOURCE REPOSITORY

L<http://github.com/jberger/File-chdir-WalkDir>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Joel Berger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

