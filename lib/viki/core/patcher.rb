module Viki::Core
  class Patcher < BaseRequest
    def on_complete(error, body, headers, &block)
      block.call Viki::Core::Response.new(error, body)
    end

    def request
      @request ||= Typhoeus::Request.new url,
                                         body: body,
                                         headers: default_headers,
                                         method: "patch",
                                         # forbid_reuse: true,
                                         timeout: (Viki.timeout_seconds_post)
    end
  end
end
