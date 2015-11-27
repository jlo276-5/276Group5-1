class AddDatabaseLastScannedLineToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :database_last_line, :integer, default: 0
  end
end
