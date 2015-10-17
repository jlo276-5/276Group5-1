class User < ActiveRecord::Base
    
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
    validates :password, presence: true, length: { minimum: 6 }

end
