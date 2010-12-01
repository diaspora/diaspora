$options = (ENV['MOCHA_OPTIONS'] || '').split(',').inject({}) { |hash, key| hash[key] = true; hash }
