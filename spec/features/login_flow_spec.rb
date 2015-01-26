require 'spec_helper'

feature 'Login Flow' do
  let!(:exercise) { create(:exercise) }

  scenario 'login from home' do
    visit '/'

    click_on 'Sign in with Github'

    expect(page).to have_text('testuser')
    expect(page).to have_text('Mumuki is a simple, open and collaborative platform')
  end

  scenario 'login from home, localized' do
    visit '/es'

    click_on 'Iniciá sesion con Github'

    expect(page).to have_text('testuser')
    expect(page).to have_text('Mumuki es una plataforma simple, abierta y colaborativa')
  end


  scenario 'login on authentication request' do
    visit "/en/exercises/#{exercise.id}"

    click_on 'New Submission'

    expect(page).to have_text('You must sign in with Github before continue')
    expect(page).to_not have_text("New submission for #{exercise.title}")

    click_on 'sign in with Github'

    expect(page).to have_text("New submission for #{exercise.title}")
    expect(page).to_not have_text('You must sign in with Github before continue')

  end
end
