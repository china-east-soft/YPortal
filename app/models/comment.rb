class Comment < ActiveRecord::Base

  belongs_to :program, counter_cache: true

  validates_presence_of :mac, :channel, alloc_blank: false
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
  end



  def audio?
    content_type == "audio"
  end

  def text?
    content_type == "text"
  end
end
