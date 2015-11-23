data_in = "data/in"
data_out = "data/out"

fs = require "fs-extra"
path = require "path"
walk = require "walk"
util = require "util"

tiddly_to_md = require "./tiddly_to_md"

fs.emptyDir data_out, (err) ->
  if err?
    console.log "Error emptyDir #{data_out} : #{err}"
  else
    # search all files in input folder
    walker = walk.walk data_in, { followLinks: false }
    walker.on "file", (root, fileStat, next) ->
      if fileStat.name.charAt(0) is "."
        next()
      else
        source_file = path.resolve(root, fileStat.name)
        fs.readFile source_file, (err, buffer) ->
          if err?
            console.log "Error reading #{source_file} : #{err}"
          else
            target_file = "#{data_out}/#{decodeURIComponent(fileStat.name).replace /\//g, "_"}.md"
            content = tiddly_to_md.convert buffer.toString()
            fs.writeFile target_file, content, (err) ->
              if err?
                console.log "Error saving #{target_file} : #{err}"
              next()
