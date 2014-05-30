json.array!(@activities) do |activity|
  json.extract! activity, :id, :title, :started_at, :end_at, :description, :hot
  json.url activity_url(activity, format: :json)
end
