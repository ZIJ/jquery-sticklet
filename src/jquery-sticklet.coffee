##################################

# jQuery Sticklet plugin v2.1

# Usage: $('#selector').sticklet('above footer', 'below #sticky-header', 'topline .banner', 'bottomline article:last-child');


##################################

# Copyright (C) 2012 Igor Zalutsky

# MIT License

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##################################

# set of unique sticky blocks with independent conditions
class TargetSet
  targets: []

  # updates a registered target or registers a new one
  # element: jQ object, conditions: array of strings
  save: (element, conditions) ->
    id = element.data('stickletId')
    target = new Target(element, conditions)
    unless @targets[id]
      id = @targets.length
      element.data('stickletId', id)
      @targets.push(target)
    else
      @targets[id] = target

  positionAll: ->
    for target in @targets
      target.position()


# single sticky block
class Target
  # element: jQ object, conditions: array of restriction-describing strings
  constructor: (element, conditions) ->
    @element = element.first() or $([])
    @restrictions =
      (for condition in conditions
        new Restriction(@, condition))

  # stick element according to one of given conditions
  position: ->
    range = @getRange()
    if range.stickTo == 'top'
      @element.offset(top: range.min)
    else
      @element.offset(top: range.max)

  # calculate bounding range using all restrictions
  getRange: ->
    finalRange = new Range
    for restriction in @restrictions
      range = restriction.calculate()
      if range.stickTo == 'top'
        if range.min <= finalRange.max
          finalRange.min = Math.max(range.min, finalRange.min)
          finalRange.stickTo = 'top'
        else
          return finalRange
      else
        if range.max >= finalRange.min
          finalRange.max = Math.min(range.max, finalRange.max)
          finalRange.stickTo = 'bottom'
        else
          return finalRange
    finalRange


# single positioning rule
class Restriction
  @regex: /^(below|above|topline|bottomline)\s+(\S+)$/

  constructor: (target, condition) ->
    @target = target
    @condition = condition
    match = Restriction.regex.exec(condition)
    @position = match[1]
    @selector = match[2]
    @element = $(@selector)

  # evaluate bounding range for current restriction
  calculate: ->
    rangeMap =
      below: =>
        min: @element.offset().top + @element.height()
        stickTo: 'top'
      topLine: =>
        min: @element.offset().top
        stickTo: 'top'
      above: =>
        max: @element.offset().top - @target.element.height()
        stickTo: 'bottom'
      bottomLine: =>
        max: @element.offset().top + @element.height() - @target.element.height()
        stickTo: 'bottom'
    new Range rangeMap[@position]()


# positioning interval for a particular target and restriction
class Range
  constructor: (options) ->
    @min = (options.min if options) or -Number.MAX_VALUE
    @max = (options.max if options) or Number.MAX_VALUE
    @stickTo = (options.stickTo if options) or 'top'

targets = new TargetSet()

# plugin binding
$.fn.sticklet = ->
  conditions = arguments
  @each ->
    targets.save($(@), conditions)

# scroll binding
$(window).scroll ->
  targets.positionAll()



