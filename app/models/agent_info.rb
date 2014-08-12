class AgentInfo < ActiveRecord::Base

  enum status: [ :init, :active]

  validates_presence_of :name, :category, :industry, :city, :contact, :telephone

  belongs_to :agent

end
