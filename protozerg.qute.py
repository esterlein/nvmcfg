config.load_autoconfig()

bg       = "#10111a"
fg       = "#aebbe2"
accent   = "#6fcde9"
danger   = "#e04949"
muted    = "#2a3145"
hover    = "#2f354d"

c.fonts.default_size = "10pt"
c.fonts.web.size.default = 16

c.content.cookies.store = True
c.content.cookies.accept = "all"
c.session.lazy_restore = True
c.session.default_name = "default"

c.content.javascript.enabled = True

c.content.headers.user_agent = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
)

c.colors.completion.fg = fg
c.colors.completion.odd.bg = bg
c.colors.completion.even.bg = "#181a22"
c.colors.completion.match.fg = accent
c.colors.completion.item.selected.bg = muted
c.colors.completion.item.selected.fg = fg
c.colors.completion.category.bg = muted
c.colors.completion.category.fg = accent

c.colors.statusbar.normal.bg = bg
c.colors.statusbar.normal.fg = fg

c.colors.tabs.bar.bg = bg
c.colors.tabs.selected.odd.bg = accent
c.colors.tabs.selected.odd.fg = bg
c.colors.tabs.odd.bg = hover
c.colors.tabs.odd.fg = fg
c.colors.tabs.even.bg = hover
c.colors.tabs.even.fg = fg
c.colors.tabs.selected.even.bg = accent
c.colors.tabs.selected.even.fg = bg

c.colors.webpage.bg = bg
c.colors.webpage.darkmode.enabled = True

c.content.blocking.method = "both"

c.zoom.default = '125%'

c.tabs.show = "never"
c.statusbar.show = "never"

c.scrolling.bar = 'never'
c.scrolling.smooth = False

c.url.start_pages = 'https://chat.openai.com'
c.url.default_page = 'https://chat.openai.com'

c.input.mouse.rocker_gestures = False



config.bind('cc', 'hint code yank')
config.bind('cp', 'hint inputs --first; mode-enter insert')
config.bind('ch', 'hint links')
config.bind('cs', 'yank selection')
config.bind('cr', 'reload')
config.bind('cn', 'open -t https://chat.openai.com/')

