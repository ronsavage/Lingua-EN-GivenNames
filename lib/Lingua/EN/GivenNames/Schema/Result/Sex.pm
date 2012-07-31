use utf8;
package Lingua::EN::GivenNames::Schema::Result::Sex;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Lingua::EN::GivenNames::Schema::Result::Sex

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sexes>

=cut

__PACKAGE__->table("sexes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 fc_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "fc_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 names

Type: has_many

Related object: L<Lingua::EN::GivenNames::Schema::Result::Name>

=cut

__PACKAGE__->has_many(
  "names",
  "Lingua::EN::GivenNames::Schema::Result::Name",
  { "foreign.sex_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-07-31 17:18:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mOyekd/Ig8OnvQ9zPowIsg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
