module ContentType
  def self.for(type)
    Kernel.const_get "ContentType::#{type.to_s.titleize}"
  end

  module Html
    def self.to_html(content)
      content.html_safe if content
    end
  end

  module Plain
    def self.to_html(content)
      content
    end
  end

  module Markdown
    @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, fenced_code_blocks: true)

    def self.to_html(content)
      @@markdown.render(content).html_safe if content
    end
  end
end
