class User < ActiveRecord::Base
  belongs_to :institution
  has_one :privacy_setting, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :course_memberships, dependent: :destroy
  has_many :courses, through: :course_memberships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :group_membership_requests, dependent: :destroy
  accepts_nested_attributes_for :privacy_setting
  accepts_nested_attributes_for :user_interests, allow_destroy: true

  before_destroy :send_deletion_email

  attr_accessor :remember_token, :activation_token, :reset_token, :email_change_token
  ##check upper case
  before_save   :downcase_email
  before_create :create_activation_digest
  ## check name exist and length
  validates :name, length: { maximum: 50 }
  validates :tos_agree, acceptance: true
  validates :role, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2}
  validates :cas_identifier, allow_blank: true, uniqueness: true

  def name
    read_attribute(:name) || read_attribute(:email).partition('@').first
  end

  ## check email format
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  ## check email exist and length
   validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
  validates :email_change_new, allow_nil: true, length: { maximum: 255 },
                     format: { with: VALID_EMAIL_REGEX },
                     uniqueness: { scope: :email, case_sensitive: false }
  validate :validate_email_domain, on: :create, if: 'cas_identifier.nil?'
  validate :validate_new_email_unique, on: :update, if: '!email_change_new.nil?'

  ##activate
  def activate
    update_attribute(:activation_digest, nil)
    update_attribute(:activated,         true)
    update_attribute(:activated_at,      Time.zone.now)
  end

  # send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def reset_reset_digest
    update_attribute(:reset_digest, nil)
    update_attribute(:reset_sent_at, nil)
  end

  def create_email_change_digest
    self.email_change_token = User.new_token
    update_attribute(:email_change_digest, User.digest(email_change_token))
    update_attribute(:email_change_requested_at, Time.zone.now)
  end

  def reset_email_change_digest
    update_attribute(:email_change_digest, nil)
    update_attribute(:email_change_new, nil)
    update_attribute(:email_change_requested_at, nil)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def send_email_change_email
    UserMailer.email_change(self).deliver_now
  end

  def send_password_change_success_email
    UserMailer.password_change_success(self).deliver_now
  end

  def send_deletion_email
    UserMailer.account_deletion(self).deliver_now
  end

  def lock_account
    update_attribute(:account_locked, true)
    UserMailer.account_locked(self).deliver_now
  end

  def unlock_account
    update_attribute(:account_locked, false)
    update_attribute(:failed_login_attempts, 0)
  end

  #check if password exist
  has_secure_password

  #check length of password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  ## return a radom password token
  def User.new_token
     SecureRandom.urlsafe_base64
  end

  # Remember User
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # forget user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # return true if everything matches
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # returns true if not expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def email_change_expired?
    email_change_requested_at < 2.hours.ago
  end

  # The Power
  def admin?
    return true if self.role > 0
  end

  # More Power
  def superuser?
    return true if self.role > 1
  end

  # Get All The Power
  def more_powerful(than, user)
    if than
      return self.role > user.role
    else
      return self.role >= user.role
    end
  end

  # Strings
  def role_string_long
    if self.role == 0
      return "Standard User"
    elsif self.role == 1
      return "Administrator"
    elsif self.role == 2
      return "Super User"
    else
      return "Unknown Role"
    end
  end

  def role_string
    if self.role == 0
      return "Standard"
    elsif self.role == 1
      return "Admin"
    elsif self.role == 2
      return "Super"
    else
      return "Unknown"
    end
  end

  def gender_string
    if self.gender == 1
      return "Male"
    elsif self.gender == 2
      return "Female"
    else
      return "Unspecified"
    end
  end

  def memberOfCourse?(course)
    return !self.courses.find_by(id: course.id).nil?
  end

  def memberOfGroup?(group)
    return !self.groups.find_by(id: group.id).nil?
  end

  def adminOfGroup?(group)
    gm = self.group_memberships.find_by(group_id: group.id)
    return (!gm.nil? and gm.role == 1)
  end

  def current_course_memberships
    ccm = []
    unless self.institution.nil? or self.institution.current_term.nil?
      c_t = self.institution.current_term
      self.course_memberships.includes(course: [{department: :term}]).each do |cm|
        if cm.course.term == c_t
          ccm << cm
        end
      end
    end
    return ccm
  end

  def next_course_memberships
    ccm = []
    unless self.institution.nil? or self.institution.next_term.nil?
      n_t = self.institution.next_term
      self.course_memberships.includes(course: [{department: :term}]).each do |cm|
        if cm.course.term == n_t
          ccm << cm
        end
      end
    end
    return ccm
  end

  def current_courses
    current = []
    unless self.institution.nil? or self.institution.current_term.nil?
      c_t = self.institution.current_term
      self.courses.includes(department: :term).each do |c|
        if c.term == c_t
          current << c
        end
      end
    end
    return current
  end

  def next_courses
    nextcourses = []
    unless self.institution.nil? or self.institution.next_term.nil?
      n_t = self.institution.next_term
      self.courses.includes(department: :term).each do |c|
        if c.term == n_t
          nextcourses << c
        end
      end
    end
    return nextcourses
  end

  private

    def validate_email_domain
      unless self.institution_id.nil? or (!self.institution_id.blank? and !self.email.blank? and (self.email.ends_with?("@" + Institution.find(self.institution_id).email_constraint) or self.email.ends_with?("." + Institution.find(self.institution_id).email_constraint)))
        errors.add(:email, "contains an invalid domain for the selected institution")
      end
    end

    def validate_new_email_unique
      unless User.find_by(email: self.email_change_new).nil?
        errors.add(:new_email, "must be unique")
      end
    end

    # change email address into lowercase
    def downcase_email
      self.email = email.downcase
    end

    # create and generate password to activate
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
