require 'spec_helper'
require 'timecop'
require 'sinatra'

describe 'Rack request logger with Sinatra', timecop: true do
  include_context 'loga initialize'

  let(:app) do
    Class.new(Sinatra::Base) do
      set :environment, :production
      use Loga::Rack::RequestId
      use Loga::Rack::Logger

      error StandardError do
        status 500
        body 'Ooops'
      end

      get '/ok' do
        'Hello Sinatra'
      end

      get '/error' do
        fail StandardError, 'Hello Sinatra Error'
      end
    end
  end

  context 'when environment is production' do
    context 'when the request is successful' do
      it 'logs the request' do
        get '/ok',
            { username: 'yoshi' },
            'HTTP_USER_AGENT' => 'Chrome', 'HTTP_X_REQUEST_ID' => '471a34dc'

        expect(json).to match(
          'version'             => '1.1',
          'host'                => 'bird.example.com',
          'short_message'       => 'GET /ok?username=yoshi',
          'timestamp'           => 1_450_150_205.123,
          'level'               => 6,
          '_type'               => 'request',
          '_service.name'       => 'hello_world_app',
          '_service.version'    => '1.0',
          '_request.method'     => 'GET',
          '_request.path'       => '/ok',
          '_request.params'     => { 'username' => 'yoshi' },
          '_request.request_ip' => '127.0.0.1',
          '_request.user_agent' => 'Chrome',
          '_request.status'     => 200,
          '_request.request_id' => '471a34dc',
          '_request.duration'   => 0,
          '_tags'               => [],
        )
      end
    end

    context 'when the request raises an exception' do
      it 'logs the request with the exception' do
        get '/error',
            { username: 'yoshi' },
            'HTTP_USER_AGENT' => 'Chrome', 'HTTP_X_REQUEST_ID' => '471a34dc'

        expect(json).to match(
          'version'              => '1.1',
          'host'                 => 'bird.example.com',
          'short_message'        => 'GET /error?username=yoshi',
          'timestamp'            => 1_450_150_205.123,
          'level'                => 3,
          '_type'                => 'request',
          '_service.name'        => 'hello_world_app',
          '_service.version'     => '1.0',
          '_request.method'      => 'GET',
          '_request.path'        => '/error',
          '_request.params'      => { 'username' => 'yoshi' },
          '_request.request_ip'  => '127.0.0.1',
          '_request.user_agent'  => 'Chrome',
          '_request.status'      => 500,
          '_request.request_id'  => '471a34dc',
          '_request.duration'    => 0,
          '_exception.klass'     => 'StandardError',
          '_exception.message'   => 'Hello Sinatra Error',
          '_exception.backtrace' => be_a(String),
          '_tags'               => [],
        )
      end
    end
  end

  pending 'when environment is development'
end
