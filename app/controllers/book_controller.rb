class BookController < ApplicationController

  def show
    @book = Organization.current.book
    @exams = Organization.current.accessible_exams_for current_user
  end

  private

  def authorization_minimum_role
    :ex_student
  end
end
