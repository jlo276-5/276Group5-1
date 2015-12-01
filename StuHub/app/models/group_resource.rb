class GroupResource < Resource
  belongs_to :group

  validates_associated :group

end
