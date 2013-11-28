module ApplicationHelper

  # TODO: what is it used for ?
  def title
    "amr_recorded_performances"
  end


  #oldest possible concert year for records
  # TODO: Shouldn't be a constant in environment.rb ?
  def oldest_year
    1950
  end

  def post_to(obj, rel) # object as AR object and relationship as string and plural

    #case where collection is empty
    return 0 if obj.send(rel).count == 0

    html = form_tag send("list_#{rel}_url"), :id => ("#{rel}_for_#{obj.class.to_s.downcase}_" + obj.id.to_s)

    obj.send(rel).each do |i|
      html << hidden_field_tag('ids[]', i.id)
    end

    html << link_to_function( obj.send(rel).size,
      "document.forms['" + "#{rel}_for_#{obj.class.to_s.downcase}_" + obj.id.to_s + "'].submit();",
      :href => send("list_#{rel}_path") )

    html << "</form>".html_safe
  end

  #major code stink
  # this is only used in bands.show line 28
  def post_to_alt(obj, rel, argument_to_rel, routed_rel)
     #case where collection is empty
    return 0 if obj.send(rel, argument_to_rel).count == 0

    html = form_tag send("list_#{routed_rel}_url"), :id => ("#{routed_rel}_for_#{obj.class.to_s.downcase}_" + obj.id.to_s)

    obj.send(rel, argument_to_rel).each do |i|
      html << hidden_field_tag('ids[]', i.id)
    end

    html << link_to_function( obj.send(rel, argument_to_rel).size,
      "document.forms['" + "#{routed_rel}_for_#{obj.class.to_s.downcase}_" + obj.id.to_s + "'].submit();",
      :href => send("list_#{routed_rel}_path") )

    html << "</form>".html_safe
  end



  def order_by_form_for(attribute, order_dir = "", search_string = "")
    html = form_tag(request.request_uri, :id => ("order_by_" + attribute))
	    html << hidden_field_tag('search_string', search_string)
      html << hidden_field_tag('order_attribute', attribute)

      # invert order direction for next request
      order_dir == 'DESC' ? order_dir = 'ASC' : order_dir = 'DESC'

      html << hidden_field_tag('order_direction', order_dir)
      html << link_to_function( attribute.humanize, "document.forms['order_by_#{attribute}'].submit();", :href => request.request_uri )
		html << "</form>".html_safe
  end

  def order_by_link_to(attribute, order_dir = "", search_string = "", ids = [])
    # invert order direction for next request
    params[:order_direction] == 'DESC' ? order_dir = 'ASC' : order_dir = 'DESC'

    triangle = {}
    if params[:order_attribute] == attribute
      triangle = { :class => 'descending' } if params[:order_direction] == 'DESC'
      triangle = { :class => 'ascending' } if params[:order_direction] == 'ASC'
    end

    link_to(attribute.humanize, { :controller => controller.controller_name, :action => controller.action_name,
													:order_attribute => attribute,
													:order_direction => order_dir,
													:search_string => search_string,
													:ids => ids,
													:page => params[:page] },
                          triangle
													)
  end
end

