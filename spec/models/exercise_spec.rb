require 'spec_helper'

describe Exercise do
  let(:exercise) { create(:exercise) }
  let(:user) { create(:user) }

  before { I18n.locale = :en }

  describe '#new_solution' do
    context 'when there is default content' do
      let(:exercise) { create(:exercise, default_content: 'foo') }

      it { expect(exercise.new_solution.content).to eq 'foo' }
    end

    context 'when there is no default content' do
      let(:exercise) { create(:exercise) }

      it { expect(exercise.new_solution.content).to be_nil }
    end
  end

  describe '#submit_solution!' do
    context 'when exercise has no guide' do
      before { exercise.submit_solution!(user, content: '') }

      it { expect(user.last_guide).to eq exercise.guide }
      it { expect(user.last_organization).to eq Organization.current }
    end
  end

  describe '#next_for' do
    context 'when exercise has no guide' do
      it { expect(exercise.next(user)).to be nil }
    end
    context 'when exercise belong to a guide with a single exercise' do
      let(:exercise_with_guide) { create(:exercise, guide: guide) }
      let(:guide) { create(:guide) }

      it { expect(exercise_with_guide.next(user)).to be nil }
    end
    context 'when exercise belongs to a guide with two exercises' do
      let!(:exercise_with_guide) { create(:exercise, guide: guide, number: 2) }
      let!(:alternative_exercise) { create(:exercise, guide: guide, number: 3) }
      let!(:guide) { create(:guide) }

      it { expect(exercise_with_guide.next(user)).to eq alternative_exercise }
    end
    context 'when exercise belongs to a guide with two exercises and alternative exercise has being solved' do
      let(:exercise_with_guide) { create(:exercise, guide: guide) }
      let!(:alternative_exercise) { create(:exercise, guide: guide) }
      let(:guide) { create(:guide) }

      before { alternative_exercise.submit_solution!(user, content: 'foo').passed! }

      it { expect(exercise_with_guide.next(user)).to be nil }
    end

    context 'when exercise belongs to a guide with two exercises and alternative exercise has being submitted but not solved' do
      let!(:exercise_with_guide) { create(:exercise, guide: guide, number: 2) }
      let!(:alternative_exercise) { create(:exercise, guide: guide, number: 3) }
      let(:guide) { create(:guide) }

      before { alternative_exercise.submit_solution!(user, content: 'foo') }

      it { expect(guide.pending_exercises(user)).to_not eq [] }
      it { expect(guide.next_exercise(user)).to_not be nil }
      it { expect(guide.pending_exercises(user)).to include(alternative_exercise) }
      it { expect(exercise_with_guide.next(user)).to eq alternative_exercise }
      it { expect(guide.exercises).to_not eq [] }
      it { expect(exercise_with_guide.guide).to eq guide }
      it { expect(guide.pending_exercises(user)).to include(exercise_with_guide) }
    end
  end

  describe '#extra' do
    context 'when exercise has no extra code' do
      it { expect(exercise.extra).to eq '' }
    end

    context 'when exercise has extra code and has no guide' do
      let!(:exercise_with_extra) { create(:exercise, extra: 'exercise extra code') }

      it { expect(exercise_with_extra.extra).to eq "exercise extra code\n" }
    end

    context 'when exercise has extra code and ends with new line and has no guide' do
      let!(:exercise_with_extra) { create(:exercise, extra: "exercise extra code\n") }

      it { expect(exercise_with_extra.extra).to eq "exercise extra code\n" }
    end

    context 'when exercise has extra code and belong to a guide with no extra code' do
      let!(:exercise_with_extra) { create(:exercise, guide: guide, extra: 'exercise extra code') }
      let!(:guide) { create(:guide) }

      it { expect(exercise_with_extra.extra).to eq "exercise extra code\n" }
    end

    context 'when exercise has extra code and belong to a guide with extra code' do
      let!(:exercise_with_extra) { create(:exercise, guide: guide, extra: 'exercise extra code') }
      let!(:guide) { create(:guide, extra: 'guide extra code') }

      it { expect(exercise_with_extra.extra).to eq "guide extra code\nexercise extra code\n" }
      it { expect(exercise_with_extra[:extra]).to eq 'exercise extra code' }
    end
  end

  describe '#submitted_by?' do
    context 'when user did a submission' do
      before { exercise.submit_solution!(user) }
      it { expect(exercise.assigned_to? user).to be true }
    end
    context 'when user did no submission' do
      it { expect(exercise.assigned_to? user).to be false }
    end
  end

  describe '#solved_by?' do
    context 'when user did no submission' do
      it { expect(exercise.solved_by? user).to be false }
    end
    context 'when user did a successful submission' do
      before { exercise.submit_solution!(user).passed! }

      it { expect(exercise.solved_by? user).to be true }
    end
    context 'when user did a pending submission' do
      before { exercise.submit_solution!(user) }

      it { expect(exercise.solved_by? user).to be false }
    end
    context 'when user did both successful and failed submissions' do
      before do
        exercise.submit_solution!(user)
        exercise.submit_solution!(user).passed!
      end

      it { expect(exercise.solved_by? user).to be true }
    end
  end

  describe '#destroy' do
    context 'when there are no submissions' do
      it { exercise.destroy! }
    end

    context 'when there are submissions' do
      let!(:assignment) { create(:assignment, exercise: exercise) }
      before { exercise.destroy! }
      it { expect { Assignment.find(assignment.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end

  end

  describe '#previous_solution_for' do
    context 'when user has a single submission for the exercise' do
      let!(:assignment) { exercise.submit_solution!(user, content: 'foo') }

      it { expect(exercise.default_content_for(user)).to eq assignment.solution }
    end

    context 'when user has no submissions for the exercise' do
      it { expect(exercise.default_content_for(user)).to eq '' }
    end


    context 'when user has multiple submission for the exercise' do
      let!(:assignments) { [exercise.submit_solution!(user, content: 'foo'),
                            exercise.submit_solution!(user, content: 'bar')] }

      it { expect(exercise.default_content_for(user)).to eq assignments.last.solution }
    end

    context 'when user has no solution and exercise has default content' do
      let(:exercise) { create(:exercise, default_content: '#write here...') }

      it { expect(exercise.default_content_for(user)).to eq '#write here...' }
    end
  end

  describe '#full_text_search' do
    let!(:tagged_exercise) { create(:exercise, tag_list: ['foo'], name: 'bar') }
    let!(:untagged_exercise) { create(:exercise, name: 'baz') }

    it { expect(Exercise.full_text_search('foo')).to eq [tagged_exercise] }

    it { expect(Exercise.full_text_search('bar')).to eq [tagged_exercise] }
    it { expect(Exercise.full_text_search('baz')).to eq [untagged_exercise] }

    it { expect(Exercise.full_text_search('foobaz')).to eq [] }
  end

  describe '#guide_done_for?' do

    context 'when it does not belong to a guide' do
      it { expect(exercise.guide_done_for?(user)).to be false }
    end

    context 'when it belongs to a guide unfinished' do
      let!(:guide) { create(:guide) }
      let!(:exercise_unfinished) { create(:exercise, guide: guide) }
      let!(:exercise_finished) { create(:exercise, guide: guide) }

      before do
        exercise_finished.submit_solution!(user, content: 'foo').passed!
      end

      it { expect(exercise_finished.guide_done_for?(user)).to be false }
    end

    context 'when it belongs to a guide unfinished' do
      let!(:guide) { create(:guide) }
      let!(:exercise_finished) { create(:exercise, guide: guide) }
      let!(:exercise_finished2) { create(:exercise, guide: guide) }

      before do
        exercise_finished.submit_solution!(user, content: 'foo').passed!
        exercise_finished2.submit_solution!(user, content: 'foo').passed!
      end

      it { expect(exercise_finished.guide_done_for?(user)).to be true }
    end
  end

  describe '#language' do
    let(:guide) { create(:guide) }
    let(:exercise_with_guide) { create(:exercise, guide: guide, language: guide.language) }
    let(:other_language) { create(:language) }

    context 'when has no guide' do
      it { expect(exercise.valid?).to be true }
    end

    context 'when has guide and is consistent' do
      it { expect(exercise_with_guide.valid?).to be true }
    end
  end

  describe '#friendly_name' do
    it { expect(Exercise.find(exercise.friendly_name)).to eq exercise }
    it { expect(Problem.find(exercise.friendly_name)).to eq exercise }
  end
end
