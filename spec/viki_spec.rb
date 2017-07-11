require 'spec_helper'

describe Viki do
  describe 'configure' do
    describe 'max concurrency' do
      it 'sets max concurrency' do
        Viki.configure do |c|
          c.max_concurrency = 100
        end
        expect(Viki.hydra_options[:max_concurrency]).to eq(100)
      end

      it 'sets to 200 if max_concurrency is not specified' do
        Viki.configure do |c|
        end

        expect(Viki.hydra_options[:max_concurrency]).to eq(200)
      end
    end

    describe 'pipelining' do
      it 'enables' do
        Viki.configure do |c|
          c.pipelining = true
        end
        expect(Viki.hydra_options[:pipelining]).to eq(true)
      end

      it 'disable pipelining if it is not specified' do
        Viki.configure do |c|
        end

        expect(Viki.hydra_options[:pipelining]).to eq(false)
      end
    end

    describe 'memoize' do
      it 'sets meomoize to false' do
        Viki.configure do |c|
          c.memoize = false
          c.logger = nil
        end
        expect(Typhoeus::Config.memoize).to eq(false)
      end

      it 'sets meomoize to true if it is not specified' do
        Viki.configure do |c|
        end
        expect(Typhoeus::Config.memoize).to eq(true)
      end
    end
  end

  describe 'run' do
    it 'initializes with hydra_options' do
      Viki.configure do |c|
        c.max_concurrency = 100
        c.pipelining = true
      end
      Viki.run
      expect(Viki.hydra.max_concurrency).to be(100)
    end
  end

  describe 'is_ssl_enabled?' do
    it 'initializes with ssl option' do
      Viki.configure do |c|
        c.ssl = true
      end

      expect(Viki.is_ssl_enabled?).to eq true
    end

    it 'initializes without ssl option' do
      Viki.configure do |c|
        c.ssl = false
      end

      expect(Viki.is_ssl_enabled?).to eq false
    end
  end
end
