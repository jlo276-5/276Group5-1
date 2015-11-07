class CreateJoinTableCourseMembershipSection < ActiveRecord::Migration
  def change
    create_join_table :course_memberships, :sections do |t|
      t.index [:course_membership_id, :section_id], unique: true, name: "index_cms_on_cm_id_and_section_id"
    end
  end
end
