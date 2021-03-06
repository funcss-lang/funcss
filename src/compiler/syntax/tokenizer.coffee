#
# This file is part of FuncSS Software (http://funcss.org)
#
# Copyright © 2015 Bernát Kalló
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# This implementation is based on CSS Syntax Module Level 3 Candidate
# Recommendation http://www.w3.org/TR/css-syntax-3 
#
# Copyright © 2014 W3C® (MIT, ERCIM, Keio, Beihang). This software or document
# includes material copied from or derived from CSS Syntax Module Level 3
# Candidate Recommendation http://www.w3.org/TR/css-syntax-3 . Comments that 
# start with #> are copied from the referred specification. Consult
# http://www.w3.org/Consortium/Legal/2015/doc-license for details about their 
# usage.


SS     = require "./ss_nodes"

class Tokenizer
  tokenize: (string) ->
    @init(string)
    tokens = []
    while not ((token = @consume_a_token()) instanceof SS.EOFToken)
      tokens.push token
    return tokens

  init: (string) ->
    @stream = string.split("")
    @current = undefined

  consume_next: ->
    if @stream.length
      @current = @stream.shift()
    else
      @current = "EOF"

  next: ->
    if @stream.length
      @stream[0]
    else
      "EOF"

  next2: ->
    if @stream.length > 1
      @stream[1]
    else
      "EOF"

  next3: ->
    if @stream.length > 2
      @stream[2]
    else
      "EOF"

  reconsume_current: ->
    @stream.unshift(@current)
    @current = undefined

  is_digit: (c) ->
    "0" <= c <= "9"

  is_hex_digit: (c) ->
    @is_digit(c) or "A" <= c <= "F" or "a" <= c <= "f"

  is_uppercase_letter: (c) ->
    "A" <= c <= "Z"

  is_lowercase_letter: (c) ->
    "a" <= c <= "z"

  is_letter: (c) ->
    @is_uppercase_letter(c) or @is_lowercase_letter(c)

  is_non_ASCII: (c) ->
    c.charCodeAt(0) >= 0x80

  is_name_start_code_point: (c) ->
    c isnt "EOF" and @is_letter(c) or @is_non_ASCII(c) or c is "_"

  is_name_code_point: (c) ->
    @is_name_start_code_point(c) or @is_digit(c) or c is "-"

  is_non_printable: (c) ->
    cc = c.charCodeAt(0)
    cc in [0x0..0x8] or cc is 0xB or cc in [0xe..0x1F] or cc is 0x7F

  is_newline: (c) ->
    c is "\n"

  is_whitespace: (c) ->
    @is_newline(c) or c is "\t" or c is " "

  MIN_SURROGATE_CODE_POINT = 0xD800
  MAX_SURROGATE_CODE_POINT = 0xDFFF
  is_surrogate_code_point: (c) ->
    c.charCodeAt(0) in [MIN_SURROGATE_CODE_POINT..MAX_SURROGATE_CODE_POINT]

  MAX_ALLOWED_CODE_POINT = 0x10FFFF


  consume_a_token : ->
    @consume_next()
    switch
      when @is_whitespace(@current)
        while @is_whitespace(@next())
          @consume_next()
        new SS.WhitespaceToken()

      when @current is "\""
        @consume_a_string_token("\"")

      when @current is "#"
        if @is_name_code_point(@next()) or @next_2_valid_escape()
          is_id = @next_3_starts_identifier() # FIXME needed?
          new SS.HashToken(@consume_a_name(), if is_id then "id" else undefined)
        else
          new SS.DelimToken(@current)

      when @current is "$"
        if @next() is "="
          @consume_next()
          new SS.SuffixMatchToken()
        else
          new SS.DelimToken(@current)

      when @current is "'"
        @consume_a_string_token("'")

      when @current is "("
        new SS.OpeningParenToken

      when @current is ")"
        new SS.ClosingParenToken

      when @current is "*"
        if @next() is "="
          @consume_next()
          new SS.SubstringMatchToken()
        else
          new SS.DelimToken(@current)

      when @current is "+"
        if @starts_with_number()
          @reconsume_current()
          @consume_a_numeric_token()
        else
          new SS.DelimToken(@current)

      when @current is ","
        new SS.CommaToken()

      when @current is "-"
        if @starts_with_number()
          @reconsume_current()
          @consume_a_numeric_token()
        else if @next() is "-" and @next2() is ">"
          @consume_next()
          @consume_next()
          new SS.CDCToken()
        else if @starts_with_ident()
          @reconsume_current()
          @consume_an_ident_like_token()
        else
          new SS.DelimToken(@current)

      when @current is "."
        if @starts_with_number()
          @reconsume_current()
          @consume_a_numeric_token()
        else
          new SS.DelimToken(@current)

      when @current is "/"
        if @next() is "*" # comment
          @consume_next()
          while @next() isnt "EOF" and not (@next() is "*" and @next2() is "/")
            @consume_next()
          if (@next() is "*" and @next2() is "/")
            @consume_next()
            @consume_next()
          @consume_a_token()
        else
          new SS.DelimToken(@current)

      when @current is ":"
        new SS.ColonToken()

      when @current is ";"
        new SS.SemicolonToken()

      when @current is "<"
        if @next() is "!" and @next2() is "-" and @next3() is "-"
          @consume_next()
          @consume_next()
          @consume_next()
          new SS.CDOToken()
        else
          new SS.DelimToken(@current)

      when @current is "@"
        if @next_3_starts_identifier()
          new SS.AtKeywordToken(@consume_a_name())
        else
          new SS.DelimToken(@current)

      when @current is "["
        new SS.OpeningSquareToken

      when @current is "\\"
        if @starts_with_valid_escape()
          @reconsume_current()
          @consume_an_ident_like_token()
        else
          new SS.DelimToken(@current)

      when @current is "]"
        new SS.ClosingSquareToken

      when @current is "^"
        if @next() is "="
          @consume_next()
          new SS.PrefixMatchToken()
        else
          new SS.DelimToken(@current)

      when @current is "{"
        new SS.OpeningCurlyToken

      when @current is "}"
        new SS.ClosingCurlyToken


      when "0" <= @current <= "9"
        @reconsume_current()
        @consume_a_numeric_token()

      when @is_name_start_code_point(@current)
        @reconsume_current()
        @consume_an_ident_like_token()

      when @current is "|"
        if @next() is "="
          @consume_next()
          new SS.DashMatchToken()
        else if @next() is "|"
          @consume_next()
          new SS.ColumnToken()
        else
          new SS.DelimToken(@current)

      when @current is "~"
        if @next() is "="
          @consume_next()
          new SS.IncludeMatchToken()
        else
          new SS.DelimToken(@current)

      when @current is "EOF"
        return new SS.EOFToken()

      else
        new SS.DelimToken(@current)
        
  consume_a_numeric_token: ->
    number = @consume_a_number()
    if @next_3_starts_identifier()
      new SS.DimensionToken(number.repr, number.value, number.type, @consume_a_name())
    else if @next() is "%"
      @consume_next()
      new SS.PercentageToken(number.repr, number.value)
    else
      new SS.NumberToken(number.repr, number.value, number.type)

  consume_an_ident_like_token: ->
    name = @consume_a_name()
    lowerCase = name.toLowerCase() # XXX not really what the spec says
    if lowerCase is "url" and @next() is "("
      @consume_next()
      @consume_a_url_token()
    else if @next() is "("
      @consume_next()
      new SS.FunctionToken(name)
    else
      new SS.IdentToken(name)

  consume_a_string_token: (delim) ->
    s = []
    while true
      @consume_next()
      switch
        when @current is delim or @current is "EOF"
          return new SS.StringToken(s.join(""))
        when @current is "\n"
          @reconsume_current()
          return new SS.BadStringToken
        when @current is "\\"
          if @next() is "EOF"
          else if @next() is "\n"
            @consume_next()
          else #if @starts_with_valid_escape() # it always will be true
            s.push @consume_an_escaped_code_point()
        else
          s.push @current

  consume_a_url_token: ->
    #> This algorithm assumes that the initial "url(" has already been consumed.
    s = []
    while @is_whitespace(@next())
      @consume_next()
    if @next() is "EOF"
      return new SS.UrlToken(s.join(''))
    if @next() in ["'", '"']
      @consume_next()
      SS.stringToken = @consume_a_string_token(@current)
      if SS.stringToken instanceof SS.BadStringToken
        return new SS.BadUrlToken
      while @is_whitespace(@next())
        @consume_next()
      if @next() in [")", "EOF"]
        @consume_next()
        return new SS.UrlToken(SS.stringToken.value)
      else
        @consume_the_remnants_of_a_bad_url()
        return new SS.BadUrlToken
    while true
      @consume_next()
      switch
        when @current in [")", "EOF"]
          return new SS.UrlToken(s.join(''))
        when @is_whitespace(@current)
          while @is_whitespace(@next())
            @consume_next()
          if @next() in [")", "EOF"]
            @consume_next()
            return new SS.UrlToken(s.join(''))
          else
            @consume_the_remnants_of_a_bad_url()
            return new SS.BadUrlToken
        when @current in ['"', "'", "("] or @is_non_printable(@current)
          @consume_the_remnants_of_a_bad_url()
          return new SS.BadUrlToken
        when @current is "\\"
          if @starts_with_valid_escape()
            s.push @consume_an_escaped_code_point()
          else
            @consume_the_remnants_of_a_bad_url()
            return new SS.UrlToken(s.join(''))
        else
          s.push @current

  consume_a_unicode_range_token: ->
    #> This algorithm assumes that the initial "u+" has been consumed, and the next code point verified to be a hex digit or a "?".
    throw "unicode range tokens not implemented yet"

  consume_an_escaped_code_point: ->
    #> It assumes that the U+005C REVERSE SOLIDUS (\) has already been consumed and that the next input code point has already been verified to not be a newline. 
    @consume_next()
    switch
      when @is_hex_digit(@current)
        digits = [@current]
        count = 1
        while @is_hex_digit(@next()) and count < 6
          digits.push @consume_next()
          ++count
        if @is_whitespace(@next())
          @consume_next()
        number = parseInt(digits.join(''),16)
        if number is 0 or number in [MIN_SURROGATE_CODE_POINT..MAX_SURROGATE_CODE_POINT] or number > MAX_ALLOWED_CODE_POINT
          return "\ufffd"

      when @current is "EOF"
        return "\ufffd"
      else
        return @current


  starts_with_valid_escape: ->
    @is_valid_escape(@current, @next())

  next_2_valid_escape: ->
    @is_valid_escape(@next(), @next2())

  is_valid_escape: (c1, c2) ->
    if c1 isnt "\\"
      return false
    if c2 is "\n"
      return false
    return true

  starts_with_ident: ->
    @starts_identifier(@current, @next(), @next2())
  next_3_starts_identifier: ->
    @starts_identifier(@next(), @next2(), @next3())

  starts_identifier: (c1, c2, c3) ->
    switch
      when c1 is "-"
        if @is_name_start_code_point(c2) or c2 is "-" or @is_valid_escape(c2,c3)
          return true
        else
          return false
      when @is_name_start_code_point(c1)
        return true
      when c1 is "\\"
        if @is_valid_escape(c1,c2)
          return true
        else
          return false
      else
        return false

  starts_with_number: ->
    @starts_number(@current, @next(), @next2())

  starts_number: (c1,c2,c3) ->
    switch
      when c1 in ["+", "-"]
        if @is_digit(c2)
          return true
        if c2 is "." and @is_digit(c3)
          return true
        return false
      when c1 is "."
        if @is_digit(c2)
          return true
        return false
      when @is_digit(c1)
        return true
      else
        return false

  consume_a_name: ->
    s = []
    while true
      @consume_next()
      switch
        when @is_name_code_point(@current)
          s.push @current
        when @starts_with_valid_escape()
          s.push @consume_an_escaped_code_point()
        else
          @reconsume_current()
          return s.join('')

  consume_a_number: ->
    #> This algorithm does not do the verification of the first few code points that are necessary to ensure a number can be obtained from the stream. Ensure that the stream starts with a number before calling this algorithm.
    
    repr = []
    type = "integer"
    if @next() in ["+", '-']
      repr.push @consume_next()
    while @is_digit(@next())
      repr.push @consume_next()
    if @next() is "." and @is_digit(@next2())
      repr.push @consume_next()
      repr.push @consume_next()
      type = "number"
      while @is_digit(@next())
        repr.push @consume_next()
    if @next() in ["e", "E"] and (@is_digit(@next2()) or @next2() in ['-', '+'] and @is_digit(@next3()))
      repr.push @consume_next()
      if not @is_digit(@next())
        repr.push @consume_next()
      repr.push @consume_next()
      type = "number"
      while @is_digit(@next())
        repr.push @consume_next()
    repr = repr.join('')
    value = @string_to_number(repr)
    return {repr,value,type}


  string_to_number: (s) ->
    parseFloat(s)

  consume_the_remnants_of_a_bad_url: () ->
    while true
      @consume_next()
      switch
        when @current is ")" or @current is "EOF"
          return
        when @starts_with_valid_escape()
          @consume_an_escaped_code_point()








      



        



      











      
module.exports = new Tokenizer










