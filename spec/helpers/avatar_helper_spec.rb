require 'spec_helper'

describe AvatarHelper, organization_workspace: :test do
  helper AvatarHelper

  let(:user) { create(:user, avatar: kids_avatars.last) }

  let(:kids_avatars) { create_list(:avatar, 4, target_audience: :primary) }
  let!(:grown_ups_avatars) { create_list(:avatar, 3, target_audience: :grown_ups) }

  let!(:kids_organization) { create(:organization, target_audience: :primary) }
  let!(:grown_ups_organization) { create(:organization, target_audience: :grown_ups, name: 'for_grown_ups') }

  describe 'avatars_for' do
    context 'with avatar in same target audience as organization' do
      before { kids_organization.switch! }
      it { expect(avatars_for(user)).to eq kids_avatars }
    end

    context 'with avatar in different target audience as organization' do
      before { grown_ups_organization.switch! }
      it { expect(avatars_for(user)).to eq grown_ups_avatars + [user.avatar] }
    end

  end
end
