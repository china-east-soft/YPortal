class User < ActiveRecord::Base

  has_many :comments

  #active stand for a  follow b actived
  has_many :active_relationships, -> { normal }, class_name: "Relationship",
                                  foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: "followed"

  #passive stand for b followed by a, so a is a follower of b
  has_many :passive_relationships, -> { normal }, class_name: "Relationship",
                                   foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  #active block user,  a block b
  has_many :block_relationships, -> { block }, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :blocked_users, through: :block_relationships, source: "followed"

  has_secure_password

  validates :mobile_number, uniqueness: true, presence: true, format: {with: /\A\d{11}\z/}
  validates :name, presence: true



  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include? other_user
  end

  def block(other_user)
  end

  def unblock(other_user)
  end

  def blocking?(other_user)
  end

end
