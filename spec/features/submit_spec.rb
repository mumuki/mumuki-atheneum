require 'spec_helper'

feature 'Search Flow' do
  let(:haskell) { create(:language, name: 'Haskell') }
  let!(:exercise) {
    create(:exercise, tag_list: ['haskell'], title: 'Foo', description: 'an awesome problem description')
  }

  scenario 'open new submission' do
    visit "/en/exercises/#{exercise.id}"

    click_on 'Sign in with Github'
    click_on 'New Submission'

    expect(page).to have_text('New submission for Foo')
  end


  scenario 'visit my submissions, when there are no submissions' do
    visit "/en/exercises/#{exercise.id}"

    click_on 'Sign in with Github'
    click_on 'My Submissions'

    expect(page).to have_text('Submissions for Foo')
  end


end
