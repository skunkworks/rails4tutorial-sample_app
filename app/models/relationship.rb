class Relationship < ActiveRecord::Base
  # Rails is smart about figuring out our intentions. It knows that because we declare
  # that a relationship belongs to "follower" and "followed" that the foreign ids will
  # correspond to follower_id and followed_id. However, it needs some help to figure out
  # what model class it belongs to if there isn't a Follower or Followed class.
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
