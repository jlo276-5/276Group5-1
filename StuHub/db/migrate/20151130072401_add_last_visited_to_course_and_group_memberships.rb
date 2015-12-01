class AddLastVisitedToCourseAndGroupMemberships < ActiveRecord::Migration
  def change
    add_column :group_memberships, :last_visited_at, :datetime
    add_column :course_memberships, :last_visited_at, :datetime
  end
end
