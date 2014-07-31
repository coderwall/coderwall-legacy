window.Coderwall ?= {}
window.Coderwall.Autosaver ?= {}

class window.Coderwall.Autosaver.TextField

  constructor: (options={}) ->
    return unless @supportsStorage()

    @autosave_field = $("##{options.field_id}")
    @save_delay     = options.save_delay ? 3000
    @storage_key    = options.storage_key ? "coderwall:autosaver:textfield:#{@autosave_field}"
    @key_append     = options.storage_key_append
    @storage_key    = "#{@storage_key}:#{@key_append}" if @key_append?
    @initialize()
    return


  initialize: ()->
    @populateOnInit()
    @setupHandlers()
    return


  populateOnInit: ()->
    if @fieldIsEmpty()
      # attempt to populate from localstorage
      data = @getStorage()
      @autosave_field.val data if data?  
    else
      # prefill localstorage with content from field
      @store @fieldValue()
    return


  setupHandlers: () ->
    @autosave_field.on "keyup", (e)=>
      unless @save_timeout?
        @save_timeout = setTimeout @saveTimeoutHandler, @save_delay
    return


  supportsStorage: ()->
    window.localStorage?


  store: (value)->
    localStorage.setItem @storageKey(), JSON.stringify(value)
    return


  getStorage: ()->
    JSON.parse localStorage.getItem(@storageKey())


  storageKey: ()->
    @storage_key


  saveTimeoutHandler: ()=>
    @store @fieldValue()
    delete @save_timeout

  clear: ()->
    clearTimeout(@save_timeout)
    delete localStorage[@storageKey()]

  fieldIsEmpty: ()->
    @fieldValue() == ""

  fieldValue: ()->
    @autosave_field.val()
