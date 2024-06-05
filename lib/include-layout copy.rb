require "jekyll"

module Jekyll
module Plugins
module IncludeLayout
module Tags

	class IncludeWithLayoutTag < Liquid::Tag
	
		
		
	end

end
end
end
end

Liquid::Template.register_tag('include_with_layout', Jekyll::Plugins::IncludeLayout::Tags::IncludeWithLayoutTag)