class AddDisplayScheduleToPrivacySetting < ActiveRecord::Migration
  def change
    add_column :privacy_settings, :display_schedule, :boolean, default: false
  end
end
