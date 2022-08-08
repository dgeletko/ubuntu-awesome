--[[
     _            _      _   _         
  __| | __ _  ___| | ___| |_| | _____  
 / _` |/ _` |/ _ \ |/ _ \ __| |/ / _ \ 
| (_| | (_| |  __/ |  __/ |_|   < (_) |
 \__,_|\__, |\___|_|\___|\__|_|\_\___/ 
       |___/                           
--]]

-- ensure packages installed via luarocks are found
pcall(require, "luarocks.loader")

-- standard awesome libraries
local gears = require("gears") -- general utilities
local awful = require("awful") -- window management
local wibox = require("wibox") -- widget framework
local beautiful = require("beautiful") -- theming
local naughty = require("naughty") -- notifications
local menubar = require("menubar") -- xdg menu

local hotkeys_popup = require("awful.hotkeys_popup") -- awesome hotkeys help menu
require("awful.hotkeys_popup.keys") -- hotkeys help for other open applications
require("awful.autofocus") -- ensure there is always a client with focus

-- third-party libraries
local has_fdo, freedesktop = pcall(require, "freedesktop") -- freedesktop menu and desktop icon support (https://github.com/lcpz/awesome-freedesktop)
local vicious = require("vicious") -- widget library (https://github.com/vicious-widgets/vicious)
--local obvious = require("obvious") -- widget library (https://github.com/hoelzro/obvious)
--local apt = require("apt")

--------------------------------------------------
-- error handling
--------------------------------------------------

-- startup errors
-- TODO: naughty.notify deprecated... use notification objects instead
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "startup errors",
                     text = awesome.startup_errors })
end

-- runtime errors
-- TODO: naughty.notify deprecated... use notification objects instead
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "runtime error",
                         text = tostring(err) })
        in_error = false
    end)
end

--------------------------------------------------
-- theme
--------------------------------------------------

beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
beautiful.icon_theme = "Papirus-Dark"
beautiful.font = "Fira Code Bold 9"
beautiful.useless_gap = 4
beautiful.gap_single_client = false
--beautiful.tasklist_plain_task_name = true
beautiful.tasklist_disable_task_name = true

--------------------------------------------------
-- apps
--------------------------------------------------

local terminal = "x-terminal-emulator"
local editor = os.getenv("EDITOR") or "vim"

local config = {
    sloppy_focus = false,
    titlebars = false,
}

--------------------------------------------------
-- layouts
--------------------------------------------------

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}

--------------------------------------------------
-- menu
--------------------------------------------------

menubar.utils.terminal = terminal -- set terminal for applications that require it

local mainmenu = {}

local submenus = {
    awesome = {
        "awesome", {
            { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
            { "manual", terminal .. " -e man awesome" },
            { "restart", awesome.restart },
            { "quit", function() awesome.quit() end },
        }, beautiful.awesome_icon
    },

    quit = {
        "quit",
        {
            { "lock", terminal .. " -e light-locker-command --lock", menubar.utils.lookup_icon("system-lock-screen") },
            { "logout", function() awesome.quit() end, menubar.utils.lookup_icon("system-log-out") },
            { "reboot", terminal .. " -e systemctl reboot", menubar.utils.lookup_icon("system-reboot") },
            { "shutdown", terminal .. " -e systemctl poweroff", menubar.utils.lookup_icon("system-shutdown") },
        }, menubar.utils.lookup_icon("system-shutdown")
    },
}

if has_fdo then
    mainmenu = freedesktop.menu.build({
        before = {
            submenus.awesome,
        },
        after = {
            { "terminal", terminal, menubar.utils.lookup_icon("terminal") },
            submenus.quit,
        }
    })
else
    mainmenu = awful.menu({ items = submenus })
end

--------------------------------------------------
-- widgets
--------------------------------------------------

-- common widgets (shared across screens)
local widgets = {
    separator = wibox.widget.separator({ orientation = "vertical", forced_width = 2, thickness = 2, color = "#81a1c1" }),
    launcher = awful.widget.launcher({ menu = mainmenu, image = gears.filesystem.get_configuration_dir() .. "icons/start-here.svg" }),
    clock = wibox.widget.textclock("%a %b %d, %H:%M"),
    calendar = awful.widget.calendar_popup.month(),
    --updates = wibox.widget.textbox(),
    updates = awful.widget.watch("apt list --upgradable", 15, function(widget, stdout)
        widget:set_text(" " .. gears.string.linecount(stdout) - 2)
    end),
    kernel = wibox.widget.textbox(),
    host = wibox.widget.textbox(),
    cpu = wibox.widget.textbox(),
    mem = wibox.widget.textbox(),
    net = wibox.widget.textbox(),
    battery = wibox.widget.textbox(),
    disk = wibox.widget.textbox(),
    tray = wibox.widget.systray(),
}

-- configure common widgets
widgets.calendar:attach(widgets.clock, "tr", { on_hover = false })
--vicious.register(widgets.updates, vicious.widgets.pkg, " $1", 2, "Ubuntu")
--vicious.register(widgets.updates, apt, " $1", 30)
--vicious.register(widgets.kernel, vicious.widgets.os, " $2", 60)
vicious.register(widgets.kernel, vicious.widgets.os,
    function (widget, args)
        return " " .. args[2]:gsub("-generic", "")
    end, 60)
vicious.register(widgets.host, vicious.widgets.os, " $4", 60)
vicious.register(widgets.cpu, vicious.widgets.cpu, " $1%")
vicious.register(widgets.mem, vicious.widgets.mem, " $1%")
vicious.register(widgets.net, vicious.widgets.wifi, " ${ssid}", 15, "wlo1")
vicious.register(widgets.battery, vicious.widgets.bat, " $2% $1", 15, "BAT0")
vicious.register(widgets.disk, vicious.widgets.fs, " / ${/ used_p}%, /home ${/home used_p}%", 10)
--fshomewidget = wibox.widget.textbox()
--vicious.register(fshomewidget, vicious.widgets.fs, " /home ${/home used_p}%", 20)

--------------------------------------------------
-- key bindings
--------------------------------------------------

local modkey = "Mod4" -- windows key

-- global keybindings
local globalkeys = gears.table.join(
    -- awesome
    awful.key({modkey}, "s", hotkeys_popup.show_help, {description="show help", group="awesome"}),
    awful.key({modkey}, "w", function() mymainmenu:show() end, {description = "show main menu", group = "awesome"}),
    awful.key({modkey, "Control"}, "r", awesome.restart, {description="reload awesome", group="awesome"}),
    awful.key({modkey, "Shift"}, "q", awesome.quit, {description="quit awesome", group="awesome"}),
    awful.key({modkey}, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                 history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end, {description="lua execute prompt", group="awesome"}),

    -- tag
    awful.key({modkey}, "Left", awful.tag.viewprev, {description="view prev", group="tag"}),
    awful.key({modkey}, "Right", awful.tag.viewnext, {description="view next", group="tag"}),
    awful.key({modkey}, "Escape", awful.tag.history.restore, {description="go back", group="tag"}),

    -- client
    awful.key({modkey}, "u", awful.client.urgent.jumpto, {description="jump to urgent client", group="client"}),
    awful.key({modkey}, "j", function() awful.client.focus.byidx( 1) end, {description="focus next by index", group="client"}),
    awful.key({modkey}, "k", function() awful.client.focus.byidx(-1) end, {description="focus prev by index", group="client"}),
    awful.key({modkey, "Shift"}, "j", function() awful.client.swap.byidx( 1) end, {description="swap with next client by index", group="client"}),
    awful.key({modkey, "Shift"}, "k", function() awful.client.swap.byidx(-1) end, {description="swap with prev client by index", group="client"}),
    awful.key({modkey}, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, {description="go back", group="client"}),
    awful.key({modkey, "Control"}, "n",
        function ()
            local c = awful.client.restore()
            if c then
                c:emit_signal("request::activate", "key.unminimize", {raise=true})
            end
        end, {description="restore minimized", group="client"}),

    -- screen
    awful.key({modkey, "Control"}, "j", function() awful.screen.focus_relative( 1) end, {description="focus next screen", group="screen"}),
    awful.key({modkey, "Control"}, "k", function() awful.screen.focus_relative(-1) end, {description="focus prev screen", group="screen"}),

    -- layout
    awful.key({modkey}, "l", function() awful.tag.incmwfact( 0.05) end, {description="increase master width factor", group="layout"}),
    awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end, {description="decrease master width factor", group="layout"}),
    awful.key({modkey, "Shift"}, "h", function() awful.tag.incnmaster( 1, nil, true) end, {description="increase num master clients", group="layout"}),
    awful.key({modkey, "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end, {description="decrease num master clients", group="layout"}),
    awful.key({modkey, "Control"}, "h", function() awful.tag.incncol( 1, nil, true) end, {description="increase num columns", group="layout"}),
    awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end, {description="decrease num columns", group="layout"}),
    awful.key({modkey         }, "space", function() awful.layout.inc( 1) end, {description="select next", group="layout"}),
    awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(-1) end, {description="select prev", group="layout"}),

    -- launchers
    awful.key({modkey}, "r", function() awful.spawn("rofi -modi drun -show drun -show-icons -icon-theme " .. beautiful.icon_theme) end,
              {description="run prompt", group="launcher"}),
    awful.key({modkey}, "p", function() menubar.show() end, {description="show menubar", group="launcher"}),
    awful.key({modkey}, "Return", function() awful.spawn(terminal) end, {description="open terminal", group="launcher"}),
    awful.key({modkey}, "b", function() awful.spawn("x-www-browser") end, {description="open web browser", group="launcher"}),
    awful.key({modkey}, "e", function() awful.spawn("pcmanfm") end, {description="open file manager", group="launcher"}),
    awful.key({modkey}, "v", function() awful.spawn("virtualbox -style fusion") end, {description="open virtualbox", group="launcher"}),

    -- media
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("amixer -q -D pulse sset Master 5%-", false) end,
              {description="decrease volume (5%)", group="media"}),
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("amixer -q -D pulse sset Master 5%+", false) end,
              {description="increase volume (5%)", group="media"}),
    awful.key({}, "XF86AudioMute", function() awful.spawn("amixer -q -D pulse set Master toggle", false) end,
              {description="mute/unmute", group="media"}),
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause", false) end,
              {description="play/pause", group="media"}),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next", false) end,
              {description="next track", group="media"}),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous", false) end,
              {description="prev track", group="media"}),

    -- quit
    --awful.key({modkey}, "x", function() awful.spawn.with_shell(terminal .. " -e light-locker-command --lock") end, {description="lock", group="quit"}),
    awful.key({modkey, "Control"}, "x", function() awful.spawn.with_shell("systemctl poweroff") end, {description="poweroff", group="quit"})
)

for i = 1, 9 do
    -- tags - bind number keys to tags (keycodes used to work on any keyboard layout)
    globalkeys = gears.table.join(globalkeys,
        awful.key({modkey}, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end, {description="view tag #".. i, group="tag"}),

        awful.key({modkey, "Control"}, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end, {description="toggle tag #" .. i, group="tag"}),

        awful.key({modkey, "Shift"}, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end, {description="move focused client to tag #".. i, group="tag"}),

        awful.key({modkey, "Control", "Shift"}, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end, {description="toggle focused client on tag #" .. i, group="tag"})
    )
end

-- client keybindings
local clientkeys = gears.table.join(
    awful.key({modkey}, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, {description="toggle fullscreen", group="client"}),
    awful.key({modkey, "Shift"}, "c", function(c) c:kill() end, {description="close", group="client"}),
    awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {description="toggle floating", group="client"}),
    awful.key({modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end, {description="move to master", group="client"}),
    awful.key({modkey}, "o", function(c) c:move_to_screen() end, {description="move to screen", group="client"}),
    awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end, {description="toggle keep on top", group="client"}),
    awful.key({modkey}, "n", function(c) c.minimized = true end, {description="minimize", group="client"}),
    awful.key({modkey}, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end, {description="(un)maximize", group="client"}),
    awful.key({modkey, "Control"}, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {description="(un)maximize vertical", group="client"}),
    awful.key({modkey, "Shift"}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {description="(un)maximize horizontal", group="client"})
)

root.keys(globalkeys)

--------------------------------------------------
-- mouse bindings
--------------------------------------------------

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end)
    -- dgeletko disable tag navigation via mouse scroll
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise=true})
    end),
    awful.button({modkey}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise=true})
        awful.mouse.client.move(c)
    end),
    awful.button({modkey}, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise=true})
        awful.mouse.client.resize(c)
    end)
)

--------------------------------------------------
-- screens
--------------------------------------------------

-- set wallpaper from theme
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- per screen setup
awful.screen.connect_for_each_screen(function(s)
    -- wallpaper
    set_wallpaper(s)

    -- tags
    awful.tag({ "1" , "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- screen widgets
    s.widgets = {
        bar = awful.wibar({ position = "top", screen = s }),
        prompt = awful.widget.prompt(),
        layoutbox = awful.widget.layoutbox(s),
        taglist = awful.widget.taglist {
            screen = s,
            --filter = awful.widget.taglist.filter.all,
            filter = awful.widget.taglist.filter.noempty,
            -- TODO why do I need a join?
            buttons = gears.table.join(
                awful.button({ }, 1, function(t) t:view_only() end),
                awful.button({ modkey }, 1, function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end),
                awful.button({ }, 3, awful.tag.viewtoggle),
                awful.button({ modkey }, 3, function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end),
                awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
            ),
        },
        tasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = gears.table.join(
                awful.button({ }, 1, function (c)
                    if c == client.focus then
                        c.minimized = true
                    else
                        c:emit_signal("request::activate", "tasklist", { raise = true })
                    end
                end),
                awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
                awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
                awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
            ),
        },
    }

    -- configure screen widgets
    s.widgets.layoutbox:buttons(gears.table.join(awful.button({ }, 1, function () awful.layout.inc( 1) end),
                                                 awful.button({ }, 3, function () awful.layout.inc(-1) end),
                                                 awful.button({ }, 4, function () awful.layout.inc( 1) end),
                                                 awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- configure bar
    s.widgets.bar:setup {
        layout = wibox.layout.align.horizontal,
        { -- left
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
            widgets.launcher,
            s.widgets.taglist,
            s.widgets.prompt,
        },
        { -- middle
            layout = wibox.layout.fixed.horizontal,
            s.widgets.tasklist,
        },
        { -- right
            layout = wibox.layout.fixed.horizontal,
            spacing = 8,
            widgets.separator,
            widgets.kernel,
            widgets.separator,
            widgets.host,
            widgets.separator,
            widgets.cpu,
            widgets.separator,
            widgets.mem,
            widgets.separator,
            widgets.disk,
            widgets.separator,
            widgets.net,
            widgets.separator,
            widgets.battery,
            widgets.separator,
            widgets.updates,
            widgets.separator,
            widgets.tray,
            widgets.clock,
            s.widgets.layoutbox,
        },
    }
end)

--------------------------------------------------
-- client rules
--------------------------------------------------

-- xprop to get properties
awful.rules.rules = {
    -- all
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      }
    },

    -- titlebars for normal clients and dialogs
    { rule_any = {
        type = { "normal", "dialog" }
      },
      properties = { titlebars_enabled = config.titlebars }
    },

    -- floating
    { rule_any = {
        instance = {
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Cisco AnyConnect Secure Mobility Client",
          "Gpick",
          "Lxappearance",
          "PulseUI",
          "Sxiv",
          "VirtualBox",
          "VirtualBox Manager",
          "VirtualBox Machine",
        },
        name = {
          "Event Tester", -- xev.
          "Sign in to Security Device", -- brave piv pin entry
        },
        role = {
          "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        },
      },
      properties = { floating = true }
    },

    -- app specific rules
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = "1" }
    },

    -- nasa specific
    { rule_any = {
        class = {
          "ASIST_STATUS",
          "FastX",
          "Simics-common",
          "SPUDNIK", -- asist
        },
        name = {
          "Event Window on asist",
          "Serial Console", -- simics console (xterm)
        },
      },
      properties = { floating = true }
    },
}

--------------------------------------------------
-- functionality
--------------------------------------------------

-- focus border color
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- sloppy focus (focus follows mouse)
if config.sloppy_focus then
    client.connect_signal("mouse::enter", function(c)
        c:emit_signal("request::activate", "mouse_enter", {raise = false})
    end)
end

-- new client
client.connect_signal("manage", function(c)
    -- TODO move to master
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- prevent clients from being unreachable after screen count changes
        awful.placement.no_offscreen(c)
    end
end)

-- reset wallpaper on screen geometry change
screen.connect_signal("property::geometry", set_wallpaper)

-- titlebars (add if enabled in rules)
client.connect_signal("request::titlebars", function(c)
    -- titlebar buttons
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise=true})
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise=true})
            awful.mouse.client.resize(c)
        end)
    )

    -- setup titlebar
    awful.titlebar(c):setup {
        layout = wibox.layout.align.horizontal,
        { -- left
            layout = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
        },
        { -- middle
            layout = wibox.layout.flex.horizontal,
            { align  = "center", widget = awful.titlebar.widget.titlewidget(c) },
            buttons = buttons,
        },
        { -- right
            layout = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
        },
    }
end)

--------------------------------------------------
-- autostart
--------------------------------------------------

awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "autostart.sh" )

