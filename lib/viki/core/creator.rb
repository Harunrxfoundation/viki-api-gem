module Viki::Core
  class Creator < BaseRequest
    def on_complete(error, body, headers, &block)
      if !error && cachebustable?
        cache_bust(url)
      end
      block.call Viki::Core::Response.new(error, body)
    end

    def request
      @request ||= Typhoeus::Request.new url,
                                         body: body,
                                         headers: default_headers,
                                         method: "post",
                                         # forbid_reuse: true,
                                         timeout: (Viki.timeout_seconds_post)
    end
  end
end
