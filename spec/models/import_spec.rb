require 'spec_helper'

describe Import do
  let(:committer) { create(:user) }
  let(:import) { guide.imports.build(committer: committer) }

  describe '#status' do
    let(:guide) { create(:guide) }

    it { expect(import.status).to eq 'pending' }
  end


  describe '#import_from_directory!' do
    let(:guide) { create(:guide) }
    let!(:haskell) { create(:haskell) }

    before do
      import.read_guide! 'spec/data/mumuki-sample-exercises'
      guide.reload
    end

    it { expect(Exercise.count).to eq 2 }
    it { expect(guide.description).to eq "Awesome guide\n" }
    it { expect(guide.language).to eq haskell }
    it { expect(guide.locale).to eq 'en' }

    context 'when importing basic exercise' do
      let(:imported_exercise) { Exercise.find_by(guide_id: guide.id, original_id: 1) }

      it { expect(imported_exercise).to_not be nil }
      it { expect(imported_exercise.author).to eq guide.author }
      it { expect(imported_exercise.title).to eq 'sample_title' }
      it { expect(imported_exercise.description).to eq '##Sample Description' }
      it { expect(imported_exercise.test).to eq 'pending' }
      it { expect(imported_exercise.extra_code).to eq "extra\n" }
      it { expect(imported_exercise.hint).to be nil }
      it { expect(imported_exercise.language).to eq haskell }
      it { expect(imported_exercise.expectations.size).to eq 2 }
      it { expect(imported_exercise.tag_list).to include *%w(foo bar baz) }
      it { expect(guide.description).to eq "Awesome guide\n" }
    end

    context 'when importing exercise with errors' do
      let(:imported_exercise) { Exercise.find_by(guide_id: guide.id, original_id: 2) }

      it { expect(imported_exercise).to be nil }
    end

    context 'when importing exercise with hint' do
      let(:imported_exercise) { Exercise.find_by(guide_id: guide.id, original_id: 3) }

      it { expect(imported_exercise).to_not be nil }
      it { expect(imported_exercise.hint).to eq "Try this: blah blah\n" }
    end
  end

  describe '#import!' do
    let(:guide) { create(:guide, github_repository: 'foo/bar') }

    before do
      begin
        import.run_import!
      rescue
      end
    end

    context 'when repository does not exist' do
      before do
        expect_any_instance_of(WithGitAccess).to receive(:clone_repo_into).and_raise('Repository is private or does not exist')
      end
      it { expect(import.status).to eq 'failed' }
      it { expect(import.result).to eq 'Repository is private or does not exist' }
    end

    it 'succeeds when repo is private'

    context 'when repository exists' do
      before do
        expect_any_instance_of(WithGitAccess).to receive(:clone_repo_into)
      end
      it { expect(import.status).to eq 'passed' }
      it { expect(import.result).to eq '' }
    end
  end
end
