class ExercisesController < ApplicationController
  include WithExerciseIndex

  before_action :set_exercises, only: [:index]
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]
  before_action :authenticate!, except: [:show, :index]

  def show
  end

  def index

  end

  def new
    @exercise = Exercise.new
  end

  def edit
  end

  def create
    @exercise = current_user.exercises.build(exercise_params)

    if @exercise.save
      redirect_to @exercise, notice: 'Exercise was successfully created.'
    else
      render :new
    end
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to @exercise, notice: 'Exercise was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end

  private
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:title, :description, :test, :language_id, :tag_list)
  end

  def exercises
    Exercise.all
  end

end
