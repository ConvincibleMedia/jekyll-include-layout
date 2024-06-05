require "jekyll"

module Jekyll
module Plugins
module IncludePage
module Tags

	class IncludePageTag < Jekyll::Tags::IncludeRelativeTag

		# The relative tag simply overwrites what the non-relative tag thinks of as the includes directory

		def render(context)
			@site ||= context.registers[:site]

			file = render_variable(context) || @file
			validate_file_name(file)

			@site.inclusions[file] ||= locate_include_file(file)
			inclusion = @site.inclusions[file]

			add_include_to_dependency(inclusion, context) if @site.config["incremental"]

			context.stack do
			context["include"] = parse_params(context) if @params
			inclusion.render(context)

			# Get file to be included
			#file = render_variable(context) || @file
        	#validate_file_name(file)

			#Jekyll::Convertible::read_yaml(raw)
		end

		private

		def locate_include_file(file)
			@site.includes_load_paths.each do |dir|
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

end
end
end
end

Liquid::Template.register_tag('include_page', Jekyll::Plugins::IncludePage::Tags::IncludPageTag)