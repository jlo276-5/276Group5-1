class AddUpdatingLockToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :updating, :boolean, default: false
  end
end
