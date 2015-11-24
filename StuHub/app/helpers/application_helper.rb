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

  # Always use the Twitter Bootstrap pagination renderer
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => BootstrapPagination::Rails
    end
    super *[collection_or_options, options].compact
  end
end
