require 'spec_helper'

feature 'Choose organization Flow' do

  let(:user) { create(:user, permissions: {student: ''}) }
  let(:user2) { create(:user, permissions: {student: 'pdep/*'}) }
  let(:user3) { create(:user, permissions: {student: 'pdep/*:foo/*'}) }
  let(:user4) { create(:user, permissions: {student: 'immersive-orga/*'}) }

  before do
    %w(pdep central foo immersive-orga base).each do |it|
      create(:organization,
             name: it,
             book: create(:book,
                          chapters: [create(:chapter, lessons: [create(:lesson)])],
                          name: it,
                          slug: "mumuki/mumuki-the-#{it}-book"))
    end
  end

  before { Organization.locate!('immersive-orga').update!(immersive: true) }
  before { Organization.locate!('central').update!(immersible: true) }
  before { set_current_user! user }

  context 'when organization exists' do
    before { Organization.central.switch! }

    scenario 'when visiting with implicit subdomain and no permissions' do
      set_subdomain_host! 'central'

      visit '/'

      expect(page).to have_text('Sign Out')
      expect(page).not_to have_text('Do you want to go there?')
    end

    scenario 'when visiting immersible orga with permissions to only one non-immersive organization' do
      set_current_user! user2
      set_subdomain_host! 'central'

      visit '/'

      expect(page).to have_text('Sign Out')
      expect(page).not_to have_text('Do you want to go there?')
    end

    scenario 'when visiting immersible orga with permissions to only one immersive organization', :navigation_error do
      set_current_user! user4
      set_subdomain_host! 'central'

      visit '/'

      expect(page).to have_text('Sign Out')
      expect(page).not_to have_text('Do you want to go there?')
      expect(page).to have_text('immersive-orga')
    end

    scenario 'when visiting immersible orga with permissions to many non-immersive organizations' do
      set_current_user! user3
      set_subdomain_host! 'central'

      visit '/'

      expect(page).to have_text('Sign Out')
      expect(page).not_to have_text('Do you want to go there?')
    end
  end

  scenario 'when organization does not exist', :http_response_headers do
    visit '/'

    expect(page).to have_http_status(404)
  end
end