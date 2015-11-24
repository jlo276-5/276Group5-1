class ModifyDataSourcesInTerm < ActiveRecord::Migration
  def up
    add_column :terms, :database_url, :string
    add_column :terms, :database_contains_enrollment, :boolean, default: false
  end

  def down
    remove_column :terms, :database_url
    remove_column :terms, :database_contains_enrollment
  end

end
