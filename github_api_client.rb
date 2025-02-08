require 'faraday'
require 'json'

class GitHubClient
  API_ENDPOINT = 'https://api.github.com'

  def initialize(token = nil)
    @token = token
    @connection = Faraday.new(url: API_ENDPOINT) do |faraday|
      faraday.request :json # リクエストをJSON形式に設定
      faraday.response :json # レスポンスをJSON形式でパース
      faraday.adapter Faraday.default_adapter
      # 必要であればOAuthなどのミドルウェアを追加
      # faraday.use Faraday::OAuth2::Client, token: @token if @token
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

  # 他のHTTPメソッド (put, deleteなど) も同様に定義可能

  private

  def handle_response(response)
    case response.status
    when 200..299
      response.body # JSONとしてパースされたレスポンスボディを返す
    when 400..499
      raise "Client Error: #{response.status}"
    when 500..599
      raise "Server Error: #{response.status}"
    else
      raise "Unexpected Error: #{response.status}"
    end
  end
end

# クライアントの利用例
client = GitHubClient.new('your_github_token') # GitHubトークンを設定 (省略可能)

# ユーザー情報を取得
begin
  user = client.get('/users/octocat')
  puts user['login']
rescue => e
  puts "Error: #{e.message}"
end

# リポジトリの情報を取得
begin
  repo = client.get('/repos/octocat/Spoon-Knife')
  puts repo['name']
rescue => e
  puts "Error: #{e.message}"
end
