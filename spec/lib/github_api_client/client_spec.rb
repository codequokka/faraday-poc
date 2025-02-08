require 'faraday'
require 'faraday/retry'
require 'json'
require 'rspec'
require 'webmock/rspec'
require 'github_api_client/client'

# Your GitHubClient class (provided in the prompt)

RSpec.describe GitHubClient do
  let(:token) { 'your_token' } # Replace with a test token if needed
  let(:client) { described_class.new(token) }
  let(:api_url) { 'https://api.github.com/users/octocat' }

  describe '#get' do
    context 'when connection error occurs and retries successfully' do
      it 'retries and returns the successful response' do
        stub_request(:get, api_url)
          .to_raise(Faraday::ConnectionFailed)
          .then
          .to_return(status: 200, body: '{ "login": "octocat" }', headers: { 'Content-Type' => 'application/json' })

        response = client.get('/users/octocat')
        expect(response['login']).to eq('octocat')
        expect(a_request(:get, 'https://api.github.com/users/octocat')).to have_been_made.times(2)
      end
    end

    context 'when connection error occurs and retries fail' do
      it 'raises Faraday::ConnectionFailed after max retries' do
        stub_request(:get, api_url)
          .to_raise(Faraday::ConnectionFailed)
          .times(3)

        expect { client.get('/users/octocat') }.to raise_error(Faraday::ConnectionFailed)
        expect(a_request(:get, 'https://api.github.com/users/octocat')).to have_been_made.times(3)
      end
    end

    context 'when a non-retriable error occurs (e.g., 404)' do
      it 'does not retry and raises the error immediately' do
        stub_request(:get, api_url)
          .to_return(status: 404, body: '{ "message": "Not Found" }', headers: { 'Content-Type' => 'application/json' })

        expect { client.get('/users/octocat') }.to raise_error("Client Error: 404")
        expect(a_request(:get, 'https://api.github.com/users/octocat')).to have_been_made.once
      end
    end
  end
end
