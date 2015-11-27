class AddTermOrderToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :term_order, :integer, default: 1
  end
end
