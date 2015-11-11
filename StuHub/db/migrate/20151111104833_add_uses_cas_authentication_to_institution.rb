class AddUsesCasAuthenticationToInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :uses_cas, :boolean, default: false
    add_column :institutions, :cas_endpoint, :string

    add_index :institutions, :uses_cas
  end
end
