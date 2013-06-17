module ApiStub
  def stub_api(path, body, options = {})
    params = (options[:params] || {}).merge(app: Viki.app_id)
    req_method = (options[:method] || 'get').to_s
    response_code = options[:response_code] || 200
    domain = options[:manage] ? Viki.manage : Viki.domain

    stub_request(req_method, "http://#{domain}/v4/#{path}").
      with(query: hash_including(:sig, :t, params),
           headers: {'Content-Type'=>'application/json', 'User-Agent'=>'viki'},
           body: anything).
      to_return(body: body, status: response_code)
  end
end