require_relative "lib/github_api_client/client"

client = GitHubClient.new()

begin
  user = client.get('/users/octocat')
  puts user['login']
rescue => e
  puts "Error: #{e.message}"
end

begin
  repo = client.get('/repos/octocat/Spoon-Knife')
  puts repo['name']
rescue => e
  puts "Error: #{e.message}"
end
