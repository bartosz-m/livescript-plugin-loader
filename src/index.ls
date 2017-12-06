require! {
    'livescript'
    'livescript/lib/lexer'
    'livescript-compiler/lib/livescript/Compiler'
    'loader-utils': LoaderUtils
}

compiler = Compiler.create livescript: livescript with {lexer}

plugins = {}
#require '@ehelon/livescript-transform-implicit-async' .install livescript

load-plugin = (plugin, options) !->
    plugin-name = plugin.name ? plugin
    plugin-options = options ? plugin.options ? {}
    unless plugins[plugin-name]
        console.log "loading plugin #{plugin-name}"
        plugins[plugin-name] = require "#{plugin-name}/lib/plugin"
            ..install compiler, plugin-options

load-plugins = (loader-options) !->
    
    if Array.is-array loader-options
        for p in loader-options[]plugins
            load-plugin p
    else if loader-options instanceof Object
        for name,options of loader-options[]plugins
            load-plugin {name,options}
    else
        console.log "loading skipping"
        

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
        map: \embedded
        const: false
        header: false

    # query = LoaderUtils.parse-query @query
    config <<< options
    result = compiler.compile source, config
    # return result.code
    if config.map == 'none'
        return result
    
    result.map.set-source-content ls-request, source
    @callback null, result.code, result.map.to-JSON!
