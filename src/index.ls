require! {
    'livescript'
    'loader-utils': LoaderUtils
}

plugins = {}
#require '@ehelon/livescript-transform-implicit-async' .install livescript

module.exports = (source) !->
    const options = LoaderUtils.get-options @
    for p in options[]plugins
        unless plugins[p]
            plugins[p] = require "#{p}/lib/plugin"
                ..install livescript

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

    query = LoaderUtils.parse-query @query
    config <<< query

    ast = livescript.ast source
    output =  ast.compile-root config
    output.set-file filename
    result = output.to-string-with-source-map!

    if config.map == 'none'
        return result
    result.map.set-source-content ls-request, source
    @callback null, result.code, JSON.parse(result.map.to-string!)
