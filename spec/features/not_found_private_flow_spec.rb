require 'spec_helper'

feature 'not found private on app', organization_workspace: :base do
  before { set_subdomain_host! Organization.base.name }
  before { Organization.base.switch! }

  let(:admin) { create(:user, permissions: {admin: '*'}) }
  let(:student_api_client) { create :api_client, role: :student, grant: 'central/*' }
  let(:admin_api_client) { create :api_client, role: :admin, grant: '*' }

  scenario 'app without authentication' do
    visit '/nonexistentroute'

    expect(page).to have_text 'You are not allowed to see this content'
  end

  scenario 'app with authentication' do
    set_current_user! admin

    visit '/nonexistentroute'

    expect(page).to have_text 'You may have mistyped the address or the page may have moved'
  end

  scenario 'api without authorization', :json_eq_error do
    set_request_header! 'Authorization', "Bearer #{student_api_client.token}"

    visit '/api/nonexistentroute'

    expect(page.text).to json_eq errors: [
      'The operation on organization base' +
      ' was forbidden to user foo+1@bar.com' +
      ' with permissions !student:central/*;teacher:;headmaster:;janitor:;admin:;owner:;ex_student:']
  end

  scenario 'api with authentication', :json_eq_error do
    set_request_header! 'Authorization', "Bearer #{admin_api_client.token}"

    visit '/api/nonexistentroute'

    expect(page.text).to json_eq errors: ['not found']
  end
end
