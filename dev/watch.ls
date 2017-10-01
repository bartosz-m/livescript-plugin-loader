require! {
    \path
    \chokidar
    \fs-extra : fs
    \livescript : livescript
}

absolute-path = -> path.normalize path.join __dirname, it

lib-path = absolute-path '../lib'
src-path = absolute-path '../src/'
watching = true

default-options =
    map: 'linked'
    bare: true
    header: false

ls-ast = (code, options = {}) ->
      ast = livescript.ast code
      {filename} = options
      output = ast.compile-root options
      output.set-file filename
      result = output.to-string-with-source-map!

to-compile = 0

compile = (filepath) !->>
    to-compile++
    relative-path = path.relative src-path, filepath
    output = path.join lib-path, (relative-path.replace '.ls', '.js')
    map-file = "#output.map"
    try
        ls-code = await fs.read-file filepath, \utf8
        options =
            filename: path.join \../src relative-path
            output-filename: relative-path.replace /.ls$/ '.js'
        console.log "compiling #relative-path"
        js-result = ls-ast ls-code, options <<< default-options
            ..source-map = ..map.to-JSON!
            ..code += "\n//# sourceMappingURL=#map-file\n"
        fs.output-file output, js-result.code
        fs.output-file map-file, JSON.stringify js-result.map.to-JSON!
    catch
        console.error e.message
    to-compile--
    if not watching
        watcher.close!


console.log \watching "#{src-path}**/*.ls"
watcher = chokidar.watch "#{src-path}**/*.ls", ignored: /(^|[\/\\])\../
.on \ready (event, filepath) ->
    console.log 'initiall scan completed'
.on \change compile
.on \add compile
.on \unlink (filepath) ->
    relative-path = path.relative src-path, filepath
    js-file = path.join lib-path, (relative-path.replace '.ls', '.js')
    map-file = js-file + \.map
    fs.remove js-file
    fs.remove map-file
