module ApplicationHelper
  def react_component(name, props = nil, opts = {})
    content_tag(:div, nil, data: {react_component: name, react_props: props})
  end
end
