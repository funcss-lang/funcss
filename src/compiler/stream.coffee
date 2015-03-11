N = require "./nodes"

class Stream
  constructor: (items) ->
    (@items = (t for t in items)).push new N.EOFToken
    @position = 0
  consume_next: ->
    @current = @items[@position++]
  next: ->
    @items[@position]
  reconsume_current: ->
    @items.unshift(@current)

module.exports = Stream
