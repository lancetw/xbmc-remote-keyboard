fs      = require 'fs'
program = require 'commander'

class Program
  constructor: (@options = {}) ->
    @options.name ?= 'xbmc-remote-keyboard'
    do @initCommander
    return @

  initCommander: =>
    program.name = @options.name
    program
      .version(do Program.getVersion)
      .usage('[options] hostname/ip[:port]')
      .option('-v, --verbose', 'verbose')

  parseOptions: =>
    program.parse process.argv
    @options extends program
    [@options.host, @options.port] = @options.args[0].split ':'
    @options.host ?= '127.0.0.1'
    @options.port = parseInt(@options.port) || 9090
    console.log @options.args

  initXbmc: (fn = null) =>
    {TCPConnection, XbmcApi} = require 'xbmc'
    @xbmcConnection = new TCPConnection
      host:       @options.host
      port:       @options.port
      verbose:    @options.verbose
    @xbmcApi = new XbmcApi
      connection: @xbmcConnection
      verbose:    @options.verbose
      agent:      'Remote Keyboard'
    @xbmcApi.on 'connection:open', ->
      fn false if fn
    @xbmcApi.on 'connection:error', ->
      fn true if fn

  initNcurses: (fn = null) =>
    
    do @xbmcApi.input.right
    fn false if fn

  run: =>
    do @parseOptions
    @initXbmc (err) =>
      do @initNcurses

  @getVersion: -> JSON.parse(fs.readFileSync "#{__dirname}/../package.json", 'utf8').version

  @create: (options = {}) -> new Program options

  @run: -> do (do Program.create).run

module.exports =
  Program:    Program
  run:        Program.run
  create:     Program.create
  getVersion: Program.getVersion