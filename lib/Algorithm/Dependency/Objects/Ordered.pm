#!/usr/bin/perl

package Algorithm::Dependency::Objects::Ordered;
use base qw/Algorithm::Dependency::Objects/;

use strict;
use warnings;

our $VERSION = '0.01';

use Scalar::Util qw/refaddr/;
use Carp qw/croak/;

sub schedule {
	my $self = shift;
	$self->_order($self->SUPER::schedule(@_));
}

sub schedule_all {
	my $self = shift;
	$self->_order($self->SUPER::schedule_all(@_));
}

sub _order {
	my $self = shift;
	my @queue = @_;


	my $selected = Set::Object->new->union($self->selected);

	my $error_marker;
	my @schedule;

	my %dep_set; # a cache of Set::Objects for $obj->depends

	while (@queue){
		my $obj = shift @queue;
		croak "Circular dependency detected!"
			if (defined($error_marker) and refaddr($error_marker) == refaddr($obj));
		
		my $dep_set = $dep_set{refaddr $obj} ||= Set::Object->new($obj->depends);

		unless ($dep_set->subset($selected)){
			# we have some missing deps
			# put the object back in the queue
			push @queue, $obj;

			# if we encounter it again without any change
			# then a circular dependency is detected
			$error_marker = $obj unless defined $error_marker;
		} else {
			# the dependancies are a subset of the selected objects,
			# so they are all resolved.
			push @schedule, $obj;

			# mark the object as selected
			$selected->insert($obj);

			# since something changed we can forget about the error marker
			undef $error_marker;
		}
	}

	# return the ordered list
	@schedule;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Algorithm::Dependency::Objects::Ordered - An ordered dependency set

=head1 SYNOPSIS

	use Algorithm::Dependency::Objects::Ordered;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<new>

=item B<objects>

=item B<selected>

=item B<depends>

=item B<schedule>

=item B<schedule_all>

=back

=head1 SEE ALSO

Adam Kennedy's excellent L<Algorithm::Dependency::Ordered> module, upon which this is based.

=head1 BUGS

None that we are aware of. Of course, if you find a bug, let us know, and we will be sure to fix it.

=head1 CODE COVERAGE

We use Devel::Cover to test the code coverage of our tests, see the CODE COVERAGE section of L<Algorithm::Dependency::Objects> for more information.

=head1 AUTHORS

Yuval Kogman

Stevan Little

COPYRIGHT AND LICENSE 

Copyright (C) 2005 Yuval Kogman, Stevan Little

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
