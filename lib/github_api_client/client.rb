require 'faraday'
require 'json'

class GitHubClient
  API_ENDPOINT = 'https://api.github.com'

  def initialize(token = nil)
    @token = token
    @connection = Faraday.new(url: API_ENDPOINT) do |faraday|
      faraday.request :json
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
