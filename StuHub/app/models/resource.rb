class Resource < ActiveRecord::Base
  cattr_accessor :permitted_types
  @@permitted_types = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'application/rtf', 'text/plain']

  belongs_to :user
  validates :name, :description, :file_name, presence: true
  validates :content_type, inclusion: { in: @@permitted_types }

  def file_type_string
    case self.content_type
    when 'image/jpeg'
      return "JPEG"
    when 'image/png'
      return "PNG"
    when 'image/gif'
      return "GIF"
    when 'application/pdf'
      return "PDF"
    when 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      return "Excel"
    when 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      return "Word"
    when 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
      return "Powerpoint"
    when 'text/plain', 'application/rtf'
      return "Text"
    else
      return "Unknown"
    end
  end
end
