require 'spec_helper'

describe Mumukit::Auth::LoginProvider do
  let(:provider) { Mumukit::Auth.config.login_provider }

  it { expect(provider).to be_a Mumukit::Auth::LoginProvider::Developer }
  it { expect(provider.name).to eq 'developer' }

  describe Mumukit::Auth::LoginProvider::Developer do
    let(:provider) { Mumukit::Auth::LoginProvider::Developer.new }

    it { expect(provider.button_html('login', 'clazz')).to eq '<a class="clazz" href="/auth/developer">login</a>' }

    it { expect(provider.header_html).to be_blank }
    it { expect(provider.footer_html).to be_blank }
  end

  describe Mumukit::Auth::LoginProvider::Auth0 do
    let(:provider) { Mumukit::Auth::LoginProvider::Auth0.new }
    let(:login_settings) { Mumukit::Auth::LoginSettings.new }

    it { expect(provider.button_html('login', 'clazz')).to eq '<a class="clazz" href="#" onclick="window.signin();">login</a>' }
    it { expect(provider.header_html(login_settings)).to be_present }
    it { expect(provider.footer_html).to be_present }
  end

  describe Mumukit::Auth::LoginProvider::Saml do
    let(:provider) { Mumukit::Auth::LoginProvider::Saml.new }

    it { expect(provider.button_html('login', 'clazz')).to eq '<a class="clazz" href="/auth/saml">login</a>' }
    it { expect(provider.header_html).to be_blank }
    it { expect(provider.footer_html).to be_blank }
  end
end
