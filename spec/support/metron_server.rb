require 'webrick'

# Answers Metron API requests with the responses in spec/fixtures, as Metron would.
#
# A request without the test token is refused as unauthorized, and one without the test
# User-Agent as forbidden, so a passing spec shows both are sent.
#
# The fixtures follow Mokkari's schemas (Metron's own Python client); they were not recorded
# from the live API.
class MetronServer
  TOKEN      = 'test-token'.freeze
  USER_AGENT = 'ComicInfoMetronSpecs/1.0'.freeze

  # The fixture file each API path and query is answered with
  FIXTURES = {
    '/api/issue/31660/'                                     => 'issue_31660.json',
    '/api/issue/?cover_year=2012&number=1&series_name=Saga' => 'issues_saga_1_2012.json',
    '/api/issue/?number=1&series_name=Saga'                 => 'issues_saga_1.json'
  }.freeze

  def initialize fixtures_directory:
    @fixtures_directory = fixtures_directory
    @server = WEBrick::HTTPServer.new AccessLog:   [],
                                      BindAddress: '127.0.0.1',
                                      Logger:      WEBrick::Log.new(File::NULL),
                                      Port:        0
    @server.mount_proc('/') { |request, response| answer request, response }
  end

  def base_url = "http://127.0.0.1:#{port}/api/"

  def start
    @thread = Thread.new { @server.start }
  end

  def stop
    @server.shutdown
    @thread.join
  end

  private

  def port = @server.listeners.first.addr[1]

  def answer request, response
    return refuse response, status: 401 unless request['Authorization'] == "Bearer #{TOKEN}"
    return refuse response, status: 403 unless request['User-Agent'] == USER_AGENT

    query   = request.query_string ? "?#{request.query_string}" : ''
    fixture = FIXTURES[request.path + query]
    return refuse response, status: 404 unless fixture

    respond response, fixture:
  end

  def refuse response, status:
    response.status = status
  end

  def respond response, fixture:
    path = File.join @fixtures_directory, fixture

    response.status          = 200
    response['Content-Type'] = 'application/json'
    response.body            = File.read path
  end
end
