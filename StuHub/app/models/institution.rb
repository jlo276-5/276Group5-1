class Institution < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :terms, dependent: :destroy
  has_many :groups, dependent: :destroy

  def current_term
    terms.order("enrollment_start_date DESC").each do |t|
      if (t.start_date..t.exams_end_date).cover?(Time.now)
        return t
      end
    end
    return nil
  end

  def next_term
    self.terms.order("enrollment_start_date DESC").each do |t|
      if (t.enrollment_start_date..t.start_date).cover?(Time.now)
        return t
      end
    end
    return nil
  end
end
