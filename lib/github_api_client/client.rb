require 'faraday'
require 'faraday/retry'
require 'json'

class GitHubClient
  API_ENDPOINT = 'https://api.github.com'
  # API_ENDPOINT = 'https://192.168.0.1'

  def initialize(token = nil)
    retry_options = {
      max: 2,
      interval: 1,
      interval_randomness: 0.5,
      backoff_factor: 2,
      retry_statuses: [404]
    }

    @token = token
    @connection = Faraday.new(url: API_ENDPOINT) do |faraday|
      faraday.request :json
      faraday.request :retry, retry_options
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def get(path, params = {})
    response = @connection.get(path, params)
    handle_response(response)
  end

  def post(path, body = {})
    response = @connection.post(path, body.to_json)
    handle_response(response)
  end

  private

  def handle_response(response)
    case response.status
    when 200..299
      response.body
    when 400..499
      raise "Client Error: #{response.status}"
    when 500..599
      raise "Server Error: #{response.status}"
    else
      raise "Unexpected Error: #{response.status}"
    end
  end
end
