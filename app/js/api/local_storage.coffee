## attach to Eclectus global

Cypress.LocalStorage = do (_) ->

  eclRegExp = /^ecl-/

  specialKeywords = /(debug)/


  return {
    localStorage: null
    remoteStorage: null

    # config:
      # type: "localStorage"

    # initialize: ->
    #   @canBeParent = false

    clear: (keys) ->
      throw new Error("Cypress.LocalStorage is missing local and remote storage references!") if not @localStorage or not @remoteStorage

      ## make sure we always have an array here with all falsy values removed
      keys = _.compact [].concat(keys)

      ## we have to iterate over both our remoteIframes localStorage
      ## and our window localStorage to remove items from it
      ## due to a bug in IE that does not properly propogate
      ## changes to an iframes localStorage
      _.each [@remoteStorage, @localStorage], (storage) =>

        _.chain(storage)
        .keys()
        .reject(@_isSpecialKeyword)
        .reject(@_isEclectusItem)
        .each (item) =>
          if keys.length
            @_ifItemMatchesAnyKey item, keys, (key) =>
              @_removeItem(storage, key)
          else
            @_removeItem(storage, item)

      # @emit
      #   method: "clear"
      #   message: keys.join(", ")

    setStorages: (local, remote) ->
      @localStorage = local
      @remoteStorage = remote
      @

    unsetStorages: ->
      @localStorage = @remoteStorage = null
      @

    _removeItem: (storage, item) ->
      storage.removeItem(item)

    _isSpecialKeyword: (item) ->
      specialKeywords.test item

    _isEclectusItem: (item) ->
      eclRegExp.test item

    _normalizeRegExpOrString: (key) ->
      switch
        when _.isRegExp(key) then key
        when _.isString(key) then new RegExp("^" + key + "$")

    ## if item matches by string or regex
    ## any key in our keys then callback
    _ifItemMatchesAnyKey: (item, keys, fn) ->
      for key in keys
        re = @_normalizeRegExpOrString(key)

        return fn(item) if re.test(item)
  }
