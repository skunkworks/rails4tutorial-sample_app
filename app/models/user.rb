class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy

  before_save   { email.downcase! }
  # Before the user gets created in the DB, generate a remember token for them so that
  # they are not blank. We want this only on create, not on save (which would encompass
  # updates to the user)
  before_create :create_remember_token

  validates :name, 	presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: 	true,
  									format: 		{ with: VALID_EMAIL_REGEX },
  									uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }

  def feed
    microposts
  end

  # Generates a new remember token
  def self.new_remember_token
    # Generates a random URL-safe base64 string
    SecureRandom.urlsafe_base64
  end

  # Returns an encrypted form of the remember token
  def self.encrypt(token)
    # SHA1 is fast but not secure. That's okay -- we need it to be fast because
    # every page that a signed-in user accesses will need to encrypt?????
    Digest::SHA1.hexdigest(token.to_s)
  end

  private
    # Generates, encrypts, and then saves a new remember token for a user
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end