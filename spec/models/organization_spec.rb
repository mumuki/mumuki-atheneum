require 'spec_helper'

describe Organization do
  let(:user) { create(:user) }
  let(:central) { create(:organization, name: 'central') }

  describe '.current' do
    let(:organization) { Organization.find_by(name: 'test') }
    it { expect(organization).to_not be nil }
    it { expect(organization).to eq Organization.current }
  end

  describe 'defaults' do
    let(:fresh_organization) { create(:organization, name: 'bar') }
    it { expect(fresh_organization.settings.customized_login_methods?).to be true }
  end

  describe '#notify_recent_assignments!' do
    it { expect { Organization.current.notify_recent_assignments! 1.minute.ago }.to_not raise_error }
  end

  describe 'restricter_login_methods?' do
    let(:private_organization) { create(:private_organization, name: 'digitaldojo') }
    let(:public_organization) { create(:public_organization, name: 'guolok') }

    it { expect(private_organization.settings.customized_login_methods?).to be true }
    it { expect(private_organization.private?).to be true }

    it { expect { private_organization.update! public: true }.to raise_error('Validation failed: A public organization can not restrict login methods') }

    it { expect(public_organization.settings.customized_login_methods?).to be false }
    it { expect(public_organization.private?).to be false }
  end

  describe '#notify_assignments_by!' do
    it { expect { Organization.current.notify_assignments_by! user }.to_not raise_error }
  end

  describe '#in_path?' do
    let(:organization) { Organization.current }
    let!(:chapter_in_path) { create(:chapter, lessons: [
      create(:lesson, exercises: [
        create(:exercise),
        create(:exercise)
      ]),
      create(:lesson)
    ]) }
    let(:topic_in_path) { chapter_in_path.lessons.first }
    let(:topic_in_path) { chapter_in_path.topic }
    let(:lesson_in_path) { chapter_in_path.lessons.first }
    let(:guide_in_path) { lesson_in_path.guide }
    let(:exercise_in_path) { lesson_in_path.exercises.first }

    let!(:orphan_exercise) { create(:exercise) }
    let!(:orphan_guide) { orphan_exercise.guide }

    before { reindex_current_organization! }

    it { expect(organization.in_path? orphan_guide).to be false }
    it { expect(organization.in_path? orphan_exercise).to be false }

    it { expect(organization.in_path? chapter_in_path).to be true }
    it { expect(organization.in_path? topic_in_path).to be true }
    it { expect(organization.in_path? lesson_in_path).to be true }
    it { expect(organization.in_path? guide_in_path).to be true }
  end


  describe 'login_settings' do
    let(:fresh_organization) { create(:organization, name: 'foo') }
    it { expect(fresh_organization.login_settings.login_methods).to eq Mumukit::Login::Settings.default_methods }
    it { expect(fresh_organization.login_settings.social_login_methods).to eq [] }
    it { expect(fresh_organization.login_settings.to_lock_json('/foo')).to be_html_safe }
  end

  describe 'validations' do
    let(:book) { create :book }

    def organization_with_name(name)
      Organization.new name: name, contact_email: 'a@a.com', locale: 'es', book: book
    end

    describe 'organization name' do
      it { expect(build(:organization).valid?).to be true }
      it { expect(organization_with_name('a.name').valid?).to be true }
      it { expect(organization_with_name('a.name.with.subdomains').valid?).to be true }
      it { expect(organization_with_name('.a.name.that.starts.with.period').valid?).to be false }
      it { expect(organization_with_name('a.name.that.ends.with.period.').valid?).to be false }
      it { expect(organization_with_name('a.name.that..has.two.periods.in.a.row').valid?).to be false }
      it { expect(organization_with_name('a.name.with.Uppercases').valid?).to be false }
      it { expect(organization_with_name('A random name').valid?).to be false }
    end

    context 'is valid when all is ok' do
      let(:organization) { build :organization }
      it { expect(organization.valid?).to be true }
    end

    context 'is invalid when there are no books' do
      let(:organization) { build :organization, book: nil }
      it { expect(organization.valid?).to be false }
    end

    context 'is invalid when the locale isnt known' do
      let(:organization) { build :organization, locale: 'uk-DA' }
      it { expect(organization.valid?).to be false }
    end

    context 'has login method' do
      let(:organization) { build :organization, login_methods: ['github'] }
      it { expect(organization.has_login_method? 'github').to be true }
      it { expect(organization.has_login_method? 'google').to be false }
    end
  end
end
