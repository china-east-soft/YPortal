json.array!(@landings) do |landing|
  json.extract! landing, :id, :start_at, :end_at, :url, :cover
  json.url landing_url(landing, format: :json)
end
