class ContactRequest < ActiveRecord::Base
  validates :name, :title, :body, presence: true
  validates :email, length: {minimum: 6}
  validates :contact_type, numericality: {integer_only: true, less_than_or_equal_to: 3, greater_than_or_equal_to: 0}

  def type_string
    if self.contact_type == 0
      return "Feedback"
    elsif self.contact_type == 1
      return "Complaint"
    elsif self.contact_type == 2
      return "Bug"
    else
      return "Other"
    end
  end

  def table_row_type
    if self.contact_type == 0
      return "success"
    elsif self.contact_type == 1
      return "warning"
    elsif self.contact_type == 2
      return "danger"
    else
      return "info"
    end
  end
end
