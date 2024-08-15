let g:user_emmet_leader_key='<C-E>'
  let g:user_emmet_settings = {
  \    'html' : {
  \        'filters' : 'html',
  \        'indentation' : ' ',
  \        'expandos' : {
  \            'ol': 'ol>li',
  \            'list': 'ul>li*3',
  \        },
  \        'default_attributes': {
  \            'a': {'href': ''},
  \            'link': [{'rel': 'stylesheet'}, {'href': ''}],
  \        },
  \        'aliases': {
  \            'bq': 'blockquote',
  \            'obj': 'object',
  \            'src': 'source',
  \        },
  \        'empty_elements': 'area,base,basefont,...,isindex,link,meta,...',
  \        'block_elements': 'address,applet,blockquote,...,li,link,map,...',
  \        'inline_elements': 'a,abbr,acronym,...',
  \        'empty_element_suffix': ' />',
  \    },
  \    'php' : {
  \        'extends' : 'html',
  \        'filters' : 'html,c',
  \    },
  \}
