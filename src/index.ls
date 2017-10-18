require! {
    'livescript'
    'livescript/lib/MacroCompiler'
    'loader-utils': LoaderUtils
}

plugins = {}
#require '@ehelon/livescript-transform-implicit-async' .install livescript

load-plugin = (plugin, options) !->
    plugin-name = plugin.name ? plugin
    plugin-options = options ? plugin.options ? {}
    unless plugins[plugin-name]
        plugins[plugin-name] = require "#{plugin-name}/lib/plugin"
            ..install livescript, plugin-options

load-plugins = (loader-options) !->
    if Array.is-array loader-options
        for p in loader-options[]plugins
            load-plugin p
    else if loader-options instanceof Object
        for name,options in loader-options[]plugins
            load-plugin {name,options}
        

module.exports = (source) !->
    const options = LoaderUtils.get-options @
    load-plugins options

    @cacheable?!

    const webpackRemainingChain =
        LoaderUtils
        .getRemainingRequest @
        .split "!"
    const filename = webpackRemainingChain[webpackRemainingChain.length - 1]
    ls-request = filename
    js-request = LoaderUtils.get-current-request this

    config =
        filename: ls-request
        output-filename: js-request
        map: \linked
        bare: true
        const: false
        header: false

    # query = LoaderUtils.parse-query @query
    config <<< options
    result = 
        if options?macros == true
            compiler = new MacroCompiler
            compiler.compile-code source, config
        else
            ast = livescript.ast source
            output = ast.compile-root config
            output.set-file filename
            output.to-string-with-source-map!

    if config.map == 'none'
        return result
    result.map.set-source-content ls-request, source
    @callback null, result.code, JSON.parse(result.map.to-string!)
