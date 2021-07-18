require 'spec_helper'

feature 'menu bar' do
  let(:lesson) { create(:lesson, exercises: create_list(:exercise, 3))}
  let(:chapter) { create(:chapter, lessons: [lesson]) }
  let(:book) { create(:book, chapters: [chapter], name: 'private', slug: 'mumuki/mumuki-the-private-book') }
  let(:private_organization) { create(:organization, name: 'private', book: book) }

  before { set_subdomain_host! private_organization.name }
  before { private_organization.switch! }

  context 'anonymous user' do
    before { set_automatic_login! false }

    context 'on organization without permissions' do
      scenario 'should not see menu bar' do
        visit '/'

        expect(page).not_to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).not_to have_text('FAQs')
      end
    end

    context 'on organization with permissions' do
      let(:public_organization) { create(:public_organization, book: book) }
      before { set_subdomain_host! public_organization.name }
      before { public_organization.switch! }

      scenario 'should not see menu bar' do
        visit '/'

        expect(page).not_to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).not_to have_text('Solve other\'s doubts')
        expect(page).not_to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end
    end
  end

  context 'logged user' do
    let(:visitor) { create(:user) }
    let(:student) { create(:user, permissions: {student: 'private/*'}) }
    let(:teacher) { create(:user, permissions: {student: 'private/*', teacher: 'private/*'}) }
    let(:writer) { create(:user, permissions: {student: 'private/*', writer: 'private/*'}) }
    let(:janitor) { create(:user, permissions: {student: 'private/*', janitor: 'private/*'}) }
    let(:admin) { create(:user, permissions: {student: 'private/*', admin: 'private/*'}) }
    let(:owner) { create(:user, permissions: {student: 'private/*', owner: 'private/*'}) }

    scenario 'visitor should only see sing out' do
      set_current_user! visitor

      visit '/'
      expect(page).not_to have_text('My account')
      expect(page).not_to have_text('Classroom')
      expect(page).not_to have_text('Bibliotheca')
      expect(page).not_to have_text('Solve other\'s doubts')
      expect(page).not_to have_text('My doubts')
      expect(page).not_to have_text('FAQs')
    end

    context 'student with no discussions should' do
      scenario 'only see their account if forum is not enabled' do
        set_current_user! student

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).not_to have_text('Solve other\'s doubts')
        expect(page).not_to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end

      scenario 'see their account and solve_other_doubts links if forum is enabled' do
        set_current_user! student
        private_organization.update! forum_enabled: true

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).to have_text('Solve other\'s doubts')
        expect(page).not_to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end
    end

    context 'organization with faqs' do
      before { Organization.current.update! faqs: "Some faqs" }

      scenario 'should see FAQs link' do
        set_current_user! student
        visit '/'

        expect(page).to have_text('FAQs')
      end
    end

    context 'student with discussions should' do
      let(:discussion) { create(:discussion, item: lesson.exercises.last, initiator: student)}

      scenario 'only see their account if forum is not enabled' do
        set_current_user! student
        student.subscribe_to! discussion

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).not_to have_text('Solve other\'s doubts')
        expect(page).not_to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end

      scenario 'see all discussions links if forum is enabled' do
        set_current_user! student
        private_organization.update! forum_enabled: true
        student.subscribe_to! discussion

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).to have_text('Solve other\'s doubts')
        expect(page).to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end

      scenario 'only see their account if forum is enabled in a forum_only_for_trusted organization' do
        set_current_user! student
        student.subscribe_to! discussion
        private_organization.update! forum_enabled: true
        private_organization.update! forum_only_for_trusted: true

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).not_to have_text('Solve other\'s doubts')
        expect(page).not_to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end

      scenario 'see all discussions links if forum is enabled in a forum_only_for_trusted organization but it is trusted' do
        student.update! trusted_for_forum: true
        set_current_user! student
        student.subscribe_to! discussion
        private_organization.update! forum_enabled: true
        private_organization.update! forum_only_for_trusted: true

        visit '/'
        expect(page).to have_text('My account')
        expect(page).not_to have_text('Classroom')
        expect(page).not_to have_text('Bibliotheca')
        expect(page).to have_text('Solve other\'s doubts')
        expect(page).to have_text('My doubts')
        expect(page).not_to have_text('FAQs')
      end
    end

    scenario 'teacher should see their account and classroom' do
      set_current_user! teacher

      visit '/'

      expect(page).to have_text('My account')
      expect(page).to have_text('Classroom')
      expect(page).not_to have_text('Bibliotheca')
      expect(page).not_to have_text('Solve other\'s doubts')
      expect(page).not_to have_text('My doubts')
      expect(page).not_to have_text('FAQs')
    end

    scenario 'writer should see their account and bibliotheca' do
      set_current_user! writer

      visit '/'

      expect(page).to have_text('My account')
      expect(page).not_to have_text('Classroom')
      expect(page).to have_text('Bibliotheca')
    end

    scenario 'janitor should see their account and classroom' do
      set_current_user! janitor

      visit '/'

      expect(page).to have_text('My account')
      expect(page).to have_text('Classroom')
      expect(page).not_to have_text('Bibliotheca')
    end

    scenario 'admin should their account, classroom and bibliotheca' do
      set_current_user! admin

      visit '/'

      expect(page).to have_text('My account')
      expect(page).to have_text('Classroom')
      expect(page).to have_text('Bibliotheca')
    end

    scenario 'owner should see their account, classroom and bibliotheca' do
      set_current_user! owner

      visit '/'

      expect(page).to have_text('My account')
      expect(page).to have_text('Classroom')
      expect(page).to have_text('Bibliotheca')
    end
  end
end
