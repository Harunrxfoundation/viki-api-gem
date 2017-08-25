module Viki::Core
  class Patcher < BaseRequest
    def on_complete(error, body, headers, &block)
      if !error && Viki.cache && cachebustable?
        cache_bust(url)
      end
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

    private
    def cache_bust(url)
      cache_path_prefix = cache_path_components(url)[0]
      bustable_keys = Viki.cache.keys("#{cache_path_prefix}*")
      Viki.cache.del(*bustable_keys) unless bustable_keys.empty?
    end
  end
end
