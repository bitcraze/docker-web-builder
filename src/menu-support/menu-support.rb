require "liquid/variable"

module Jekyll
  class GeneratedMenuBase < Liquid::Tag
    def render_level(site, menu_tree, level, max_level, current_url)
      result = '<ul>'

      menu_tree.each do |item|
        title = 'TODO'
        url = nil

        if item.key? 'page_id'
          page = get_page(site, item['page_id'])
          title = page['title']
          url = page['url']
        end

        if item.key? 'title'
          title = item['title']
        end

        html_class = ''
        html_class = ' class="active"' if current_url == url

        if url
          result += '<li><a title="' + title + '" href="' + url + '"' + html_class + '>' + title + '</a>'
        else
          result += '<li><span>' + title + '</span>'
        end

        if item.key? 'subs'
          next_level = level + 1
          result += render_level(site, item['subs'], next_level, max_level, current_url) if next_level < max_level
        end

        result += '</li>'
      end

      result += '</ul>'
      result
    end

    def get_menu_config(site, name, key, root_url, max_level, root_style)
      menu_tree = read_config_from_file(site, name, key)
      menu_tree = build_config_from_pages(site, root_url, max_level, root_style) if not menu_tree

      menu_tree
    end

    def read_config_from_file(site, name, key)
      return nil if not name

      menu_tree = site.data[name]
      menu_tree = menu_tree[key] if key

      return menu_tree
    end

    def build_config_from_pages(site, root_url, max_level, root_style)
      # Generate a tree of all pages and populate it with the data that is available
      tree = {subs: {}, page: nil, token: 'root', title: 'root'}
      site.pages.each do |page|
        add_page_to_tree(page, tree, root_url)
      end

      # Build a menu config based on the tree
      menu_conf = []
      generate_menu_conf_from_tree(tree, menu_conf, root_style)
      menu_conf
    end

    def add_page_to_tree(page, tree, root_url)
      url = page['url']

      if url.start_with?(root_url)
        to_remove = root_url.length
        path = url[to_remove..].split('/')

        node = tree
        path.each do |token|
          if ! node[:subs].key? token
            node[:subs][token] = {subs: {}, page: nil, token: token, title: token}
          end
          node = node[:subs][token]
        end
        node[:page] = page
        node[:title] = page['title']
      end
    end

    def generate_menu_conf_from_tree(node, menu_conf, root_style)
      sub_append_point = menu_conf

      if root_style == :root_style_as_tree || root_style == :root_style_flatten
        item = {'subs' => []}
        if node[:page]
          item['page_id'] = node[:page]['page_id']
        else
          item['title'] = node[:token]
        end
        menu_conf.append item

        if root_style == :root_style_as_tree
          sub_append_point = item['subs']
        end
      end

      if node[:subs].length > 0
        node[:subs].values.sort{|a,b| a[:title].downcase <=> b[:title].downcase}.each do |sub|
          generate_menu_conf_from_tree(sub, sub_append_point, :root_style_as_tree)
        end
      end

    end

    def get_page(site, page_id)
      found = site.pages.select {|page| page['page_id'] == page_id}
      raise "There are multiple pages with page_id '" + page_id + "'" if found.length > 1
      found[0]
    end

    def parse_args(str)
      parts = str.split(';')
      parts.map {|part| part.strip}
    end

    def use_arg(variable, default_value, context)
      return variable.render(context) if variable
      return default_value
    end
  end

  # This tag is used to add a side menu to repository docs
  #
  # It generates the menu based on the files (actually URLs) in the file system and organizes the entries as a tree.
  # The title of the menu entries are based on the page titles. For sub-directories the index.md file will be used if
  # it exists, otherwise the page_id will be used as the title.
  #
  # The root level is rendered as a member of the first level of the menu to avoid always wasting one level
  #
  # This tag is a bit different from other Bitcraze tags as the parameters are fully interpreted (to support variables)
  # as opposed to other tags, where parameters are just used as is. This means that strings must be quoted.
  #
  # Usage:
  # {% side_menu 3; "/docs/" %} - this will generate a menu with 3 levels, based on the page-tree on URL "/docs/"
  #
  #
  # This tag is also compatible with a _data/menu.yml file that defines the menu. This is important when building old
  # versions of repositories for our web.
  #
  # Usage:
  # {% side_menu 3; "/docs/"; "mymenu" %} - this will generate a menu with 3 levels based on the _data/mymenu.yml file
  #
  # If more than one menu is defined in the file, the root key can be specified
  # {% side_menu 3; "/docs/"; "mymenu"; "mykey" %} - this will generate a menu with 3 levels based on the _data/mymenu.yml
  # file, for the menu defined under the "mykey" key.

  class SideMenu < GeneratedMenuBase
    def initialize(tag_name, text, tokens)
      super
      params = parse_args(text)
      @max_level = params.length > 0 ? Liquid::Variable.new(params[0], parse_context): nil
      @root_url = params.length > 1 ? Liquid::Variable.new(params[1], parse_context): nil
      @menu_def = params.length > 2 ? Liquid::Variable.new(params[2], parse_context): nil
      @menu_key = params.length > 3 ? Liquid::Variable.new(params[3], parse_context): nil
    end

    def render(context)
      max_level = use_arg(@max_level, 2, context).to_i
      root_url = use_arg(@root_url, '/', context)
      menu_def = use_arg(@menu_def, 'menu', context)
      menu_key = use_arg(@menu_key, nil, context)

      raise "root url must start and end with '/', got '" + root_url + "'" if not (root_url.start_with?('/') && root_url.end_with?('/'))

      current_url = context['page']['url']

      site = context.registers[:site]
      menu_tree = get_menu_config(site, menu_def, menu_key, root_url, max_level, :root_style_flatten)
      render_level(site, menu_tree, 0, max_level, current_url)
    end
  end


  # This tag is used to generate a menu for a sub page. Only use it in an index.md file in a directory in the doc tree,
  # it tag does not work on other pages.
  #
  # Usage:
  # {% sub_page_menu %} - this will generate a one-level menu of the sub-pages of this directory
  #
  # It is possible to specify the depth of the menu as well
  # {% sub_page_menu 2 %}
  class SubPageMenu < GeneratedMenuBase
    def initialize(tag_name, text, tokens)
      super
      params = parse_args(text)
      @max_level = params.length > 0 ? Liquid::Variable.new(params[0], parse_context): nil
    end

    def render(context)
      max_level = use_arg(@max_level, 1, context).to_i
      root_url = context['page']['url']
      menu_def = nil
      menu_key = nil

      raise "root url must start and end with '/', got '" + root_url + "'" if not (root_url.start_with?('/') && root_url.end_with?('/'))

      site = context.registers[:site]
      menu_tree = get_menu_config(site, menu_def, menu_key, root_url, max_level, :root_style_do_not_add)
      render_level(site, menu_tree, 0, max_level, root_url)
    end
  end
end

# Register the tag
Liquid::Template.register_tag('side_menu', Jekyll::SideMenu)
Liquid::Template.register_tag('sub_page_menu', Jekyll::SubPageMenu)
