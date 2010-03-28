use Lingua::EN::SimilarNames::Levenshtein;
use strict;
use warnings;
use Test::More;

my $rocker = Person->new(
    first_name => 'John',
    last_name  => 'Mellencamp'
);
isa_ok($rocker, 'Person');
can_ok('Person', qw/ first_name last_name /) || BAIL_OUT("first_name and last_name methods needed");

my $rapper = Person->new(
    first_name => 'M.C.',
    last_name  => 'Solaar'
);
is($rocker->first_name, 'John',   'Rocker First Name');
is($rapper->last_name,  'Solaar', 'Rapper Last Name');

my $compare_names_of_two_people = CompareTwoNames->new(
    one_person     => $rocker,
    another_person => $rapper,
);
isa_ok($compare_names_of_two_people, 'CompareTwoNames');
can_ok('CompareTwoNames', qw/ distance_between /) || BAIL_OUT("distance_between method needed");
my $expected_distance_between = 12;
is($compare_names_of_two_people->distance_between,
    $expected_distance_between, 'Distance between two people\'s name');

my $people =
  [ [ 'John', 'Wayne' ], [ 'Sundance', 'Kid' ], [ 'Jose', 'Wales' ], [ 'John', 'Wall' ], ];
my @people_objects = map { Person->new(first_name => $_->[0], last_name => $_->[1]) } @{$people};

my $similar_people = SimilarNames->new(list_of_people => \@people_objects, maximum_distance => 5);
isa_ok($similar_people, 'SimilarNames');
can_ok('SimilarNames', qw/ list_of_similar_name_pairs list_of_people_with_similar_names /);
my $expected_list = [
    [ [ "Jose", "Wales" ], [ "John", "Wall" ] ],
    [ [ "Jose", "Wales" ], [ "John", "Wayne" ] ],
    [ [ "John", "Wall" ],  [ "John", "Wayne" ] ]
];
is_deeply($similar_people->list_of_similar_name_pairs,
    $expected_list, 'Similar Pairs of People Names (first, last)');

done_testing();

