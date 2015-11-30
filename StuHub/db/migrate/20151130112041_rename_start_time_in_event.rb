class RenameStartTimeInEvent < ActiveRecord::Migration
  def change
    rename_column :events, :strat_time, :start_time
  end
end
