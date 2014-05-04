json.array!(@merchants) do |merchant|
  json.extract! merchant, :id, :name, :industry, :province, :city, :area, :circle, :address, :contact, :mobile, :secondary
  json.url merchant_url(merchant, format: :json)
end
