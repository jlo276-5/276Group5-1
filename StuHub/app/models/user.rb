class User < ActiveRecord::Base
    attr_accessor :remember_token
    ##check upper case
    before_save {self.email = email.downcase}
    
    ## check name exist and length
     validates :name,  presence: true, length: { maximum: 50 }
    
    ## check email format
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    
    ## check email exist and length
     validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }
    
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
  
   # if token was paired with digest, return true
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
