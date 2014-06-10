class AgentInfo < ActiveRecord::Base

  enum status: [ :init, :active, :locked ]

  belongs_to :agent

end
