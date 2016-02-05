require 'spec_helper'

describe Guide do
  let!(:extra_user) { create(:user, name: 'ignatiusReilly') }
  let(:guide) { create(:guide) }

  describe '#next_for' do
    let(:chapter) { create(:chapter) }

    context 'when guide is not in chapter' do
      it { expect(guide.next_for(extra_user)).to be nil }
    end
    context 'when guide is in chapter' do
      let(:guide_in_chapter) { create(:guide) }

      context 'when it is single' do
        before { chapter.rebuild!([create(:guide), guide_in_chapter]) }

        it { expect(guide_in_chapter.next_for(extra_user)).to be nil }
        it { expect(guide_in_chapter.chapter).to eq chapter }
      end

      context 'when there is a next guide' do
        let!(:other_guide) { create(:guide) }
        before { chapter.rebuild!([create(:guide), guide_in_chapter, other_guide]) }

        it { expect(guide_in_chapter.next_for(extra_user)).to eq other_guide }
      end
      context 'when there are many next guides at same level' do
        let!(:other_guide_1) { create(:guide) }
        let!(:other_guide_2) { create(:guide) }

        before { chapter.rebuild!([create(:guide), guide_in_chapter, other_guide_1, other_guide_2]) }

        it { expect(guide_in_chapter.next_for(extra_user)).to eq other_guide_1 }
      end
    end
  end

  describe '#navigable_name' do
    let(:chapter) { create(:chapter) }
    context 'when guide is not in chapter' do
      it { expect(guide.navigable_name).to be guide.name }
    end
    context 'when guide is in chapter' do
      let!(:guide_in_chapter) { create(:guide) }
      before { chapter.rebuild! [create(:guide), guide_in_chapter] }

      it { expect(guide_in_chapter.navigable_name).to eq "2. #{guide_in_chapter.name}" }
    end
  end

  describe '#friendly' do
    let(:chapter) { create(:chapter) }
    context 'when guide is not in chapter' do
      it { expect(guide.friendly).to be guide.name }
    end
    context 'when guide is in chapter' do
      let(:guide_in_chapter) { create(:guide) }

      before do
        chapter.rebuild!([create(:guide), guide_in_chapter])
      end

      it { expect(guide_in_chapter.friendly).to eq "#{chapter.name}: #{guide_in_chapter.name}" }
    end
  end

  describe '#friendly_name' do
    let(:chapter) { create(:chapter, name: 'Fundamentos de Programacion') }
    let(:guide_in_chapter) { create(:guide, name: 'Una Guia') }

    before do
      chapter.rebuild!([create(:guide), create(:guide), guide_in_chapter])
    end

    it { expect(guide_in_chapter.chapter).to eq chapter }
    it { expect(guide_in_chapter.friendly_name).to eq "#{guide_in_chapter.id}-fundamentos-de-programacion-una-guia" }
  end

  describe '#new?' do
    context 'when just created' do
      it { expect(guide.new?).to be true }
    end
    context 'when created a month ago' do
      before { guide.update!(created_at: 1.month.ago) }

      it { expect(guide.new?).to be false }
    end
  end


  describe '#submission_contents_for' do
    before do
      guide.exercises = [create(:exercise, language: guide.language), create(:exercise, language: guide.language)]
      guide.save!
    end
  end


end
