use Lingua::EN::SimilarNames::Levenshtein;
use strict;
use warnings;
use Test::More;
use Data::Dumper::Concise;

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

is($first_person->first_name, 'John', 'Person First Name');
is($second_person->last_name, 'Kid',  'Person Last Name');

my $compare_names_of_two_people = CompareTwoNames->new(
    one_person     => $first_person,
    another_person => $second_person,
);
my $expected_distance_between = 12;
is($compare_names_of_two_people->distance_between,
    $expected_distance_between, 'Distance between two people\'s name');

my @list_of_people = ($first_person, $second_person, $third_person, $fourth_person);
my $similar_people = SimilarNames->new(list_of_people => \@list_of_people, maximum_distance => 5);
my $expected_list = [
    [ [ "Jose", "Wales" ], [ "John", "Wall" ] ],
    [ [ "Jose", "Wales" ], [ "John", "Wayne" ] ],
    [ [ "John", "Wall" ],  [ "John", "Wayne" ] ]
];

is_deeply($similar_people->list_of_similar_name_pairs,
    $expected_list, 'Similar Pairs of People Names (first, last)');
    
done_testing();

