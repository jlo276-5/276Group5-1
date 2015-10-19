class User < ActiveRecord::Base
    attr_accessor :remember_token, :activation_token
    ##check upper case
    before_save   :downcase_email
    before_create :create_activation_digest
    ##check upper case
    ## check name exist and length
     validates :name,  presence: true, length: { maximum: 50 }

    ## check email format
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    ## check email exist and length
     validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

    ##activate
    def activate
      update_attribute(:activated,    true)
      update_attribute(:activated_at, Time.zone.now)
    end

    # send activation email
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
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

   private

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
