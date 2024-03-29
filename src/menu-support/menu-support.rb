require "liquid/variable"

module Jekyll
  class GeneratedMenuBase < Liquid::Tag
    def render_level(site, menu_tree)
      result = ''

      menu_tree.each do |item|
        title = item['title']
        if title
          url = item['url']
          is_the_active_menu = item['is_the_active_menu']
          has_hidden_children = item['has_hidden_children']

          html_class = ''
          html_class = 'active' if item['is_the_active_menu']
          html_class += ' hidden-children' if item['has_hidden_children']
          html_class = ' class="' + html_class + '"' if html_class

          if url
            result += '<li' + html_class + '><a title="' + title + '" href="' + url + '">' + title + '</a>'
          else
            result += '<li><span>' + title + '</span>'
          end

          result += render_level(site, item['subs'])
        end

        result += '</li>'
      end

      return '<ul>' + result + '</ul>'
    end

    def get_menu_config(site, name, key, root_url, max_level, root_style)
      menu_tree = read_config_from_file(site, name, key)
      menu_tree = build_config_from_pages(site, root_url, max_level, root_style) if not menu_tree

      menu_tree
    end

    # Remove nodes that are not visible and augment the nodes with all data needed for rendering
    def prune_and_augment_tree(site, menu_tree, current_url, max_level_visible, max_level)
      augment_tree(site, menu_tree)
      mark_active_node(menu_tree, current_url, 0, max_level_visible)
      prune_tree(menu_tree, 0, max_level_visible, max_level)
    end

    def prune_tree(menu_tree, level, max_level_visible, max_level)
      menu_tree.each do |item|
        next_level = level + 1
        keep_next_level = (next_level < max_level_visible)
        if item['in_active_sub_tree']
          keep_next_level = (next_level < max_level)
        end

        if keep_next_level
          prune_tree(item['subs'], next_level, max_level_visible, max_level)
        else
          if item['subs'].length > 0 && level < max_level
            item['has_hidden_children'] = true
          end
          item['subs'] = []
        end
      end
    end

    def mark_active_node(menu_tree, current_url, level, max_level_visible)
      found_active_node = false

      menu_tree.each do |item|
        item['is_the_active_menu'] = (item['url'] == current_url)
        active_node_in_sub_tree = item['is_the_active_menu'] || mark_active_node(item['subs'], current_url, level + 1, max_level_visible)

        if level == (max_level_visible - 1) && active_node_in_sub_tree
          mark_sub_tree_as_visible(item['subs'])
          item['in_active_sub_tree'] = true
        end

        found_active_node ||= active_node_in_sub_tree
      end

      found_active_node
    end

    def mark_sub_tree_as_visible(menu_tree)
      menu_tree.each do |item|
        item['in_active_sub_tree'] = true
        mark_sub_tree_as_visible(item['subs'])
      end
    end

    def augment_tree(site, menu_tree)
      menu_tree.each do |item|
        title = nil
        url = nil

        if item.key? 'page_id'
          page = get_page(site, item['page_id'])
          if page
            title = page['title']
            url = page['url']
          end
        end

        if item.key? 'title'
          title = item['title']
        end

        if title
          if item.key? 'subs'
            augment_tree(site, item['subs'])
          else
            item['subs'] = []
          end

          item['title'] = title
          item['url'] = url
          item['is_the_active_menu'] = false
          item['in_active_sub_tree'] = false
          item['has_hidden_children'] = false
        end
      end
    end

    def read_config_from_file(site, name, key)
      return nil if not name

      # Read the config. This can be either an Array, if there is a meny.yml file, or a Hash if we are building the web
      # and have generated a file with all repo menus combined.
      menu_tree = site.data[name]
      if ! menu_tree
        return nil
      end

      if key
        if menu_tree.class == Hash
          return menu_tree[key]
        end

        return nil
      end

      return menu_tree
    end

    def build_config_from_pages(site, root_url, max_level, root_style)
      # Generate a tree of all pages and populate it with the data that is available
      tree = {subs: {}, page: nil, token: 'root', title: 'root', sort_order: nil}
      site.pages.each do |page|
        add_page_to_tree(page, tree, root_url)
      end

      # Build a menu config based on the tree
      menu_conf = []
      generate_menu_conf_from_tree(tree, menu_conf, root_style)
      menu_conf
    end

    def add_page_to_tree(page, tree, root_url)
      # Skip pages without a title, these are generated redirect pages
      title = page['title']
      if title
        url = page['url']

        if url.start_with?(root_url)
          to_remove = root_url.length
          path = url[to_remove..].split('/')

          node = tree
          path.each do |token|
            if ! node[:subs].key? token
              node[:subs][token] = {subs: {}, page: nil, token: token, title: token, sort_order: nil}
            end
            node = node[:subs][token]
          end
          node[:page] = page
          node[:title] = title
          node[:sort_order] = page['sort_order']
        end
      end
    end

    def sorter(a, b)
      if a[:sort_order].class == b[:sort_order].class
        sort_order_cmp = a[:sort_order] <=> b[:sort_order]
        return sort_order_cmp if sort_order_cmp != 0
        return a[:title].downcase <=> b[:title].downcase
      end

      return 1 if a[:sort_order] == nil
      return -1 if b[:sort_order] == nil

      raise "Sort order types are different, can not compare" if a[:sort_order].class != b[:sort_order].class
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
        node[:subs].values.sort{|a, b| sorter(a, b)}.each do |sub|
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
  # {% side_menu 3; 2; "/docs/" %} - this will generate a menu with 3 levels, 2 visible by default, based on the page-tree on URL "/docs/"
  #
  #
  # This tag is also compatible with a _data/menu.yml file that defines the menu. This is important when building old
  # versions of repositories for our web.
  #
  # Usage:
  # {% side_menu 3; 2; "/docs/"; "mymenu" %} - this will generate a menu with 3 levels, 2 visible by default, based on the _data/mymenu.yml file
  #
  # If more than one menu is defined in the file, the root key can be specified
  # {% side_menu 3; 2; "/docs/"; "mymenu"; "mykey" %} - this will generate a menu with 3 levels, 2 visible by default, based on the _data/mymenu.yml
  # file, for the menu defined under the "mykey" key.

  class SideMenu < GeneratedMenuBase
    def initialize(tag_name, text, tokens)
      super
      params = parse_args(text)
      @max_level = params.length > 0 ? Liquid::Variable.new(params[0], parse_context): nil
      @max_level_visible = params.length > 1 ? Liquid::Variable.new(params[1], parse_context): nil
      @root_url = params.length > 2 ? Liquid::Variable.new(params[2], parse_context): nil
      @menu_def = params.length > 3 ? Liquid::Variable.new(params[3], parse_context): nil
      @menu_key = params.length > 4 ? Liquid::Variable.new(params[4], parse_context): nil
    end

    def render(context)
      max_level = use_arg(@max_level, 2, context).to_i
      max_level_visible = use_arg(@max_level_visible, max_level, context).to_i
      root_url = use_arg(@root_url, '/', context)
      menu_def = use_arg(@menu_def, 'menu', context)
      menu_key = use_arg(@menu_key, nil, context)

      raise "root url must start and end with '/', got '" + root_url + "'" if not (root_url.start_with?('/') && root_url.end_with?('/'))

      current_url = context['page']['url']

      site = context.registers[:site]
      menu_tree = get_menu_config(site, menu_def, menu_key, root_url, max_level, :root_style_flatten)
      prune_and_augment_tree(site, menu_tree, current_url, max_level_visible, max_level)
      render_level(site, menu_tree)
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
      prune_and_augment_tree(site, menu_tree, root_url, max_level, max_level)
      render_level(site, menu_tree)
    end
  end
end

# Register the tag
Liquid::Template.register_tag('side_menu', Jekyll::SideMenu)
Liquid::Template.register_tag('sub_page_menu', Jekyll::SubPageMenu)
