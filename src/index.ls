require! {
    'livescript'
    'livescript/lib/lexer'
    'livescript-compiler/lib/livescript/Compiler'
    'loader-utils': LoaderUtils
}

compiler = Compiler.create livescript: livescript with {lexer}

plugins = {}

load-plugin = (plugin, options) !->
    try
        plugin-name = plugin.name ? plugin
        plugin-options = options ? plugin.options ? {}
        unless plugins[plugin-name]
            console.log "loading plugin #{plugin-name}"
            unless plugin.install
                plugin = plugins[plugin-name] = require "#{plugin-name}/lib/plugin"
            plugin.install compiler, plugin-options
    catch
        console.log "Error loading plugin #{plugin-name}\n", e.stack

load-plugins = (plugins) !->    
    if Array.is-array plugins
        for p in plugins
            load-plugin p
    else if plugins instanceof Object
        for name, options of plugins
            load-plugin {name,options}
    else
        console.log "Incorrect plugin config"
        

module.exports = (source) !->
    const options = LoaderUtils.get-options @
    load-plugins options.plugins

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

    config <<< options
    result = compiler.compile source, config
    if config.map == 'none'
        return result
    
    result.map.set-source-content ls-request, source
    @callback null, result.code, result.map.to-JSON!
