class AddCurrentTermToInstitution < ActiveRecord::Migration
  def change
    add_reference :institutions, :current_term, references: :terms
  end
end
