json.array!(@banners) do |banner|
  json.extract! banner, :id, :cover
  json.url banner_url(banner, format: :json)
end
