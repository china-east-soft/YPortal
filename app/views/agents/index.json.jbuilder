json.array!(@agents) do |agent|
  json.extract! agent, :id, :email, :category, :name, :industry, :city, :contact, :telephone, :known_from, :remark, :status
  json.url agent_url(agent, format: :json)
end
