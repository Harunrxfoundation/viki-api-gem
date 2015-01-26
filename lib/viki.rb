require 'viki/logger'
require 'oj'
require 'typhoeus'
require 'ostruct'
require 'openssl'
require 'addressable/uri'
require 'viki_utils'
require 'base64'

module Viki
  class << self
    attr_accessor :salt, :app_id, :domain, :manage, :logger, :user_ip, :user_token, :signer, :hydra,
                  :timeout_seconds, :timeout_seconds_post, :cache, :cache_ns, :cache_seconds, :hydra_options
  end

  def self.run
    if defined?(::ActiveSupport::Notifications)
      ActiveSupport::Notifications.instrument("viki-api.fetch") do
        @hydra.run
      end
    else
      @hydra.run
    end
  ensure
    @hydra = Typhoeus::Hydra.new(@hydra_options)
  end

  def self.configure(&block)
    configurator = Configurator.new
    block.call configurator

    @signer = Viki::UriSigner.new(configurator.salt)
    @salt = configurator.salt
    @app_id = configurator.app_id
    @domain = configurator.domain
    @manage = configurator.manage
    @timeout_seconds = configurator.timeout_seconds
    @timeout_seconds_post = configurator.timeout_seconds_post
    @logger = configurator.logger
    @user_ip = configurator.user_ip
    @user_token = configurator.user_token
    @cache = configurator.cache
    @cache_ns = configurator.cache_ns
    @cache_seconds = configurator.cache_seconds
    @hydra_options = {max_concurrency: configurator.max_concurrency}
    @hydra = Typhoeus::Hydra.new(@hydra_options)
    nil
  end

  class Configurator
    attr_reader :logger
    attr_accessor :salt, :app_id, :domain, :manage, :user_ip, :user_token, :timeout_seconds, :timeout_seconds_post, :cache, :cache_ns, :cache_seconds, :max_concurrency

    def logger=(v)
      @logger.level = Viki::Logger::FATAL if v.nil?
    end

    def initialize
      @salt = ENV["VIKI_API_SALT"]
      @app_id = ENV["VIKI_API_APP_ID"]
      @domain = ENV["VIKI_API_DOMAIN"]
      @manage = ENV["VIKI_MANAGE_DOMAIN"]
      @logger = Viki::Logger.new(STDOUT)
      @logger.level = (ENV["VIKI_API_LOG_LEVEL"] || Viki::Logger::INFO).to_i
      @user_ip = lambda { }
      @user_token = lambda { }
      @timeout_seconds = 5
      @timeout_seconds_post = 10
      @cache = nil
      @cache_ns = "viki-api-gem"
      @cache_seconds = 5
      @max_concurrency = 200
    end
  end
end

Typhoeus.configure do |config|
  config.memoize = true
end

Viki::configure{}

require 'viki/core/base_request'
require 'viki/core/fetcher'
require 'viki/core/creator'
require 'viki/core/updater'
require 'viki/core/destroyer'
require 'viki/core/base'
require 'viki/core/response'
require 'viki/core/error_response'
require 'viki/core/timeout_error_response'

['', 'container', 'video'].each do |dir|
  Dir[File.join(File.dirname(__FILE__), "viki/#{dir}", '*.rb')].each { |f| require f }
end
