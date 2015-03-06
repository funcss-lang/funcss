class EOFToken
  toString: ->
    ""

class Stream
  constructor: (items) ->
    (@items = (t for t in items)).push new EOFToken
    @position = -1
  consume_next: ->
    @current = @items[++@position]
  next: ->
    @items[@position+1]
  reconsume_current: ->
    @items.unshift(@current)

Stream.EOFToken = EOFToken

module.exports = Stream
