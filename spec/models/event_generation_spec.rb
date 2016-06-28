require 'spec_helper'

describe Event do

  describe '#to_json' do
    describe Event::Submission do
      let(:user) { create(:user, id: 2, name: 'foo', provider: 'auth0', uid: 'github|gh1234') }
      describe 'lesson type' do
        let(:lesson) { chapter.lessons.fourth }
        let(:guide) { lesson.guide }
        let(:exercise) { lesson.exercises.first }
        let!(:chapter) {
          create(:chapter, lessons: [
            create(:lesson),
            create(:lesson),
            create(:lesson),
            create(:lesson, exercises: [create(:exercise)])]) }

        before { reindex_current_organization! }

        let(:assignment) { create(:assignment,
                                  solution: 'x = 2',
                                  status: Status::Passed,
                                  submissions_count: 2,
                                  submitter: user,
                                  submission_id: 'abcd1234',
                                  exercise: exercise) }
        let(:event) { Event::Submission.new(assignment) }
        let(:json) { event.as_json.deep_symbolize_keys }

        it { expect(lesson.number).to eq 4 }
        it do
          expect(json).to eq(status: Status::Passed,
                             result: nil,
                             expectation_results: nil,
                             feedback: nil,
                             test_results: nil,
                             submissions_count: 2,
                             exercise: {
                               id: exercise.id,
                               name: exercise.name,
                               number: exercise.number},
                             guide: {
                               name: guide.name,
                               slug: guide.slug,
                               lesson: {
                                 number: 4,
                               },
                               language: {
                                 name: guide.language.name
                               },
                               parent: {
                                 type: 'Lesson',
                                 name:  guide.name,
                                 position: 4,
                                 chapter: {
                                   id: guide.chapter.id,
                                   name: guide.chapter.name
                                 }
                               }
                             },
                             submitter: {
                               social_id: 'github|gh1234',
                               name: 'foo',
                               email: nil,
                               image_url: 'user_shape.png'},
                             id: 'abcd1234',
                             created_at: assignment.updated_at,
                             content: 'x = 2',
                             tenant: 'test')
        end
      end
      describe 'exam type' do
        let!(:exam) { create(:exam, guide: create(:guide, exercises: [create(:exercise)])) }
        let(:guide) { exam.guide }
        let(:exercise) { guide.exercises.first }
        before { reindex_current_organization! }
        let(:assignment) { create(:assignment,
                                  solution: 'x = 2',
                                  status: Status::Passed,
                                  submissions_count: 2,
                                  submitter: user,
                                  submission_id: 'abcd1234',
                                  exercise: exercise) }
        let(:event) { Event::Submission.new(assignment) }
        let(:json) { event.as_json.deep_symbolize_keys }

        it do
          expect(json).to eq(status: Status::Passed,
                             result: nil,
                             expectation_results: nil,
                             feedback: nil,
                             test_results: nil,
                             submissions_count: 2,
                             exercise: {
                               id: exercise.id,
                               name: exercise.name,
                               number: exercise.number},
                             guide: {
                               name: guide.name,
                               slug: guide.slug,
                               language: {
                                 name: guide.language.name
                               },
                               parent: {
                                 type: 'Exam',
                                 name:  guide.name,
                                 position: nil,
                                 chapter: nil
                               }
                             },
                             submitter: {
                               name: 'foo',
                               email: nil,
                               image_url: 'user_shape.png',
                               social_id: 'github|gh1234'},
                             id: 'abcd1234',
                             created_at: assignment.updated_at,
                             content: 'x = 2',
                             tenant: 'test')

        end
      end
      describe 'complementary type' do
        let!(:complement) { create(:complement, guide: create(:guide, exercises: [create(:exercise)])) }
        let(:guide) { complement.guide }
        let(:exercise) { guide.exercises.first }
        before { reindex_current_organization! }
        let(:assignment) { create(:assignment,
                                  solution: 'x = 2',
                                  status: Status::Passed,
                                  submissions_count: 2,
                                  submitter: user,
                                  submission_id: 'abcd1234',
                                  exercise: exercise) }
        let(:event) { Event::Submission.new(assignment) }
        let(:json) { event.as_json.deep_symbolize_keys }

        it do
          expect(json).to eq(status: Status::Passed,
                             result: nil,
                             expectation_results: nil,
                             feedback: nil,
                             test_results: nil,
                             submissions_count: 2,
                             exercise: {
                               id: exercise.id,
                               name: exercise.name,
                               number: exercise.number},
                             guide: {
                               name: guide.name,
                               slug: guide.slug,
                               language: {
                                 name: guide.language.name
                               },
                               parent: {
                                 type: 'Complement',
                                 name:  guide.name,
                                 position: nil,
                                 chapter: nil
                               }
                             },
                             submitter: {
                               name: 'foo',
                               email: nil,
                               image_url: 'user_shape.png',
                               social_id: 'github|gh1234'},
                             id: 'abcd1234',
                             created_at: assignment.updated_at,
                             content: 'x = 2',
                             tenant: 'test')

        end
      end
    end
  end
end
