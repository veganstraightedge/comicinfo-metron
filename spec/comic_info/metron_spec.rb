RSpec.describe ComicInfo::Metron do
  subject(:metron) do
    described_class.new base_url:   RSpec.configuration.metron_server.base_url,
                        token:      MetronServer::TOKEN,
                        user_agent: MetronServer::USER_AGENT
  end

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

  describe '#matches' do
    it 'is the numbered issue in every series named like the issue’s' do
      matches = metron.matches issue

      expect(matches.map(&:id)).to eq %w[31660 99901]
      match = matches.first
      expect(match).to be_a ComicInfo::Match
      expect(match.heading).to eq 'Saga (2012) #1'
      expect(match.series).to eq 'Saga'
      expect(match.number).to eq '1'
      expect(match.title).to be_nil
      expect(match.cover_date).to eq '2012-03-01'
      expect(match.details).to eq 'Cover date 2012-03-01'
      expect(match.site_url).to be_nil
    end

    it 'is narrowed to issues covered in the issue’s year, when it has one' do
      with_year = ComicInfo.load fixture_path('saga_1_2012.xml')

      expect(metron.matches(with_year).map(&:heading)).to eq ['Saga (2012) #1']
    end

    it 'raises an HTTP error when Metron refuses a wrong token' do
      wrong_token = described_class.new base_url:   RSpec.configuration.metron_server.base_url,
                                        token:      'wrong',
                                        user_agent: MetronServer::USER_AGENT

      message = 'Metron answered with HTTP status 401.'

      expect { wrong_token.matches issue }.to raise_error(ComicInfo::Metron::HTTPError, message) { expect(it.status).to eq 401 }
    end

    it 'raises an HTTP error when Metron refuses an unnamed app' do
      unnamed = described_class.new base_url:   RSpec.configuration.metron_server.base_url,
                                    token:      MetronServer::TOKEN,
                                    user_agent: ''

      message = 'Metron answered with HTTP status 403.'

      expect { unnamed.matches issue }.to raise_error(ComicInfo::Metron::HTTPError, message) { expect(it.status).to eq 403 }
    end
  end
end
