[Livescript](https://github.com/gkz/LiveScript) Loader for Webpack with plugin support. 

I'm using it for my personal project so it is **probably** **almost** production ready - I'm talking about loader itself plugins are different story. 

# Plugins

- [transform-esm](https://www.npmjs.com/package/livescript-transform-esm)  - es modules import & export
- [transform-implicit-async](https://www.npmjs.com/package/livescript-transform-implicit-async) - automatic `async` insertion
- [transform-object-create](https://www.npmjs.com/package/livescript-transform-object-create) - `Object.create` as an implementation of clone operator `^^`


# Installation

Install loader with 

    npm install --save-dev livescript-plugin-loader


# Configuration

Add loader rule to your webpack.config.ls

```livescript
module.exports =
    module:
        rules:
          * test: /\.ls$/
            exclude: /(node_modules|bower_components)/
            use: [
              * loader: \livescript-plugin-loader
            ]
          ...  
```

## Source maps
In Firefox I advice to use
```livescript
    devtool: 'source-map'
```

and in Chrome
```livescript
   devtool: 'eval-source-map'
```

## Plugins

First install plugins that you want to use
    
    npm install --save-dev livescript-transform-top-level-await


Next add them to property `options.plugins` in loader configuration section in webpack.config.ls

```livescript
* loader: \livescript-plugin-loader
  options:
      plugins: <[
          livescript-transform-implicit-async
          livescript-transform-object-create
      ]>
```

If you want to pass some options to plugin use object instead of array
```livescript
* loader: \livescript-plugin-loader
  options:
      plugins:
          \livescript-transform-esm : format: \cjs
```
Or use objects instead of strings
```livescript
* loader: \livescript-plugin-loader
  options:
      plugins:
        * name: \livescript-transform-object-create
          options: format: \esm
        ...
```

# Atom integration

If you are using Atom editor you may be interested in my packages which provide realtime code preview. 

* [livescript-ide-preview](https://atom.io/packages/livescript-ide-preview) - show transpiled code
*  [atom-livescript-provider](https://atom.io/packages/atom-livescript-provider) - provides compilation service

Under the hood they use the very same plugins as this loader.


![](https://github.com/bartosz-m/livescript-ide-preview/raw/master/doc/assets/screenshot-01.gif)

# Implementation

This loader is small - 62 lines - and quite simple, it does only three things:
1. Creates [compiler](https://www.npmjs.com/package/livescript-compiler) instance
2. Loads plugins into compiler 
3. Executes compiler

# License

[BSD-3-Clause](License.md)
