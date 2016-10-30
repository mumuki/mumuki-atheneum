require 'spec_helper'

describe Guide do
  let!(:haskell) { create(:haskell) }
  let!(:gobstones) { create(:gobstones) }
  let(:reloaded_exercise_1) { Exercise.find(exercise_1.id) }

  let(:guide_json) do
    {name: 'sample guide',
     description: 'Baz',
     slug: 'mumuki/sample-guide',
     language: 'haskell',
     locale: 'en',
     extra: 'bar',
     teacher_info: 'an info',
     authors: 'Foo Bar',
     exercises: [
         {type: 'problem',
          name: 'Bar',
          description: 'a description',
          test: 'foo bar',
          tag_list: %w(baz bar),
          layout: 'input_bottom',
          teacher_info: 'an info',
          language: 'gobstones',
          solution: 'foo',
          id: 1},

         {type: 'playground',
          description: 'lorem ipsum',
          name: 'Foo',
          tag_list: %w(foo bar),
          extra: 'an extra code',
          extra_visible: true,
          default_content: 'a default content',
          id: 4},

         {name: 'Baz',
          description: 'lorem ipsum',
          tag_list: %w(baz bar),
          layout: 'input_bottom',
          type: 'problem',
          expectations: [{inspection: 'HasBinding', binding: 'foo'}],
          id: 2}]}.deep_stringify_keys
  end

  describe '#import_from_json!' do
    context 'when an exercise is deleted' do
      let(:guide) { create(:guide, exercises: [exercise_1, exercise_2, exercise_3, exercise_4]) }

      let(:exercise_1) { build(:problem,
                               language: haskell,
                               name: 'Exercise 1',
                               bibliotheca_id: 1,
                               number: 1) }

      let(:exercise_2) { build(:playground,
                               language: haskell,
                               name: 'Exercise 2',
                               bibliotheca_id: 4,
                               number: 2) }

      let(:exercise_3) { build(:problem,
                               language: haskell,
                               name: 'Exercise 3',
                               bibliotheca_id: 2,
                               number: 3) }

      let(:exercise_4) { create(:problem,
                               language: haskell,
                               name: 'Exercise 4',
                               bibliotheca_id: 8,
                               number: 4) }

      before do
        guide.import_from_json!(guide_json)
      end

      describe 'it is removed from the guide' do
        it { expect(guide.exercises.count).to eq 3 }
        it { expect(guide.exercises).not_to include exercise_4 }
      end

      describe 'it is deleted from the database' do
        it { expect { Exercise.find(exercise_4.id) }.to raise_error }
      end
    end

    context 'when guide is empty' do
      let(:lesson) { create(:lesson, guide: create(:guide, exercises: [])) }
      let(:guide) { lesson.guide }

      before do
        guide.import_from_json!(guide_json)
      end

      it { expect(guide).to_not be nil }
      it { expect(guide.name).to eq 'sample guide' }
      it { expect(guide.language).to eq haskell }
      it { expect(guide.slug).to eq 'mumuki/sample-guide' }
      it { expect(guide.extra).to eq 'bar' }
      it { expect(guide.description).to eq 'Baz' }

      it { expect(guide.exercises.count).to eq 3 }
      it { expect(guide.exercises.first.language).to eq gobstones }
      it { expect(guide.exercises.first.extra_visible).to be false }
      it { expect(guide.exercises.second.language).to eq haskell }
      it { expect(guide.exercises.second.default_content).to eq 'a default content' }
      it { expect(guide.exercises.second.extra_visible).to be true }

      it { expect(guide.exercises.last.expectations.first['binding']).to eq 'foo' }

      it { expect(guide.exercises.pluck(:name)).to eq %W(Bar Foo Baz) }
    end

    context 'when exercise already exists' do
      let(:guide) { create(:guide, language: haskell, exercises: [exercise_1]) }

      before do
        guide.import_from_json! guide_json
      end

      context 'when exercise changes its type' do
        let(:exercise_1) { build(:playground,
                                 bibliotheca_id: 1,
                                 language: haskell,
                                 name: 'Exercise 1',
                                 description: 'description') }

        describe 'exercises are not duplicated' do
          it { expect(guide.exercises.count).to eq 3 }
          it { expect(Exercise.count).to eq 3 }
        end

        it { expect(guide.exercises.first).to be_instance_of(Problem) }
        it { expect(guide.exercises.first).to eq reloaded_exercise_1 }

      end
      context 'exercises are reordered' do
        let(:exercise_1) { create(:problem,
                                  bibliotheca_id: 4,
                                  language: haskell,
                                  name: 'Exercise 1',
                                  description: 'description',
                                  hint: 'baz',
                                  test: 'pending',
                                  extra: 'foo') }

        it 'identity should be preserved' do
          expect(guide.exercises.first).to_not eq reloaded_exercise_1
          expect(guide.exercises.second).to eq reloaded_exercise_1
        end

        it { expect(guide.exercises.pluck(:bibliotheca_id)).to eq [1, 4, 2] }

        describe 'exercises are not duplicated' do
          it { expect(guide.exercises.count).to eq 3 }
          it { expect(Exercise.count).to eq 3 }
        end
      end
    end

    context 'when many exercises already exist' do
      let(:guide) { create(:guide, language: haskell, exercises: [exercise_1, exercise_2]) }

      let(:exercise_1) { build(:problem,
                               language: haskell,
                               name: 'Exercise 1',
                               bibliotheca_id: 2,
                               number: 1,
                               description: 'description',
                               corollary: 'A corollary',
                               test: 'foo',
                               hint: 'baz',
                               extra: 'foo') }
      let(:exercise_2) { build(:playground,
                               language: haskell,
                               name: 'Exercise 2',
                               bibliotheca_id: 4,
                               number: 2,
                               description: 'description',
                               corollary: 'A corollary',
                               hint: 'baz',
                               extra: 'foo') }
      let(:reloaded_exercise_2) { Exercise.find(exercise_2.id) }

      before do
        guide.import_from_json! guide_json
      end

      describe 'exercises are not duplicated' do
        it { expect(guide.exercises.count).to eq 3 }
        it { expect(Exercise.count).to eq 3 }
      end

      it { expect(guide.exercises.first).to be_instance_of(Problem) }
      it { expect(guide.exercises.second).to be_instance_of(Playground) }
      it { expect(guide.exercises.third).to be_instance_of(Problem) }

      it { expect(guide.exercises.second).to eq reloaded_exercise_2 }
      it { expect(guide.exercises.third).to eq reloaded_exercise_1 }

      it { expect(guide.exercises.first.number).to eq 1 }
      it { expect(guide.exercises.second.number).to eq 2 }
      it { expect(guide.exercises.third.number).to eq 3 }

      it { expect(guide.exercises.pluck(:bibliotheca_id)).to eq [1, 4, 2] }
      it { expect(guide.exercises.pluck(:id).drop(1)).to eq [reloaded_exercise_2.id, reloaded_exercise_1.id] }
    end

    context 'when new_expecations' do
      let(:guide) { create(:guide, language: haskell) }
      let(:guide_json) do
        {name: 'sample guide',
         description: 'Baz',
         slug: 'mumuki/sample-guide',
         language: 'haskell',
         locale: 'en',
         extra: 'bar',
         teacher_info: 'an info',
         authors: 'Foo Bar',
         exercises: [
             {name: 'Baz',
              description: 'lorem ipsum',
              tag_list: %w(baz bar),
              layout: 'input_bottom',
              test: 'foo bar',
              type: 'problem',
              expectations: [{inspection: 'HasBinding', binding: 'foo'}],
              new_expectations: true,
              id: 2}]}.deep_stringify_keys
      end

      before do
        guide.import_from_json! guide_json
      end

      it { expect(guide.exercises.first.new_expectations).to be_truthy }
      it { expect(guide.exercises.first.expectations).to eq [] }
    end
  end
end
