class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  # We have to specify the foreign key explicitly, since AR convention by default would look
  # for a foreign key named user_id.
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_relationships, foreign_key: 'followed_id',
                                   class_name:  'Relationship',
                                   dependent:   :destroy
  # We want User objects to respond to a followed_users method that returns a collection of
  # followed users. We can do this by establishing a has_many association through
  # relationships.
  # 
  # A relationship object responds to the #followed method and returns an AR User object.
  # We can specify that a user has many followed users by going *through* the relationship
  # model. Convention dictates that the relationships table should have a foreign key that
  # matches the name of this method (i.e. followed_user_id)
  has_many :followed_users, through: :relationships, source: :followed
  # Don't have to specify source because "followers" matches the convention of the foreign
  # key convention by looking for follower_id.
  has_many :followers,      through: :reverse_relationships

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
    # TODO: We'll change this to be better!
    microposts
  end

  def follow!(user)
    self.relationships.create!(followed_id: user.id)
  end

  def unfollow!(user)
    self.relationships.find_by(followed_id: user.id).destroy!
  end

  def following?(user)
    self.relationships.find_by(followed_id: user.id)
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