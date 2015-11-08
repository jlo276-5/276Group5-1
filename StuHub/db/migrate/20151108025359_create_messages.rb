class CreateMessages < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.text :content
    end
  end
end
