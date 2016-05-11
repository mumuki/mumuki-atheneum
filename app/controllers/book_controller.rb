class BookController < ApplicationController
  before_action :redirect_to_last_guide_if_possible, only: :show

  def show
    @book = Organization.current.book
  end

  private

  def redirect_to_last_guide_if_possible
    redirect_to_last_guide if should_redirect_to_last_guide?
  end
end