class AgentInfo < ActiveRecord::Base

  enum status: [ :init, :active, :locked ]

  validates_presence_of :name, :category, :industry, :city, :contact, :telephone

  belongs_to :agent

end
