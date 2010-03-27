package Lingua::EN::SimilarNames::Levenshtein;

use MooseX::Declare;
use Text::LevenshteinXS qw(distance);
use Math::Combinatorics;
use strict;
use warnings;
use 5.010;

our $VERSION = '0.02';

=head1 Name
 
Lingua::EN::SimilarNames::Levenshtein - Compare people first and last names.

=head1 Synopsis

    my $first_person = Person->new(
        first_name => 'John',
        last_name  => 'Wayne',
    );
    my $second_person = Person->new(
        first_name => 'Sundance',
        last_name  => 'Kid',
    );
    my $third_person = Person->new(
        first_name => 'Jose',
        last_name  => 'Wales',
    );
    my $fourth_person = Person->new(
        first_name => 'John',
        last_name  => 'Wall',
    );
    my @list_of_people = ($first_person, $second_person, $third_person, $fourth_person);
    my $people = SimilarNames->new(list_of_people => \@list_of_people, maximum_distance => 5);
    my $people_with_similar_names  = $people->list_of_people_with_similar_names;
 
=head1 Description
 
Given a list of people objects, find the people whose names are within a 
specified edit distance.  The result is an ArrayRef[ArrayRef[Str]].
 
=cut

=head1 Classes

=head2 Person

This class defines people objects with first and last name attributes.

=cut

class Person {
    has 'first_name' => (isa => 'Str', is => 'ro', default => '');
    has 'last_name'  => (isa => 'Str', is => 'ro', default => '');
    has 'full_name'  => (
        isa        => 'Str',
        is         => 'ro',
        lazy_build => 1,
    );

    method say_name() {
        say $self->full_name;
      }

      method _build_full_name {
        return $self->first_name . ' ' . $self->last_name;
      }
}

=head2 ComparTwoNames

This class defines comparator objects.  Given two Person objects, 
it computes the edit distance between their names.

=cut

class CompareTwoNames {
    has 'one_person'     => (isa => 'Person', is => 'rw');
    has 'another_person' => (isa => 'Person', is => 'rw');
    has 'distance_between' => (
        isa        => 'Int',
        is         => 'ro',
        lazy_build => 1,
    );

    method _build_distance_between() {
        return Text::LevenshteinXS::distance($self->one_person->first_name,
            $self->another_person->first_name) +
          Text::LevenshteinXS::distance($self->one_person->last_name,
            $self->another_person->last_name);
    };
}

=head2 SimilarNames

This class takes a list of Person objects and uses CompareTwoNames to
generate a list of people with similar names based on an edit distance range.

One can get at the list of Person object pairs with similar name via the 
C<list_of_people_with_similar_names> attribute.  Alternatively, one can 
get at list of the names pairs themselves (no Person object) via the
C<list_of_similar_name_pairs> attribute.

=cut

class SimilarNames {
    has 'list_of_people' => (
        isa        => 'ArrayRef[Person]',
        is         => 'ro',
        lazy_build => 1
    );
    has 'minimum_distance' => (isa => 'Int', is => 'rw', default => 1);
    has 'maximum_distance' => (isa => 'Int', is => 'rw', default => 3);
    has 'list_of_people_with_similar_names' => (
        isa        => 'ArrayRef[ArrayRef[Person]]',
        is         => 'ro',
        lazy_build => 1
    );
    has 'list_of_similar_name_pairs' => (
        isa        => 'ArrayRef[ArrayRef[ArrayRef[Str]]]',
        is         => 'ro',
        lazy_build => 1
    );

    method _build_list_of_people_with_similar_names() {
        my $people_tuples = Math::Combinatorics->new(
            count => 2,                       # This could be abstracted
            data  => $self->list_of_people,
        );
          my @list_of_people_with_similar_names;
          while (my ($first_person, $second_person) = $people_tuples->next_combination()) {
            my $name_comparison = CompareTwoNames->new(
                one_person     => $first_person,
                another_person => $second_person,
            );
            my $distance_between_names = $name_comparison->distance_between();
            if (   ($distance_between_names >= $self->minimum_distance)
                && ($distance_between_names <= $self->maximum_distance))
            {
                push @list_of_people_with_similar_names, [ $first_person, $second_person ];
            }
        }

        return \@list_of_people_with_similar_names
    };

    method _build_list_of_similar_name_pairs() {
        my @list_of_similar_name_pairs;
        foreach my $pair_of_people (@{ $self->list_of_people_with_similar_names }) {
            push @list_of_similar_name_pairs,
              [
                [ $pair_of_people->[0]->first_name, $pair_of_people->[0]->last_name ],
                [ $pair_of_people->[1]->first_name, $pair_of_people->[1]->last_name ]
              ];
        }
        return \@list_of_similar_name_pairs
    };
}

__END__

=head1 Accessors
 
=head2 list_of_similar_name_pairs

This is called on a SimilarNames object to return a list of similar 
name pairs for the list of Person objects passed in.  It uses the Levenshtein 
edit distance.  This means the names are close to one another in spelling.

=head2 list_of_people_with_similar_name

This accessor is similar to the C<list_of_similar_name_pairs> but returns a 
list of Person object pairs instead of the names.

=head1 Authors
 
Mateu X. Hunter C<hunter@missoula.org>
 
=head1 Copyright
 
Copyright 2010, Mateu X. Hunter
 
=head1 License
 
You may distribute this code under the same terms as Perl itself.

=head1 Code Repository



=cut

1
