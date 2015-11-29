class AddInstitutionToGroup < ActiveRecord::Migration
  def change
    add_reference :groups, :institution, index: true, foreign_key: true
  end
end
