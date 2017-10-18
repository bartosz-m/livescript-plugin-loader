Webpack loader for livescript[livescript](https://github.com/gkz/LiveScript) with support for plugins.

Converts unary clone operator ^^ to Object.create

This isn't real plugin because livescript doesn't have support for it. It's more like a hack thats is mutating AST generated by livescript.

# Plugins
- [implicit async functions](https://www.npmjs.com/package/livescript-transform-implicit-async)
- macros - for now build in to loader itself (beware WIP) info on [github ](https://github.com/gkz/LiveScript/issues/982)
- [Object.create as an implementation of clone operator **^^**](https://www.npmjs.com/package/livescript-transform-object-create)
- [top level await](https://www.npmjs.com/package/livescript-transform-top-level-await)

# Installation

Install loader with 

    npm install --save-dev livescript-plugin-loader


Optionally install some plugins
    
    npm install --save-dev livescript-transform-top-level-await

# Configuration

Add pluging to yout webpack.config.ls

```livescript
module.exports =
    module:
    rules:
      * test: /\.ls$/
        exclude: /(node_modules|bower_components)/
        use: [
          * loader: "livescript-plugin-loader"
        ]
      ...  
```

To use plugins set property `options.plugins` in loader configuration e.g.

```livescript
* loader: "livescript-plugin-loader"
  options:
      plugins: <[
          livescript-transform-implicit-async
          livescript-transform-object-create
      ]>
```

If you want to configure plugin pass object instead of array
```livescript
* loader: "livescript-plugin-loader"
  options:
      plugins:
          \livescript-transform-implicit-async : {dummy: true}
```
Or use objects instead of strings
```livescript
* loader: "livescript-plugin-loader"
  options:
      plugins:
        * name: \livescript-transform-object-create
          options: {dummy: true}
        ...
```

# License
[BSD-3-Clause](License.md)