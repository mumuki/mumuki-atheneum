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
    it { expect(fresh_organization.private?).to be true }
    it { expect(fresh_organization.customized_login_methods?).to be true }
  end

  describe '#notify_recent_assignments!' do
    it { expect { Organization.notify_recent_assignments! 1.minute.ago }.to_not raise_error }
  end

  describe 'restricter_login_methods?' do
    let(:private_organization) { create(:private_organization, name: 'digitaldojo') }
    let(:public_organization) { create(:public_organization, name: 'guolok') }

    it { expect(private_organization.customized_login_methods?).to be true }
    it { expect(private_organization.private?).to be true }

    it { expect { private_organization.update! private: false }.to raise_error('Validation failed: A public organization can not restrict login methods') }

    it { expect(public_organization.customized_login_methods?).to be false }
    it { expect(public_organization.private?).to be false }
  end

  describe '#url_for' do
    it { expect(Organization.url_for 'zaraza').to eq 'http://test.localmumuki.io:3000/zaraza' }
    it { expect(central.url_for 'zaraza').to eq 'http://central.localmumuki.io:3000/zaraza' }
  end

  describe '#domain' do
    it { expect(Organization.domain).to eq 'test.localmumuki.io' }
    it { expect(central.domain).to eq 'central.localmumuki.io' }
  end

  describe '#notify_assignments_by!' do
    it { expect { Organization.notify_assignments_by! user }.to_not raise_error }
  end

  describe '#in_path?' do
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

    it { expect(Organization.in_path? orphan_guide).to be false }
    it { expect(Organization.in_path? orphan_exercise).to be false }

    it { expect(Organization.in_path? chapter_in_path).to be true }
    it { expect(Organization.in_path? topic_in_path).to be true }
    it { expect(Organization.in_path? lesson_in_path).to be true }
    it { expect(Organization.in_path? guide_in_path).to be true }
  end

end
