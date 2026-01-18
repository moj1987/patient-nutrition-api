require 'rails_helper'

RSpec.describe EmailWhitelistService do
  describe '.allowed?' do
    context 'when ALLOWED_EMAILS is configured' do
      before do
        allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('admin@example.com,user@example.com')
        described_class.reset_cache!
      end

      it 'returns true for whitelisted email' do
        expect(described_class.allowed?('admin@example.com')).to be true
        expect(described_class.allowed?('user@example.com')).to be true
      end

      it 'returns true for whitelisted email with different case' do
        expect(described_class.allowed?('ADMIN@EXAMPLE.COM')).to be true
        expect(described_class.allowed?('User@Example.Com')).to be true
      end

      it 'returns true for whitelisted email with whitespace' do
        expect(described_class.allowed?(' admin@example.com ')).to be true
        expect(described_class.allowed?('user@example.com ')).to be true
      end

      it 'returns false for non-whitelisted email' do
        expect(described_class.allowed?('hacker@example.com')).to be false
        expect(described_class.allowed?('test@other.com')).to be false
      end
    end

    context 'when ALLOWED_EMAILS is not configured' do
      before do
        allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return(nil)
        described_class.reset_cache!
      end

      it 'raises ConfigurationError' do
        expect {
          described_class.allowed?('test@example.com')
        }.to raise_error(EmailWhitelistService::ConfigurationError, 'ALLOWED_EMAILS environment variable is not configured')
      end
    end

    context 'when ALLOWED_EMAILS is empty' do
      before do
        allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('')
        described_class.reset_cache!
      end

      it 'raises ConfigurationError' do
        expect {
          described_class.allowed?('test@example.com')
        }.to raise_error(EmailWhitelistService::ConfigurationError, 'ALLOWED_EMAILS environment variable is not configured')
      end
    end

    context 'when ALLOWED_EMAILS has malformed entries' do
      before do
        allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('admin@example.com,, ,user@example.com')
        described_class.reset_cache!
      end

      it 'ignores empty entries and validates properly' do
        expect(described_class.allowed?('admin@example.com')).to be true
        expect(described_class.allowed?('user@example.com')).to be true
        expect(described_class.allowed?('test@example.com')).to be false
      end
    end
  end

  describe '.whitelisted_emails' do
    it 'returns normalized email list' do
      allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('ADMIN@Example.com, User@Test.Com')
      described_class.reset_cache!

      expect(described_class.whitelisted_emails).to eq([ 'admin@example.com', 'user@test.com' ])
    end

    it 'caches the result' do
      allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('test@example.com')

      # First call should query ENV
      expect(ENV).to receive(:[]).with('ALLOWED_EMAILS').once.and_return('test@example.com')
      described_class.reset_cache!

      # Call multiple times
      described_class.whitelisted_emails
      described_class.whitelisted_emails
    end
  end

  describe '.reset_cache!' do
    it 'clears the cached emails' do
      allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('test@example.com')

      # Populate cache
      described_class.whitelisted_emails

      # Reset and change ENV
      described_class.reset_cache!
      allow(ENV).to receive(:[]).with('ALLOWED_EMAILS').and_return('new@example.com')

      # Should pick up new value
      expect(described_class.whitelisted_emails).to eq([ 'new@example.com' ])
    end
  end
end
