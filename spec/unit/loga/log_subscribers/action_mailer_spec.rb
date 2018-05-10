require 'spec_helper'
require 'active_support'
require 'loga/log_subscribers/action_mailer'

RSpec.describe Loga::LogSubscribers::ActionMailer do
  subject(:mailer) { described_class.new }

  let(:event) do
    double('event', payload: payload, duration: 0.0001, time: Time.now)
  end

  before do
    Loga.reset

    Loga.configure(service_name: 'hello_world_app')
  end

  describe '#deliver' do
    context 'when an email is sent' do
      let(:payload) do
        {
          mailer: 'FakeMailer',
          to:     ['user@example.com'],
        }
      end

      it 'logs an info message' do
        expect(Loga.logger).to receive(:info).with(kind_of(Loga::Event))

        mailer.deliver(event)
      end
    end
  end

  describe '#process' do
    context 'when an email is sent' do
      let(:payload) do
        {
          mailer: 'FakeMailer',
          action: 'hello_world',
        }
      end

      it 'logs an info message' do
        expect(Loga.logger).to receive(:debug).with(kind_of(Loga::Event))

        mailer.process(event)
      end
    end
  end

  describe '#receive' do
    context 'when an email is sent' do
      let(:payload) do
        {
          mailer:  'FakeMailer',
          from:    'loremipsum@example.com',
          subject: 'Lorem ipsum',
        }
      end

      it 'logs an info message' do
        expect(Loga.logger).to receive(:info).with(kind_of(Loga::Event))

        mailer.receive(event)
      end
    end
  end
end
