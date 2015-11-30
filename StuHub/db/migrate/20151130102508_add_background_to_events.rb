class AddBackgroundToEvents < ActiveRecord::Migration
  def change
    add_column :events, :if_background, :boolean
  end
end
