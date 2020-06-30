require 'khipu-api-client'

Khipu.configure do |c|
  c.secret           = 'abc123'
  c.receiver_id      = 1234
  c.platform         = 'my-ecomerce'  # (optional) please let us know :)
  c.platform_version = '1.0'
end
