module ApplicationHelper
  def markdown(text)
    options = {
      filter_html: true,
      hard_wrap: true,
      with_toc_data: true,
      link_attributes: { rel: 'nofollow', target: "_blank" }
    }
    extensions = {
      autolink: true,
      tables: true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true
    }
    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end
end
