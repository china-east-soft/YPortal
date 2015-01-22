class User < ActiveRecord::Base
  after_create :register_to_huanxin, if: "mobile_number.present?"

  has_many :comments
  has_many :point_details
  has_many :user_check_ins
  has_many :watchings

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

  has_many :passive_blacklists, class_name: "Blacklist", foreign_key: "blocked_id", dependent: :destroy
  has_many :blockers, through: :passive_blacklists, source: :blocker


  belongs_to :program

  def guide_now
    if program
      program.guide_now
    end
  end


  # 使用了环信的聊天服务，所以用户体系需要和环信融合(使用用户的id的md5作为环信的username，详情见oa上项目wiki)
  # 向环信发起注册我们的用户体系的时候因为网络或者环信的原因是有可能注册失败的，所以采用了预先向环信
  # 注册的方案。就是我们预先生成一批信息为空的user，使用这些user的id向环信注册。
  # 然后APP发起注册的时候再从这些user中选一个出来填上用户信息返回给app。
  #User.all will return all users which mobile_number is not nil, other query method will be impressed, too
  #use User.unscoped.all  query all users
  default_scope { where.not(mobile_number: nil) }

  scope :unused_users, -> { unscoped.where(mobile_number: nil) }
  scope :unused_users_and_not_reg, -> { unused_users.where(register_huanxin: false) }
  scope :unused_reged_users, -> { unused_users.where(register_huanxin: true) }

  has_secure_password

  validates :mobile_number, uniqueness: true, presence: true, format: {with: /\A\d{11}\z/}

  #validates :name, presence: true
  #validates :gender, inclusion: {in: %w(male female)}, presence: true

  validates :status, inclusion: {in: %w(online offline)}, if: "status.present?"

  has_attached_file :gravatar
  validates_attachment_content_type :gravatar, :content_type => /.*/
  validates :avatar_type, inclusion: {in: %W{system custom}, message: "%{value} is not a valid type"}, if: "avatar_type.present?"

  def custom_avatar?
    avatar_type == "custom"
  end

  def system_avatar?
    avatar_type == "system"
  end

  def online?
    status == "online"
  end

  def name
    if name = read_attribute(:name)
      name
    else
      "用户#{id}"
    end
  end

  def gender_tr
    case gender
    when "male"
      "男"
    when "female"
      "女"
    end
  end


  #Lv1 0-49
  #Lv2 50-199
  #Lv3 200-499
  #Lv4 500-999
  #Lv5 1000-2999
  #Lv6 3000-9999
  #Lv7 10000-29999
  #Lv8 30000-59999
  #Lv9 60000-999999
  #Lv10(Max) >100000
  def level
    case experience
    when 0..1049
      1
    when 1050..1199
      2
    when 1200..1499
      3
    when 1500..1999
      4
    when 2000..3999
      5
    when 4000..9999
      6
    when 10000..29999
      7
    when 30000..59999
      8
    when 60000..99999
      9
    when 100000...Float::INFINITY
      10
    end
  end


  #geocoded_by :address
  #after_save :geocode
  #geocode函数向地图服务可以根据address 请求lat和long信息，默认是google map， 本应用不用这个功能，latitude和longitude是APP传过来的
  reverse_geocoded_by :latitude, :longitude  #tell model use geocode


  def follow(other_user)
    if (self == other_user) || other_user.blocked?(self)
      false
    else
      if blocked?(other_user)
        # active_blacklists.find_by(blocked_id: other_user.id).destroy
        unblock other_user
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

    HuanxinFriendWorker.perform_async(self.id, :block_user, other_user.id)
  end

  def unblock(other_user)
    active_blacklists.find_by(blocked_id: other_user.id).destroy
    HuanxinFriendWorker.perform_async(self.id, :unblock_user, other_user.id)
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

  private
  def register_to_huanxin
    HuanxinUserWorker.perform_async(self.id, :register_user)
  end

end
