class Institution < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :terms, dependent: :destroy

  def current_term
    term = terms.order("enrollment_start_date DESC").first
    terms.order("enrollment_start_date DESC") do |t|
      if (t.start_date..t.exams_end_date).cover?(Time.now)
        term = t
        break
      end
    end
    return term
  end

  def next_term
    term = terms.order("enrollment_start_date DESC").first
    terms.order("enrollment_start_date DESC") do |t|
      if (t.enrollment_start_date..t.start_date).cover?(Time.now)
        term = t
        break
      end
    end
    return term
  end
end
