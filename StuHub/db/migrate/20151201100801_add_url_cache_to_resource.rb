class AddUrlCacheToResource < ActiveRecord::Migration
  def change
    add_column :resources, :cached_url, :string
  end
end
