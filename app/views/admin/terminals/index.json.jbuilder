json.array!(@terminals) do |terminal|
  json.extract! terminal, :id, :admin, :mac, :imei, :sim_iccid, :status
  json.url terminal_url(terminal, format: :json)
end
