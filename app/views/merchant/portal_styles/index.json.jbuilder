json.array!(@portal_styles) do |portal_style|
  json.extract! portal_style, :id, :name, :btn_style
  json.url portal_style_url(portal_style, format: :json)
end
