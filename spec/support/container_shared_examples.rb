shared_examples_for "a container object" do
  it "fetches containers" do
    VCR.use_cassette "#{described_class.name}_container" do
      described_class.fetch do |response|
        containers = response.value
        containers.should be_a_kind_of(Array)
        containers.first.keys.should include('managers')
      end
      Viki.run
    end
  end

  describe ".popular" do
    it "sorts by views_recent" do
      described_class.should_receive(:fetch).with sort: 'views_recent'
      described_class.popular
    end

    it "accepts options" do
      described_class.should_receive(:fetch).with sort: 'views_recent', a: 1
      described_class.popular(a: 1)
    end
  end

  describe ".upcoming" do
    it "shows videos with state 3" do
      described_class.should_receive(:fetch).with state: '3'
      described_class.upcoming
    end

    it "accepts options" do
      described_class.should_receive(:fetch).with state: '3', a: 1
      described_class.upcoming(a: 1)
    end
  end

  describe ".trending" do
    it "sorts by trending" do
      described_class.should_receive(:fetch).with sort: 'trending'
      described_class.trending
    end

    it "accepts options" do
      described_class.should_receive(:fetch).with sort: 'trending', a: 1
      described_class.trending(a: 1)
    end
  end
end
