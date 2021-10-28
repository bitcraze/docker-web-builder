module Jekyll

  class IncludeRelativeGenerated < Tags::IncludeRelativeTag
    def render(context)
      begin
        super
      rescue IOError => e
        info = "File " + @file + " not found"
        if @params
          params = parse_params(context)
          info = params["info"]
        end

        "---\n" + info + "\n\n---"
      end
    end
  end
end

# Register the tag
Liquid::Template.register_tag('include_relative_generated', Jekyll::IncludeRelativeGenerated)
