class User < ApplicationRecord
  attr_accessor :remember_token
  before_save {self.email = email.downcase}
  validates :username,  presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[ ia-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum:6}, allow_nil: true
  # validates :name, presence: true

  def self.create_from_facebook(auth)
    User.create!(
      facebook_id: auth['uid'],
      username: auth['info']['name'],
      email: auth['info']['email'],
      password: SecureRandom.hex(10)
    )
  end
  def User.new_token
     SecureRandom.urlsafe_base64
  end
  def self.new_token
     SecureRandom.urlsafe_base64
  end

 def remember
   self.remember_token = User.new_token
   update_attribute(:remember_digest, User.digest(remember_token))
 end

 # Returns true if the given token matches the digest.
 def authenticated?(remember_token)
   return false if remember_digest.nil?
   BCrypt::Password.new(remember_digest).is_password?(remember_token)
 end

 # Returns the hash digest of the given string.
 def self.digest(string)
   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                 BCrypt::Engine.cost
   BCrypt::Password.create(string, cost: cost)
 end

 # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

end
