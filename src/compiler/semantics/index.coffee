# The semantic analyser
#
# This unit is responsible for building a style graph from a style sheet.
# It provides a modular framework for compiler modules that can add new
# semantic functionality.
#

SS      = require "../syntax/ss_nodes"
FS      = require "./fs_nodes"

module.exports = Semantics = (ss, options) ->
  new FS.FunctionalStylesheet(ss, options)


    


  


