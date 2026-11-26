RSpec.describe ComicInfo::Metron do
  subject(:metron) { described_class.new token: 'test-token', user_agent: 'ComicInfoMetronSpecs/1.0' }

  let(:issue) { ComicInfo.load fixture_path('saga_1.xml') }

  it 'has a version number' do
    expect(ComicInfo::Metron::VERSION).not_to be_nil
  end

  it 'is credited as Metron' do
    expect(metron.name).to eq 'Metron'
    expect(metron.home_url).to eq 'https://metron.cloud/'
  end

  describe '#missing_details' do
    it 'is nothing when the issue has a series and a number' do
      with_year = ComicInfo.load fixture_path('saga_1_2012.xml')

      expect(metron.missing_details(issue)).to be_nil
      expect(metron.missing_details(with_year)).to be_nil
    end

    it 'asks for a series and a number when either is blank' do
      no_series = ComicInfo.load fixture_path('number_only.xml')
      no_number = ComicInfo.load fixture_path('series_only.xml')
      blank     = ComicInfo.load fixture_path('blank_number.xml')

      expect(metron.missing_details(no_series)).to eq 'Metron needs a Series and a Number to search for.'
      expect(metron.missing_details(no_number)).to eq 'Metron needs a Series and a Number to search for.'
      expect(metron.missing_details(blank)).to eq 'Metron needs a Series and a Number to search for.'
    end
  end
end
