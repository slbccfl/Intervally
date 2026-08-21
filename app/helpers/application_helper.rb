module ApplicationHelper
    def inline_error_for(field, form_obj)
        html = []
        if form_obj.errors[field].any?
            html << form_obj.errors[field].map do |msg|
                tag.div(msg, class: "text-red-400 text-xs m-0 p-0 text-right mb-2")
            end
        end
        html.join.html_safe
    end

  def bg_color_for_priority(priority)
    case priority
    when 1 then "bg-red-500"
    when 2 then "bg-orange-500"
    when 3 then "bg-yellow-500"
    when 4 then "bg-blue-500"
    when 5 then "bg-green-500"
    else "bg-gray-500"
    end
  end
end
