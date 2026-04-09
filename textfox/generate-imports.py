#!/usr/bin/env python3
"""
Generate per-theme Stylus import JSONs by replacing the Catppuccin palette
tokens in each userstyle's LESS source with theme-specific hex values.
"""

import json, re, copy

# Catppuccin palette token names (the 26 standard colors + accent)
TOKENS = [
    'rosewater', 'flamingo', 'pink', 'mauve', 'red', 'maroon', 'peach',
    'yellow', 'green', 'teal', 'sky', 'sapphire', 'blue', 'lavender',
    'text', 'subtext1', 'subtext0',
    'overlay2', 'overlay1', 'overlay0',
    'surface2', 'surface1', 'surface0',
    'base', 'mantle', 'crust',
]

THEMES = {
    # Catppuccin Latte (light) — matches catppuccin.sh which uses Latte
    'catppuccin': {
        'dark':    False,
        'base':    '#eff1f5', 'mantle':  '#e6e9ef', 'crust':   '#dce0e8',
        'surface0':'#ccd0da', 'surface1':'#bcc0cc', 'surface2':'#acb0be',
        'overlay0':'#9ca0b0', 'overlay1':'#8c8fa1', 'overlay2':'#7c7f93',
        'subtext0':'#6c6f85', 'subtext1':'#5c5f77', 'text':    '#4c4f69',
        'rosewater':'#dc8a78','flamingo':'#dd7878', 'pink':    '#ea76cb',
        'mauve':   '#8839ef', 'red':     '#d20f39', 'maroon':  '#e64553',
        'peach':   '#fe640b', 'yellow':  '#df8e1d', 'green':   '#40a02b',
        'teal':    '#179299', 'sky':     '#04a5e5', 'sapphire':'#209fb5',
        'blue':    '#1e66f5', 'lavender':'#7287fd',
        'accent':  '#8839ef',  # mauve
    },
    # Nord — dark blue-grey
    'nord': {
        'dark':    True,
        'base':    '#2e3440', 'mantle':  '#272c36', 'crust':   '#21252d',
        'surface0':'#3b4252', 'surface1':'#434c5e', 'surface2':'#4c566a',
        'overlay0':'#4c566a', 'overlay1':'#677691', 'overlay2':'#7b8daa',
        'subtext0':'#d8dee9', 'subtext1':'#e5e9f0', 'text':    '#eceff4',
        'rosewater':'#d8dee9','flamingo':'#d08770', 'pink':    '#b48ead',
        'mauve':   '#b48ead', 'red':     '#bf616a', 'maroon':  '#bf616a',
        'peach':   '#d08770', 'yellow':  '#ebcb8b', 'green':   '#a3be8c',
        'teal':    '#8fbcbb', 'sky':     '#88c0d0', 'sapphire':'#81a1c1',
        'blue':    '#5e81ac', 'lavender':'#81a1c1',
        'accent':  '#88c0d0',  # frost-8
    },
    # Rose Pine Dawn (light) — matches rosepine.sh
    'rosepine': {
        'dark':    False,
        'base':    '#faf4ed', 'mantle':  '#f4ede8', 'crust':   '#ede6e0',
        'surface0':'#f2e9e1', 'surface1':'#dfdad9', 'surface2':'#cecacd',
        'overlay0':'#cecacd', 'overlay1':'#9893a5', 'overlay2':'#797593',
        'subtext0':'#797593', 'subtext1':'#575279', 'text':    '#575279',
        'rosewater':'#d7827a','flamingo':'#d7827a', 'pink':    '#b4637a',
        'mauve':   '#907aa9', 'red':     '#b4637a', 'maroon':  '#b4637a',
        'peach':   '#ea9d34', 'yellow':  '#ea9d34', 'green':   '#56949f',
        'teal':    '#56949f', 'sky':     '#56949f', 'sapphire':'#286983',
        'blue':    '#286983', 'lavender':'#907aa9',
        'accent':  '#286983',  # pine
    },
    # Gruvbox Dark
    'gruvbox-dark': {
        'dark':    True,
        'base':    '#282828', 'mantle':  '#1d2021', 'crust':   '#161718',
        'surface0':'#3c3836', 'surface1':'#504945', 'surface2':'#665c54',
        'overlay0':'#7c6f64', 'overlay1':'#928374', 'overlay2':'#a89984',
        'subtext0':'#a89984', 'subtext1':'#bdae93', 'text':    '#ebdbb2',
        'rosewater':'#d5c4a1','flamingo':'#d3869b', 'pink':    '#d3869b',
        'mauve':   '#b16286', 'red':     '#fb4934', 'maroon':  '#cc241d',
        'peach':   '#fe8019', 'yellow':  '#fabd2f', 'green':   '#b8bb26',
        'teal':    '#8ec07c', 'sky':     '#83a598', 'sapphire':'#458588',
        'blue':    '#458588', 'lavender':'#b16286',
        'accent':  '#d79921',  # yellow (matches gruvbox-dark.sh)
    },
    # Gruvbox Light
    'gruvbox-light': {
        'dark':    False,
        'base':    '#fbf1c7', 'mantle':  '#f9f5d7', 'crust':   '#f2eabd',
        'surface0':'#ebdbb2', 'surface1':'#d5c4a1', 'surface2':'#bdae93',
        'overlay0':'#a89984', 'overlay1':'#7c6f64', 'overlay2':'#665c54',
        'subtext0':'#504945', 'subtext1':'#3c3836', 'text':    '#3c3836',
        'rosewater':'#d5c4a1','flamingo':'#d3869b', 'pink':    '#d3869b',
        'mauve':   '#8f3f71', 'red':     '#9d0006', 'maroon':  '#cc241d',
        'peach':   '#af3a03', 'yellow':  '#b57614', 'green':   '#79740e',
        'teal':    '#427b58', 'sky':     '#076678', 'sapphire':'#458588',
        'blue':    '#458588', 'lavender':'#8f3f71',
        'accent':  '#458588',  # teal (matches gruvbox-light.sh)
    },
}


def palette_less(theme):
    """Build LESS variable definitions for the given theme palette."""
    lines = []

    # @catppuccin namespace map — some styles index into this directly via
    # @catppuccin[@@flavor][@token]. We map every standard flavor to our
    # theme colors so the lookup always resolves to the right values.
    flavor_vars = ' '.join(f'@{t}: {theme[t]};' for t in TOKENS)
    flavor_vars += f' @accent: {theme["accent"]};'
    filter_vars = ' '.join(f'@{t}: none;' for t in TOKENS) + ' @accent: none;'

    lines.append('@catppuccin: {')
    for flavor in ['latte', 'frappe', 'macchiato', 'mocha']:
        lines.append(f'  @{flavor}: {{ {flavor_vars} }};')
    lines.append('};')
    lines.append('')
    lines.append('@catppuccin-filters: {')
    for flavor in ['latte', 'frappe', 'macchiato', 'mocha']:
        lines.append(f'  @{flavor}: {{ {filter_vars} }};')
    lines.append('};')
    lines.append('')

    # Top-level palette variables for styles that reference @base, @text, etc. directly
    for token in TOKENS:
        lines.append(f'@{token}: {theme[token]};')
    lines.append(f'@accent: {theme["accent"]};')
    for token in TOKENS + ['accent']:
        lines.append(f'@{token}-filter: none;')
    lines.append('')

    # #lib mixin implementations (replaces the remote lib.less import)
    lines.append('#lib {')
    lines.append('  .rgbify(@color) {')
    lines.append('    @rgb: red(@color), green(@color), blue(@color);')
    lines.append('  }')
    lines.append('  .hslify(@color) {')
    lines.append('    @raw: e(%("%s, %s%, %s%", hue(@color), saturation(@color), lightness(@color)));')
    lines.append('  }')
    lines.append('  .css-variables() {')
    for token in TOKENS:
        lines.append(f'    --ctp-{token}: @{token};')
    lines.append('  }')
    lines.append('}')

    return '\n'.join(lines)


def defaults_less(theme):
    """Replacement for #lib.defaults() scoped inside the mixin call."""
    is_dark = theme['dark']
    scheme = 'dark' if is_dark else 'light'
    return (
        f'color-scheme: {scheme};\n'
        '  ::selection { background-color: fade(@accent, 30%); color: @text; }\n'
        '  input::placeholder, textarea::placeholder { color: @subtext0; }'
    )


def transform_source(source, theme):
    # Remove @updateURL from header so Stylus won't auto-update and overwrite
    source = re.sub(r'@updateURL[^\n]*\n', '', source)

    # Remove the Catppuccin lib import
    source = re.sub(
        r'@import\s+"https://userstyles\.catppuccin\.com/lib/lib\.less";\s*\n',
        '',
        source
    )

    # Insert our palette definitions after the UserStyle header block.
    # @var declarations are kept so @darkFlavor/@lightFlavor/@accentColor
    # remain defined (the mixin still references them as arguments).
    palette = palette_less(theme)
    source = re.sub(
        r'(==/UserStyle==\s*\*/\s*\n)',
        rf'\1\n{palette}\n\n',
        source
    )

    # Remove #lib.palette() calls (our top-level variables replace them)
    source = re.sub(r'[ \t]*#lib\.palette\(\);\n?', '', source)

    # Replace #lib.defaults() with our simplified version
    defaults = defaults_less(theme)
    source = re.sub(r'[ \t]*#lib\.defaults\(\);', defaults, source)

    return source


def make_entry(original, theme_name, theme):
    entry = copy.deepcopy(original)

    ucd = entry.get('usercssData', {})
    # Remove update URL so Stylus won't auto-update and overwrite our palette
    ucd.pop('updateUrl', None)
    ucd.pop('updateURL', None)
    entry['usercssData'] = ucd
    entry.pop('updateUrl', None)

    # Keep the original name so Stylus replaces the existing style on import
    # rather than creating a duplicate alongside it.
    entry['sourceCode'] = transform_source(entry.get('sourceCode', ''), theme)
    return entry


def main():
    with open('import.json', 'r') as f:
        data = json.load(f)

    settings = [d for d in data if 'name' not in d]
    styles   = [d for d in data if 'name' in d]

    for theme_name, theme in THEMES.items():
        result = settings + [make_entry(s, theme_name, theme) for s in styles]
        out_path = f'import-{theme_name}.json'
        with open(out_path, 'w') as f:
            json.dump(result, f, separators=(',', ':'))
        print(f'wrote {out_path}  ({len(styles)} styles)')


if __name__ == '__main__':
    main()
