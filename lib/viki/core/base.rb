module Viki::Core
  class Base
    class InvalidOption < RuntimeError
      def initialize(field, value)
        super("Invalid value for '#{field}' field: #{value}")
      end
    end
    class InsufficientOptions < RuntimeError
    end

    PATH_TOKENS_REGEX = /:(\w+)/
    END_OF_PATH_REGEX = /(\/\w+)(\.\w+)?$/
    DEFAULT_NAME = "NONAME"
    JSON_FORMAT = "json"
    DEFAULT_PARAMS = {format: JSON_FORMAT}
    DEFAULT_API_VERSION = "v4"

    class << self
      attr_accessor :_paths, :_ssl, :_manage, :_cacheable

      def cacheable(opts = {})
        cache_seconds = opts.delete(:cache_seconds) || Viki.cache_seconds
        @_cacheable = {cache_seconds: cache_seconds}
      end

      def use_ssl
        @_ssl = true
      end

      def path(path, options = {})
        api_version = options.fetch(:api_version, DEFAULT_API_VERSION)
        path = api_version + path
        name = options.fetch(:name, DEFAULT_NAME)
        @_paths ||= {}
        @_paths[name] ||= []
        @_paths[name].push path

        manage = options.fetch(:manage, false)
        @_manage ||= []
        @_manage << path if manage
      end

      def default(default_values)
        @_defaults ||= DEFAULT_PARAMS.dup
        @_defaults.merge!(default_values)
      end

      def uri(params = {})
        params = build_params(params)
        path, params = build_path(params)
        path = "/#{path}.#{params.delete(:format)}"
        domain = "https://#{params.delete(:manage) == true ? Viki.manage : Viki.domain}"
        uri = Addressable::URI.join(domain, path)

        query_values = {}
        query_values.merge! uri.query_values if uri.query_values
        query_values.merge! params
        query_values[:app] = params[:app] || Viki.app_id

        token = Viki.user_token && Viki.user_token.call
        query_values[:token] = token if token && !token.empty?

        uri.query_values = query_values
        uri
      end

      def signed_uri(params = {}, body = nil)
        signer = params[:secret] ? Viki::UriSigner.new(params.delete(:secret)) : Viki.signer
        signer.sign_request(uri(params).to_s, body)
      end

      def fetch(url_options = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup)
        Viki.logger.debug "#{self.name} fetching from the API: #{uri}"

        if @_cacheable
          fetcher = Viki::Core::Fetcher.new(uri, nil, format, @_cacheable)
        else
          fetcher = Viki::Core::Fetcher.new(uri, nil, format)
        end

        fetcher.queue &block
        fetcher
      end

      def fetch_sync(url_options = {})
        response = nil
        fetch(url_options) { |r| response = r }
        Viki.run
        response
      end

      def create(url_options = {}, body = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup, body)
        Viki.logger.debug "#{self.name} creating to the API: #{uri}"
        creator = Viki::Core::Creator.new(uri, body, format)
        creator.queue &block
        creator
      end

      def create_sync(url_options = {}, body = {})
        response = nil
        create(url_options, body) { |r| response = r }
        Viki.run
        response
      end

      def update(url_options = {}, body = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup, body)
        Viki.logger.debug "#{self.name} updating to the API: #{uri}"
        creator = Viki::Core::Updater.new(uri, body, format)
        creator.queue &block
        creator
      end

      def update_sync(url_options = {}, body = {})
        response = nil
        update(url_options, body) { |r| response = r }
        Viki.run
        response
      end

      def destroy(url_options = {}, body = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup, body)
        Viki.logger.debug "#{self.name} destroying to the API: #{uri}"
        destroyer = Viki::Core::Destroyer.new(uri, body, format)
        destroyer.queue &block
        destroyer
      end

      def destroy_sync(url_options = {}, body = {})
        response = nil
        destroy(url_options, body) { |r| response = r }
        Viki.run
        response
      end

      def patch(url_options = {}, body = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup, body)
        Viki.logger.debug "#{self.name} patching to the API: #{uri}"
        creator = Viki::Core::Patcher.new(uri, body, format)
        creator.queue &block
        creator
      end

      def patch_sync(url_options = {}, body = {})
        response = nil
        patch(url_options, body) { |r| response = r }
        Viki.run
        response
      end

      def put(url_options = {}, body = {}, &block)
        format = get_format(url_options)
        uri = signed_uri(url_options.dup, body)
        Viki.logger.debug "#{self.name} putting to the API: #{uri}"
        creator = Viki::Core::Putter.new(uri, body, format)
        creator.queue &block
        creator
      end

      def put_sync(url_options = {}, body = {})
        response = nil
        put(url_options, body) { |r| response = r }
        Viki.run
        response
      end

      private

      def get_format(params)
        params[:format] || DEFAULT_PARAMS[:format] || JSON_FORMAT
      end

      def build_params(params)
        @_defaults ||= DEFAULT_PARAMS
        @_defaults.merge(params)
      end

      def build_path(params)
        name = params.delete(:named_path) || DEFAULT_NAME
        paths = @_paths[name].dup
        paths.reject! {|p| @_manage.include?(p) && !params.has_key?(:manage)}

        #It calculates how many symbols from the URL are provided by the params
        #and returns the path that has all the required symbols and the maximum
        #number of them.
        final_path = nil
        final_length = 0
        final_params = []
        paths.each do |path|
          url_params = path.scan(PATH_TOKENS_REGEX).flatten.map(&:to_sym)
          total_params = url_params.length
          valid_params = url_params.map {|a| params.has_key?(a) ? 1 : 0}.reduce(&:+).to_i
          next unless total_params - valid_params == 0
          if total_params >= final_length
            final_path = path.dup
            final_params = url_params
            final_length = total_params
          end
        end

        raise Viki::Core::Base::InsufficientOptions if final_path.nil?
        final_params.each {|p| final_path.gsub!(":#{p}", params.delete(p))}

        resource_id = params.delete(:id)
        final_path.gsub!(END_OF_PATH_REGEX, "\\1/#{resource_id}\\2") unless resource_id.nil?

        [final_path, params]
      end
    end
  end
end
