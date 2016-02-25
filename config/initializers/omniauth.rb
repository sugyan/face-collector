OmniAuth.config.full_host = lambda do |env|
  format('%s://%s', env['rack.url_scheme'], env['HTTP_X_FORWARDED_HOST'] || env['HTTP_HOST'])
end
