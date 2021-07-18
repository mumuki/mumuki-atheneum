class FAQsController < ApplicationController
  def authorization_minimum_role
    :ex_student
  end

  def index
    @faqs = Organization.current.faqs_html
    raise Mumuki::Domain::NotFoundError unless @faqs.present?
  end
end
