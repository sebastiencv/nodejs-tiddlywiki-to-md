fs = require "fs-extra"

convert = (content) ->
  process_chunks split_in_chunks prepare_content content

prepare_content = (content) ->
  # replace all new lines in math by a space
  content = content.replace /<x-tex>([\s\S]*?)<\/x-tex>/gi, (match, p1) -> "$#{p1.replace(/\n/g, " ").replace(/\|/g, "¦").trim()}$"
  content

process_chunks = (chunks) ->
  content = ""
  for chunk in chunks
    content += switch chunk.type
      when "list"
        process_list chunk
      when "code"
        process_code chunk
      when "table"
        process_table chunk
      when "line"
        process_line chunk
  content

process_list = (chunk) ->
  list = for item in chunk.content
    spaces_before = "          ".substring(0, (item.stars.length-1) * 2)
    list_symbol = if item.stars[item.stars.length-1] is "*" then "*" else "1."
    "#{spaces_before}#{list_symbol} #{process_format item.content}"
  # join items
  "#{list.join "\n"}\n"


process_code = (chunk) ->
  "```#{chunk.language}\n#{chunk.content}```\n"

process_table = (chunk) ->
  chunk.content = for row in chunk.content
    # replace ^^| by |||
    row.replace /(\^+)\|/g, (match, p1) -> "#{p1.replace /\^/g, "|"}|"
  # ensure the second line is header description
  unless chunk.content.length > 1 and /^[\|:-\s]*$/.test chunk.content[1]
    # add a header row
    chunk.content.splice 1, 0, chunk.content[0].match(/\|/g).join("-")
  # join items
  "#{process_format chunk.content.join "\n"}\n"
  # remove ! at start of cell
  .replace(/\|\s*!+/g, "|")

process_line = (chunk) ->
  # update title
  line = chunk.content.replace /^(!*) /, (match, p1) -> "#{p1.replace /!/g, "#"} "
  # return line
  "#{process_format line}\n"

process_format = (text) ->
  # bold
  text = text.replace /''([\s\S]*?)''/gi, (match, p1) -> "**#{p1.trim()}**"
  # italic : use italic for personnal notes
  text = text.replace /::([\s\S]*?)::/gi, (match, p1) -> "*#{p1.trim()}*"
  # underscore
  text = text.replace /__([\s\S]*?)__/gi, (match, p1) -> "<u>#{p1.trim()}</u>"
  # superscript
  text = text.replace /\^\^([\s\S]*?)\^\^/gi, (match, p1) -> "<sup>#{p1.trim()}</sup>"
  text = text.replace /\(\(([\s\S]*?)\)\)/gi, (match, p1) -> "<sup>#{p1.trim()}</sup>"
  # subscript
  text = text.replace /,,([\s\S]*?),,/gi, (match, p1) -> "<sub>#{p1}</sub>"
  # image
  text = text.replace /<<img ([^>]*)>>/g, (match, p1) ->
    # find attributes
    match = p1.match /src:"([^"]*?)"/
    src = if match? then match[1] else ""
    match = p1.match /width:([^ >]*)/
    width = if match? then "width: #{parseInt match[1]}px;" else ""
    match = p1.match /align:([^ >]*)/
    align = if match? then "float: #{match[1]};" else ""
    # copy the image
    source = "data/#{src}"
    target = "data/out/#{src}"
    fs.readFile source, (err, data) ->
      unless err?
        fs.readFile target, (err, data) ->
          if err?
            fs.ensureFile target, (err) ->
              if err?
                console.error(err) if err?
              else
                fs.copy source, target, (err) -> console.error(err) if err?
    # return the image text
    "<img src=\"#{src}\" style=\"border: 0px none; margin: 0px;0px 0px 1.5em;#{width}#{align}\">"
  text

split_in_chunks = (content) ->
  # split the document in chunks
  chunks = []
  list_regex = /^([\*#]+) (.*)$/
  table_regex = /^\|.*\|\s*$/
  lines = content.split "\n"
  i = -1
  while ++i < lines.length
    line = lines[i]
    switch true
      when is_list_block
        if list_regex.test line
          # is still a lisy
          [match, stars, content] = line.match list_regex
          chunk.content.push stars: stars, content: content
        else
          # is not a list, add the stored list
          is_list_block = false
          chunks.push chunk
          chunk = null
          # re-process the line
          i--
      when is_table_block
        if /^\|.*\|\s*$/.test line
          # is still a line
          chunk.content.push line
        else
          # is not a line, add the stored table
          is_table_block = false
          chunks.push chunk
          chunk = null
          # re-process the line
          i--
      when is_code_block
        if line.substr(0, 3) is "```"
          # end of code block
          is_code_block = false
          chunks.push chunk
          chunk = null
        else
          # process the code block
          chunk.content += line + "\n"
      else
        # is not in code/table block
        switch true
          # start of a list block
          when list_regex.test line
            is_list_block = true
            # start of a code block
            [match, stars, content] = line.match list_regex
            chunk =
              type: "list"
              content: [stars: stars, content: content]
          # start of a code block
          when line.substr(0, 3) is "```"
            is_code_block = true
            # start of a code block
            chunk =
              type: "code"
              language: line.substr(3)
              content: ""
          # start of a table block
          when table_regex.test line
            is_table_block = true
            # start of a table block
            chunk =
              type: "table"
              content: [line]
          # normal line
          else
            chunks.push
              type: "line"
              content: line
  # store the last chunk if this chunk ends the file
  chunks.push chunk if chunk?
  # return chunks
  chunks


convert_ = (content) ->
  # bold
  # search for a lazy block of chars ([\s\S]*?) between '' '', but not in a code blocl `` ``
  content = content.replace /(```[^(`)]+```)|''([\s\S]*?)''/gi, (match, p1, p2) -> if p2? then "**#{p2}**" else p1
  # italic
  content = content.replace /(```[^(`)]+```)|\/\/([\s\S]*?)\/\//gi, (match, p1, p2) -> if p2? then "*#{p2}*" else p1
  # underscore
  content = content.replace /(```[^(`)]+```)|__([\s\S]*?)__/gi, (match, p1, p2) -> if p2? then "<u>#{p2}</u>" else p1
  # superscript
  content = content.replace /(```[^(`)]+```)|\^\^([\s\S]*?)\^\^/gi, (match, p1, p2) -> if p2? then "<sup>#{p2}</sup>" else p1
  content = content.replace /(```[^(`)]+```)|\(\(([\s\S]*?)\)\)/gi, (match, p1, p2) -> if p2? then "<sup>#{p2}</sup>" else p1
  # subscript
  content = content.replace /(```[^(`)]+```)|,,([\s\S]*?),,/gi, (match, p1, p2) -> if p2? then "<sub>#{p2}</sub>" else p1
  # math
  # search lazy block of chars between <x-tex> and </x-tex>
  content = content.replace /<x-tex>([\s\S]*?)<\/x-tex>/gi, (match, p1) -> "$#{p1.trim().replace /\|/g, "¦"}$"
  # remove new lines in tables
  content = content.replace /<(\/)?br>/gi, " "
  # add header separator in tables
  # search line of |...|...| between new lines (\n) and preceeded by a non table row -> return the first line of table
  content = content.replace /[^\|]\n(\|[\s\S]*?\|)\n(\|[\s\S]*?\|\n)?/gmi, (match, p1, p2) ->
    # check is not already a header separator
    console.log p1, p2
  content

exports.convert = (content) ->
  convert content
