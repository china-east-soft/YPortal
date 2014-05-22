json.array!(@mboxes) do |mbox|
  json.extract! mbox, :id, :name, :integer, :portal_style_id, :category
  json.url mbox_url(mbox, format: :json)
end
