require 'mumukit/bridge'

class Language < ActiveRecord::Base
  include WithMarkup

  enum output_content_type: [:plain, :html, :markdown]

  validates_presence_of :test_runner_url,
                        :extension, :image_url, :output_content_type

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  markup_on :test_syntax_hint

  def self.find_by_name!(name)
    self.where('lower(name) = ?', name.downcase).first
  end

  def run_tests!(request)
    bridge.run_tests!(request)
  end

  def bridge
    Mumukit::Bridge::Bridge.new(test_runner_url)
  end

  def test_extension
    self[:test_extension] || extension
  end

  def highlight_mode
    self[:highlight_mode] || name
  end

  def to_s
    name
  end

  def output_to_html(content)
    ContentType.for(output_content_type).to_html(content)
  end
end
