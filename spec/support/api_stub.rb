module ApiStub
  def stub_api(path, body, options = {})
    params = (options[:params] || {}).merge(app: Viki.app_id)
    req_method = (options[:method] || 'get').to_s
    response_code = options[:response_code] || 200
    domain = options[:manage] ? Viki.manage : Viki.domain
    api_version = options[:api_version] || 'v4'
    if options.has_key?(:https)
      protocol = (options[:https] == true) ? "https" : "http"
    else
      protocol = Viki.is_ssl_enabled? ? "https" : "http"
    end
    stub_request(req_method, "#{protocol}://#{domain}/#{api_version}/#{path}").
      with(query: hash_including(:sig, :t, params),
           headers: {'Content-Type'=>'application/json', 'User-Agent'=>'viki'},
           body: anything).
      to_return(body: body, status: response_code)
  end
end
