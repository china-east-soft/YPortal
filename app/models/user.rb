class User < ActiveRecord::Base

  has_many :comments
  has_many :point_details

  #active stand for a  follow b actived
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: "followed"

  #passive stand for b followed by a, so a is a follower of b
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  #active block user,  a block b
  # use another blacklist table
  # has_many :block_relationships, -> { block }, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # has_many :blocked_users, through: :block_relationships, source: "followed"

  has_many :active_blacklists, class_name: "Blacklist",
                                  foreign_key: "blocker_id", dependent: :destroy
  has_many :blocked_users, through: :active_blacklists, source: "blocked"

  has_secure_password

  validates :mobile_number, uniqueness: true, presence: true, format: {with: /\A\d{11}\z/}
  validates :name, presence: true
  validates :gender, inclusion: {in: %w(male female)}, presence: true

  def gender_tr
    case gender
    when "male"
      "男"
    when "female"
      "女"
    end
  end


  def follow(other_user)
    if (self == other_user) || other_user.blocked?(self)
      false
    else
      if blocked?(other_user)
        active_blacklists.find_by(blocked_id: other_user.id).destroy
      end

      active_relationships.create(followed_id: other_user.id)
    end
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include? other_user
  end


  def block(other_user)
    if self == other_user
      return false
    end

    if following?(other_user)
      unfollow other_user
    end

    if other_user.following? self
      other_user.unfollow self
    end

    active_blacklists.create(blocked_id: other_user.id)
  end

  def unblock(other_user)
    active_blacklists.find_by(blocked_id: other_user.id).destroy
  end

  def blocked?(other_user)
    blocked_users.include? other_user
  end


  #return integer
  #0: no relation
  #1: follow other user  and not be followed
  #2: not follow other user and be followed by other user
  #3: follow and be followed
  #4: block other user and not be blocked
  #5: not block other but be blocked by other user
  #6: block other and be blocked by other
  def relationship_with(other_user)

    follow = following? other_user
    be_followed = other_user.following? self
    block =  blocked? other_user
    be_blocked = other_user.blocked? self

    #0 stand for no relation
    relationship = 0

    if follow || be_followed
      if follow && !be_followed
        relationship = 1
      elsif be_followed && !follow
        relationship = 2
      elsif follow && be_followed
        relationship = 3
      end
    elsif block || be_blocked
      if block && !be_blocked
        relationship = 4
      elsif be_blocked && !block
        relationship = 5
      elsif block && be_blocked
        relationship = 6
      end
    end

    relationship
  end

end
