require 'spec_helper'

describe ServiceLogger::GELFFormatter do
  let(:service_name)    { 'demo_service' }
  let(:service_version) { '725e032a' }
  let(:host)            { 'www.example.com' }
  let(:options) do
    {
      service_name:    service_name,
      service_version: service_version,
      host:            host,
    }
  end

  subject { described_class.new(options) }

  describe '#call(severity, time, _progname, message)' do
    let(:time) { Time.new(2015, 12, 15, 9, 0, 5.123) }
    let(:message) do
      {
        short_message: 'Hello World',
        event_type:    'http_request',
        data:          {},
      }
    end

    subject { JSON.parse(super().call('INFO', time, nil, message)) }

    specify do
      expect(subject).to include('version'       => '1.1',
                                 'host'          => host,
                                 'short_message' => 'Hello World',
                                 'full_message'  => '',
                                )
    end

    it 'formats the severity as standard syslog level' do
      expect(subject).to include('level' => 6)
    end

    it 'formats the time as unix timestamp with milliseconds' do
      expect(subject).to include('timestamp' => "#{time.to_i}.123")
    end

    context 'when the message does provide a short_message' do
      let(:message) { {} }
      it 'raises a KeyError' do
        expect { subject }.to raise_error(KeyError)
      end
    end
    context 'when the message provides data' do
      let(:message) do
        super().merge(
          data: {
            '_user_uuid' => 'abcd',
          },
        )
      end
      it 'merges the data key values with the message' do
        expect(subject).to include('_user_uuid' => 'abcd',
                                   'short_message' => 'Hello World',
                                  )
      end
    end
  end

  describe '#unix_timestamp_with_milliseconds(time)' do
    let(:time) { Time.new(2015, 12, 15, 9, 0, 5.123) }

    subject { super().unix_timestamp_with_milliseconds(time) }

    it 'formats Time in seconds since unix epoch with decimal places for milliseconds' do
      expect(subject).to eq("#{time.to_i}.123")
    end
  end

  describe '#severity_to_syslog_level(severity)' do
    let(:severity) { 'INFO' }

    subject { super().severity_to_syslog_level(severity) }

    specify { expect(subject).to eq(6) }
    pending 'test all other mappings'
  end
end
