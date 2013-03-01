module Viki::Core
  class Destroyer < BaseRequest
    def on_complete(error, body, &block)
      block.call Viki::Core::Response.new(error, body)
    end

    def request
      headers = default_headers.merge({'Content-Type' => "application/json"})
      @request ||= Typhoeus::Request.new url,
                                         body: body,
                                         headers: headers,
                                         method: "delete",
                                         forbid_reuse: true,
                                         timeout: Viki.timeout_seconds
    end
  end
end
