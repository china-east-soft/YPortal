module PrivateKey

  # generate private key
  def private_key
    key_file = Rails.root.join('.private_key')
    if File.exist?(key_file)
      # Use the existing token.
      File.read(key_file).chomp
    else
      # Generate a new token and store it in key_file.
      token = SecureRandom.hex(64)
      File.write(key_file, token)
      token
    end
  end

end