convert = (content) ->
  # bold
  content = content.replace /''([^']*)''/g, (match, p1) -> "**#{p1}**"
  content

exports.convert = (content) ->
  convert content
