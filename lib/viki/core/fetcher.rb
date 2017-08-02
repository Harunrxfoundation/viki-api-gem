require 'set'

module Viki::Core
  class Fetcher < BaseRequest
    attr_accessor :count, :more, :details

    PAGE_REGEX = /page=(\d+)/
    TOKEN_FIELD = "token"
    IGNORED_PARAMS = ['t', 'sig', TOKEN_FIELD]

    def queue(&block)

      log @url

      super && return if @url.include?("nocache=true")
      super && return unless Viki.cache && !cacheable.empty?

      public_cache_key = cache_key(url, true)
      private_cache_key = cache_key(url, false)
      cached = if Viki.cache.exists(private_cache_key)
              then Viki.cache.get(private_cache_key)
              else Viki.cache.get(public_cache_key)
              end
      if cached
        begin
          parsed_body = Oj.load(cached, mode: :compat, symbol_keys: false)
        rescue
          Viki.logger.info "Couldn't parse json. Body: #{@body.to_s}. Object: #{self}"
          log_json(Oj.dump({level: 'error', error: "Could not parse json with body #{@body.to_s}"}, mode: :compat))
        end
        if parsed_body
          block.call Viki::Core::Response.new(nil, get_content(parsed_body), self)
        else
          error = Viki::Core::ErrorResponse.new(body, 0, url)
          Viki.logger.error(error.to_s)
          log_json(error.to_json)
          block.call Viki::Core::Response.new(error, nil, self)
        end
      else
        super
      end
    end

    def on_complete(error, body, headers, &block)
      if error
        block.call Viki::Core::Response.new(error, nil, self)
      else
        if body
          if Viki.cache && !cacheable.empty?
            cacheSeconds = cacheable[:cache_seconds]
            public_cache = false
            # Respect timing set in Cache-Control header for stuff that's public
            if headers.respond_to?(:has_key?) && headers.has_key?("Cache-Control")
              cacheHeaderParts = headers["Cache-Control"].split(",").map { |s| s.strip }
              if cacheHeaderParts.include?("public")
                public_cache = true
                maxAgeRegex = %r{^max-age=\d+$}
                maxAgeList = cacheHeaderParts.drop_while { |x| x !~ maxAgeRegex }
                if maxAgeList.length > 0
                  cacheSeconds = %r{^max-age=(\d+)$}.match(maxAgeList[0])[1].to_i
                end
              end
            end
            Viki.cache.setex(cache_key(url, public_cache), cacheSeconds, Oj.dump(body, mode: :compat))
          end
          block.call Viki::Core::Response.new(nil, get_content(body), self)
        else
          error = Viki::Core::ErrorResponse.new(body, 0, url)
          Viki.logger.error(error.to_s)
          log_json(error.to_json)
          block.call Viki::Core::Response.new(error, nil, self)
        end
      end
    end

    def request
      Typhoeus::Request.new url,
                            headers: default_headers,
                            method: "get",
                            # forbid_reuse: true,
                            timeout: (Viki.timeout_seconds)
    end

    private
    def get_content(json)
      if is_list?(json)
        @count = json["count"]
        @more = json["more"] if json.has_key?('more')
        @more = !!json["pagination"]["next"] if json.has_key?('pagination')
        @details = json["details"]
        json["response"]
      else
        json
      end
    end

    def is_list?(value)
      return false unless value.is_a?(Hash)
      value.has_key?("response")
    end

    def cache_key(url, public_cache = false)
      parsed_url = Addressable::URI.parse(url)
      cache_key = parsed_url.path

      if parsed_url.query_values
        # Only include user role if caching for private
        unless public_cache
          token = parsed_url.query_values[TOKEN_FIELD]
          user_role = 0
          if token
            rindex_token = token.rindex("_")
            token_role = rindex_token.nil? ? 0 : token[rindex_token + 1, token.length]
            user_role = token_role
          end
          cache_key += "-@role=#{user_role}"
        end

        parsed_url.query_values.
          reject { |k, _| IGNORED_PARAMS.include?(k) }.
          to_a.
          sort_by { |(k, _)| k }.
          each do |k, v|
          cache_key += "-#{k}=#{v}"
        end
      end
      "#{Viki.cache_ns}.#{cache_key}"
    end
  end
end
