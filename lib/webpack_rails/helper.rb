# view helper to resolve bundle asset file url (falling back to sprockets)

module WebpackRails::Helper
  def webpack_bundle_asset(bundle_filename)
    webpack_config = Rails.application.config.webpack_rails
    if webpack_config.dev_server
      "#{webpack_config[:protocol]}://#{webpack_config[:host]}:#{webpack_config[:port]}/#{bundle_filename}"
    else
      asset_path bundle_filename
    end
  end
end
