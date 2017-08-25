module Viki::Core
  class Updater < BaseRequest
    def on_complete(error, body, headers, &block)
      if !error && cachebustable?
        cache_bust
      end
      block.call Viki::Core::Response.new(error, body)
    end

    def request
      @request ||= Typhoeus::Request.new url,
                                         body: body,
                                         headers: default_headers,
                                         method: "put",
                                         # forbid_reuse: true,
                                         timeout: (Viki.timeout_seconds_post)
    end
  end
end
