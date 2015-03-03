
class Stream
  init: (tokens) ->
    @stream = (t for t in tokens)
    @current = undefined

  consume_next: ->
    if @stream.length
      @current = @stream.shift()
    else
      @current = new EOFToken

  next: ->
    if @stream.length
      @stream[0]
    else
      new EOFToken

  reconsume_current: ->
    @stream.unshift(@current)

module.exports = Stream
