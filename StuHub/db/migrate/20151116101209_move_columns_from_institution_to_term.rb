class MoveColumnsFromInstitutionToTerm < ActiveRecord::Migration
  def up
    remove_column :institutions, :data_mode
    remove_column :institutions, :xlsx_db_url
    remove_column :institutions, :api_endpoint
    remove_column :institutions, :data_last_updated

    add_column :terms, :year, :string
    add_column :terms, :term_reference, :string
    add_column :terms, :data_mode, :integer, default: 0
    add_column :terms, :data_url, :string
    add_column :terms, :data_last_updated, :datetime
    add_reference :terms, :institution, index: true, foreign_key: true
    remove_reference :terms, :year

    add_index :terms, [:institution_id, :term_reference], unique: true
  end

  def down
    add_column :institutions, :data_mode, :integer, default: 0
    add_column :institutions, :xlsx_db_url, :string
    add_column :institutions, :api_endpoint, :string
    add_column :institutions, :data_last_updated, :datetime

    remove_column :terms, :year
    remove_column :terms, :term_reference
    remove_column :terms, :data_mode
    remove_column :terms, :data_url
    remove_column :terms, :data_last_updated
    remove_reference :terms, :institution
    add_reference :terms, :year, index: true, foreign_key: true
  end
end
