# jquery-sticklet

jQuery plugin for making blocks sticky with priority, like fixed menus that float upwards since certain scroll position

## usage

Just pass it a list of conditions, sorted by priority (most important first). Condition is simply alignment and selector, separated by whitespace. 

```javascript
$('#selector').sticklet('above footer', 'below #sticky-header', 'topline .banner', 'bottomline article:last-child');
```

The following alignments are supported:

* 'above' 
* 'below'
* 'topline'
* 'bottomline'
