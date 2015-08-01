def status_as_class(description)
  case description.downcase
  when 'good service' then 'online'
  when 'delays' then 'delays'
  when 'service change' then 'delays'
  when 'planned work' then 'delays'
  when 'suspended' then 'delays'
  else 'offline'
  end
end

def line_status(line, in_lines, feed)
  line_status = feed
    .css("line:contains(#{in_lines})")
    .find {|line| line.css('name').text.chomp == in_lines}
  status = line_status.css('status').text.chomp
  {name: line, status: status_as_class(status)}
end
