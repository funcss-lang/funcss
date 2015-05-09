SS = require "../syntax/ss_nodes"

class Stream
  constructor: (items, @eof) ->
    (@items = (t for t in items)).push new SS.EOFToken(@eof)
    @position = 0
  consume_next: ->
    @current = @items[@position++]
  next: ->
    @items[@position]
  reconsume_current: ->
    @items.unshift(@current)

module.exports = Stream
