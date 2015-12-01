module UsersHelper

  # return certain user's Gravatar
  def avatar_for(user, options = { size: 150, class: '' })
    if !user.avatar_url.blank?
      image_tag(user.avatar_url, size: "#{options[:size]}", alt: user.name, class: "#{options[:class]}")
    else
      gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
      gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?d=mm&s=#{options[:size]}}"
      image_tag(gravatar_url, alt: user.name, class: "gravatar #{options[:class]}")
    end
  end
end
