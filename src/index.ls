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
            plugins[p] = require "#{p}/plugin"
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

    # result = livescript.compile source, config
    if config.map == 'none'
        return result
    result.map.set-source-content ls-request, source
    # result.code += "\n//# sourceMappingURL=data:application/json;base64,#{ new Buffer result.map.to-string! .to-string 'base64' }\n"
    # result.map._file = ls-request # Monkeypatch filename in sourcemap
    # @callback null, result.code, JSON.parse(result.map.to-string!)
    @callback null, result.code, JSON.parse(result.map.to-string!)
