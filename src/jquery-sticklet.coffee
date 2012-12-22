
# internal variables, don't change them

targets = []

limitRegex = /^(below|above|topline|bottomline)\s+(\S+)$/

win = $(window)

lastScroll = null

# plugin binding
$.fn.sticklet = ->

  limits = []
  for str in arguments
    limit = parseLimit(str)
    if limit.element.length > 0
      limits.push(limit)


  @each ->
    el = $(@)
    id = el.data('stickletId')

    # registering target element
    if not targets[id]
      id = targets.length
      el.data('sticklet-id', id)
      targets.push
        element: el,
        initialTop: Number(el.css('top'))

    # updating limits
    targets[id].limits = limits

  activate()

  # maintaining chainability
  return @

# attach handler
activate = ->
  win.on 'scroll', onScroll

# detach handler
deactivate = ->
  win.off 'scroll', onScroll

# scroll event handler that avoids unnecessary computations in case of smooth scrolling
onScroll = ->
  scroll = win.scrollTop()
  if scroll != lastScroll
    for target in targets
      position(target)
    lastScroll = scroll

# change target's offset according to limits
position = (target) ->
  conditions =
    (for limit in target.limits
      calculateLimit(target.element, limit)
    )

  bounds = intersect(conditions)
  console.log(bounds)
  applyBounds(target, bounds)

# set element's offset according to directional bounding rule
applyBounds = (target, bounds) ->
  if bounds.reverse
    target.element.offset(top: bounds.max)
  else
    target.element.offset(top: bounds.min)

# create a final directional rule from conditions according to their priority
intersect = (conditions) ->
  bounds =
    min: Number.MIN_VALUE,
    max: Number.MAX_VALUE

  for rule in conditions
    if not rule.reverse
      if rule.min <= bounds.max
        bounds.min = Math.max(bounds.min, rule.min)
        bounds.reverse = false
      else
        return bounds
    else
      if rule.max >= bounds.min
        bounds.max = Math.min(bounds.max, rule.max)
        bounds.reverse = true
      else
        return bounds
  return bounds


# convert limits to directional conditions using current element position
calculateLimit = (target, limit) ->
  limitTop = limit.element.offset().top
  limitHeight = limit.element.height()
  targetHeight = target.height()
  if limit.position == 'below'
    return {
    min: limitTop + limitHeight,
    reverse: false
    }
  if limit.position == 'topline'
    return {
    min: limitTop,
    reverse: false
    }
  if limit.position == 'above'
    return {
    max: limitTop - targetHeight
    reverse: true
    }
  if limit.position == 'bottomline'
    return {
    max: limitTop + limitHeight - targetHeight,
    reverse: true
    }

# convert string limitation to descriptor object
parseLimit = (str) ->
  # TODO add validation in parseLimit
  match = limitRegex.exec(str)
  selector = match[2]
  return {
  position: match[1]
  element: $(selector)
  }