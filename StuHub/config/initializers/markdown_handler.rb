# http://stackoverflow.com/questions/4163560/how-can-i-automatically-render-partials-using-markdown-in-rails-3/10131299#10131299

module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template)
    compiled_source = erb.call(template)
    "Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_intra_emphasis: true, autolink: true).render(begin;#{compiled_source};end).html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
