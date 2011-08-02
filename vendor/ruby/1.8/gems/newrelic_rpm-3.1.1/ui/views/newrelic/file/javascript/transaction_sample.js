function show_request_params()
{
  $('#params_link').hide();
  $('#request_params').show();
}

function show_view(page_id){
  $('#show_sample_summary, #show_sample_sql, #show_sample_detail').hide();  
  $('#' + page_id).show();
} 

function toggle_row_class(theLink)
{
  var image = $('img', theLink).first();
  var visible = toggle_row_class_for_image(image);
  image.attr('src', (visible ? EXPANDED_IMAGE : COLLAPSED_IMAGE));
}

function toggle_row_class_for_image(image)
{
  var clazz = image.attr('class_for_children');
  var elements = $('#trace_detail_table').find('tr.' + clazz);
  if (elements.size() == 0) return;
  var visible = !elements.first().is(':visible');
  show_or_hide_elements(elements, visible);
  return visible;
}

function stack_trace_ids(unique_id) {
  return {'show': 'show_rails_link' + unique_id, 'hide': 'hide_rails_link' + unique_id,
          'app': 'application_stack_trace' + unique_id, 'full': 'full_stack_trace' + unique_id};
}

function show_rails(unique_id) {
  traces = stack_trace_ids(unique_id);
  $('#' + traces.full).show();
  $('#' + traces.app).hide();
  $('#' + traces.show).hide();
  $('#' + traces.hide).show();
}

function hide_rails(unique_id) {
  traces = stack_trace_ids(unique_id);
  $('#' + traces.full).hide();
  $('#' + traces.app).show();
  $('#' + traces.show).show();
  $('#' + traces.hide).hide();
}

function show_or_hide_class_elements(clazz, visible)
{
  var elements = $('#trace_detail_table').find('tr.' + clazz);
  show_or_hide_elements(elements, visible);
}

function show_or_hide_elements(elements, visible)
{
  if(visible) {
    elements.show();
  } else {
    elements.hide();
  }
}

function mouse_over_row(element)
{
  clazz = $(element).attr('child_row_class')
  $(element).css('cssText', 'background-color: lightyellow');
}

var g_style_element;
function get_cleared_highlight_styles()
{
  if (!g_style_element)
  {
    $('head', document).first().append('<style id="highlight_styles" />');
    g_style_element = $('#highlight_styles');
  }
  else {
    g_style_element.empty();
  }
  return g_style_element;
}

function mouse_out_row(element)
{
  $(element).css('cssText', '')
}

function get_parent_segments()
{
  return $('#trace_detail_table').find('img.parent_segment_image');
}

function expand_or_contract_segments(expand_or_contract) {
  var parent_segments = get_parent_segments();
  parent_segments.attr('src', (expand_or_contract ? EXPANDED_IMAGE : COLLAPSED_IMAGE))
  parent_segments.each(function (index, element) {
    show_or_hide_class_elements($(element).attr('class_for_children'), expand_or_contract);
  });
}

function expand_all_segments()
{
  expand_or_contract_segments(true);
}

function collapse_all_segments()
{
  expand_or_contract_segments(false);
}

function jump_to_metric(metric_name)
{
  highlight($('tr.' + metric_name, '#trace_detail_table'))
  expand_all_segments();
}
function highlight(elements) {
  elements.css('background-color', 'lightyellow');
}