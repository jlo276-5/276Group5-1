class Institution < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :terms, dependent: :destroy

  def current_term
    unless current_term_id.nil?
      term = Term.find_by(id: current_term_id)
    end
  end
end
