class Comment < ActiveRecord::Base
  after_create :update_user_points, if: "user_id.present?"
  before_save :update_channel, if: "program_id.present?"

  belongs_to :program, counter_cache: true
  belongs_to :user

  has_many :children, class_name: "Comment"
  belongs_to :parent, class_name: "Comment", foreign_key: :parent_id

  validates_presence_of :mac, :channel, allow_blank: false
  validates_presence_of :body, if: :text?

  default_scope { order(id: :desc) }

  def self.comments_for_app(channel:, id: 0, limit: 20)
    #id == 0 present request for the newest record
    if id == 0
      where("created_at >= ?", Time.now - 4.hour).
        where(channel: channel).limit(limit)
    else
      where("created_at >= ?", Time.now - 4.hour).
        where("channel = :channel AND id < :id", {channel: channel, id: id}).limit(limit)
    end
  end

  #audio attachment
  has_attached_file :audio
  validates_attachment_content_type :audio, :content_type => /.*/
  validates :content_type, inclusion: {in: %w{text audio}, message: "%{value} is not a valid type"}, presence: true
  validates_presence_of :audio, if: :audio?


  #tree structrue(parent-child relationship)
  belongs_to :parent, class_name: "Comment"
  has_many :children, class_name: "Comment", foreign_key: "parent_id"

  def ancestor
    self.class.ancestor_for(self)
  end

  def self.ancestor_for(instance)
    unscoped.where("#{table_name}.id in (#{ancestor_sql_for(instance)})").order("#{table_name}.id asc")
  end

  #use postgresql with recursive for performace
  #不使用网易盖楼的方式，所以这个方法不用了，留在这边以备后面用吧
  def self.ancestor_sql_for(instance)
    ancestors_sql = <<-SQL
   WITH RECURSIVE search_ancestor_tree(id, parent_id, path) as (
     select id, parent_id, ARRAY[id] from #{table_name}
     where id = #{instance.id}
   UNION ALL
     SELECT #{table_name}.id, #{table_name}.parent_id, path || #{table_name}.id
     from search_ancestor_tree join #{table_name} on #{table_name}.id = search_ancestor_tree.parent_id where not #{table_name}.id = ANY(path)
   )
   select parent_id from search_ancestor_tree order by path
   SQL

   ancestors_sql
  end

  def audio?
    content_type == "audio"
  end

  def text?
    content_type == "text"
  end

  def update_channel
    if program.present?
      self.channel = program.channel
    end
  end

  def update_user_points
    PointDetail.create_by_user_id_and_rule_name(user_id: self.user_id, rule_name: "节目评论")
  end

end
