require "jekyll"

module Jekyll
module Plugins
module IncludePage
module Tags

class IncludePageTag < Jekyll::Tags::IncludeTag

	# This uses as its basis the code of OptimizedIncludeTag which also extends IncludeTag

	def render(context)
		@site ||= context.registers[:site]

		# Get the filename from tag
		file = render_variable(context) || @file
		validate_file_name(file)

		# Create an inclusion for that filename
		@site.inclusions[file] ||= locate_include_file(context, file)
		inclusion = @site.inclusions[file]
		add_include_to_dependency(inclusion, context) if @site.config["incremental"]

		# Construct a new page so we can render it in a layout
		dir = File.join(page_path(context), File.dirname(file))
		name = File.basename(file)
		newpage = Jekyll::Page.new(@site, @site.source, dir, name)

		# Get the data from the included file
		data = newpage.read_yaml(dir, name)

		# Inject include.___ variables into the inclusion
		# Inject the page's data into the scope of the inclusion
		content_with_include_parameters = context.stack do
			context["include"] = parse_params(context) if @params
			context["page"] = data
			inclusion.render(context)
		end

		# Update the new page's content to the result of the injections
		newpage.content = content_with_include_parameters

		# Output the contents rendered into layout specified
		newpage.render(@site.layouts, @site.site_payload) # Renders into the page object's output
		newpage.output # Return that
	end

	# Overwrite tag_includes_dirs to return site source directory
	def tag_includes_dirs(context)
		site = context.registers[:site]
		Array(site.source).freeze
	end

	private

	def locate_include_file(context, file)
		# Insert this call to tag_includes_dirs overwritten by the include_relative tag
		includes_dirs = tag_includes_dirs(context)
		puts 'Using includes_dirs: ' + includes_dirs.to_s
		# Checks all includes directories until it finds a valid file
		# If in relative mode, the includes directories array will have just one entry, the current directory
		includes_dirs.each do |dir|
			path = PathManager.join(dir, file)
			return Inclusion.new(@site, dir, file) if valid_include_file?(path, dir)
		end
		raise IOError, could_not_locate_message(file, @site.includes_load_paths, @site.safe)
	end

	def valid_include_file?(path, dir)
		File.file?(path) && !outside_scope?(path, dir)
	end

	def outside_scope?(path, dir)
		@site.safe && !realpath_prefixed_with?(path, dir)
	end

	def realpath_prefixed_with?(path, dir)
		File.realpath(path).start_with?(dir)
	rescue StandardError
		false
	end

	def add_include_to_dependency(inclusion, context)
		page = context.registers[:page]
		return unless page&.key?("path")

		absolute_path = \
		if page["collection"]
			@site.in_source_dir(@site.config["collections_dir"], page["path"])
		else
			@site.in_source_dir(page["path"])
		end

		@site.regenerator.add_dependency(absolute_path, inclusion.path)
	end

end

class IncludePageRelativeTag < IncludePageTag

	# This uses as its basis IncludeRelativeTag

	def tag_includes_dirs(context)
		Array(page_path(context)).freeze
	end

	def page_path(context)
		page, site = context.registers.values_at(:page, :site)
		return site.source unless page

		site.in_source_dir File.dirname(resource_path(page, site))
	end

	private
	
	def resource_path(page, site)
		path = page["path"]
		path = File.join(site.config["collections_dir"], path) if page["collection"]
		path.delete_suffix("/#excerpt")
	end

end

end
end
end
end

Liquid::Template.register_tag('include_page', Jekyll::Plugins::IncludePage::Tags::IncludePageTag)
Liquid::Template.register_tag('include_page_relative', Jekyll::Plugins::IncludePage::Tags::IncludePageRelativeTag)