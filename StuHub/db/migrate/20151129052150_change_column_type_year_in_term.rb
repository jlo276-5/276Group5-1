class ChangeColumnTypeYearInTerm < ActiveRecord::Migration
  def change
    change_column :terms, :year, 'integer USING CAST(year AS integer)'
  end
end
