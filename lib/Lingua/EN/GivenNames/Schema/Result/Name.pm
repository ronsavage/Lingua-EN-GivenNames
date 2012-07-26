use utf8;
package Lingua::EN::GivenNames::Schema::Result::Name;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Lingua::EN::GivenNames::Schema::Result::Name

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<names>

=cut

__PACKAGE__->table("names");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 derivation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 form_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 kind_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 meaning_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 original_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sex_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 fc_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "derivation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "form_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "kind_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "meaning_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "original_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sex_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "fc_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 derivation

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Derivation>

=cut

__PACKAGE__->belongs_to(
  "derivation",
  "Lingua::EN::GivenNames::Schema::Result::Derivation",
  { id => "derivation_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 form

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Form>

=cut

__PACKAGE__->belongs_to(
  "form",
  "Lingua::EN::GivenNames::Schema::Result::Form",
  { id => "form_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 kind

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Kind>

=cut

__PACKAGE__->belongs_to(
  "kind",
  "Lingua::EN::GivenNames::Schema::Result::Kind",
  { id => "kind_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 meaning

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Meaning>

=cut

__PACKAGE__->belongs_to(
  "meaning",
  "Lingua::EN::GivenNames::Schema::Result::Meaning",
  { id => "meaning_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 original

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Original>

=cut

__PACKAGE__->belongs_to(
  "original",
  "Lingua::EN::GivenNames::Schema::Result::Original",
  { id => "original_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 sex

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Sex>

=cut

__PACKAGE__->belongs_to(
  "sex",
  "Lingua::EN::GivenNames::Schema::Result::Sex",
  { id => "sex_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 source

Type: belongs_to

Related object: L<Lingua::EN::GivenNames::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Lingua::EN::GivenNames::Schema::Result::Source",
  { id => "source_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-07-26 13:46:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:faVVBJpvpEpUNO4GMgjZ+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
