module Jekyll

  class GeneratedMenuBase < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @params = parse_args(text)
    end

    def render_level(site, menu_tree, level, max_level)
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

        if url
          result += '<li><a title="' + title + '" href="' + url + '">' + title + '</a></li>'
        else
          result += '<li>' + title + '</li>'
        end

        if item.key? 'subs'
          next_level = level + 1
          result += render_level(site, item['subs'], next_level, max_level) if next_level < max_level
        end

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
      # Generate a tree of all pages and populate with the data that is available
      tree = {subs: {}, page: nil, token: 'root'}
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
            node[:subs][token] = {subs: {}, page: nil, token: token}
          end
          node = node[:subs][token]
        end
        node[:page] = page
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
        node[:subs].values.each do |sub|
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

    def use_arg(args, index, default_value)
      return args[index] if args.length > index
      return default_value
    end
  end

  class SideMenu < GeneratedMenuBase
    def render(context)
      max_level = use_arg(@params, 0, 2).to_i
      root_url = use_arg(@params, 1, '/')
      menu_def = use_arg(@params, 2, 'menu')
      menu_key = use_arg(@params, 3, nil)

      raise "root url must start and end with '/'" if not (root_url.start_with?('/') && root_url.end_with?('/'))

      site = context.registers[:site]
      menu_tree = get_menu_config(site, menu_def, menu_key, root_url, max_level, :root_style_flatten)
      render_level(site, menu_tree, 0, max_level)
    end
  end

  class SubPageMenu < GeneratedMenuBase
    def render(context)
      max_level = use_arg(@params, 0, 1).to_i
      root_url = context['page']['url']
      menu_def = nil
      menu_key = nil

      raise "root url must start and end with '/'" if not (root_url.start_with?('/') && root_url.end_with?('/'))

      site = context.registers[:site]
      menu_tree = get_menu_config(site, menu_def, menu_key, root_url, max_level, :root_style_do_not_add)
      render_level(site, menu_tree, 0, max_level)
    end
  end
end

# Register the tag
Liquid::Template.register_tag('side_menu', Jekyll::SideMenu)
Liquid::Template.register_tag('sub_page_menu', Jekyll::SubPageMenu)
