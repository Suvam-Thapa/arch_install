#!/bin/bash

Conf_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

D_server () {
        echo "Installing Xorg (xorg-server + xorg-xinit)..."
        sudo pacman -S --needed --noconfirm xorg-server xorg-xinit xorg-apps
}

login_manager () {
        echo "Installing SDDM..."
        sudo pacman -S --needed --noconfirm sddm
        sudo systemctl enable sddm
}

window_manager () {
        echo "Installing DWM..."
        mkdir -p ~/.config
        cd ~/.config
        git clone https://git.suckless.org/dwm 
        cd ~/.config/dwm/

tee ~/.config/dwm/config.def.h > /dev/null <<'EOF'
/* appearance */
static const unsigned int borderpx  = 0;   
static const unsigned int snap      = 24; 
static const int showbar            = 0;   
static const int topbar             = 1;  
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=10" };
static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=10";
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#52616B";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },  // col_cyan
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4" };
static const Rule rules[] = { NULL };

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; 
static const char *dmenucmd[] = {"dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL};
static const char *termcmd[]  = {"alacritty", NULL};
static const char *browser[] = {"vivaldi-stable" , "--disable-gpu-vsync", NULL};
static const char *gnome_screenshot[] = {"gnome-screenshot", "-i", NULL};
static const char *thunar[] = {"thunar", NULL};
static const char *brightness_inc[] = {"brightnessctl", "s", "+10%", NULL};
static const char *brightness_dec[] = {"brightnessctl", "s", "10%-", NULL};

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY|ShiftMask,     		XK_c,       quit,           {0} },
	{ MODKEY|ShiftMask,     		XK_q,       killclient,     {0} },
	{ MODKEY,           			XK_p,       spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return,  zoom,           {0} },
	{ MODKEY,                		XK_Return,  spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,       togglebar,      {0} },
	{ MODKEY|ShiftMask,             XK_b,       spawn,          {.v = browser } },
	{ MODKEY,                       XK_e,       spawn,          {.v = thunar } },
    { MODKEY|ShiftMask,             XK_minus,   spawn,          {.v = brightness_dec } },
    { MODKEY|ShiftMask,             XK_equal,   spawn,          {.v = brightness_inc } },
    { MODKEY|ShiftMask,             XK_s,       spawn,          {.v = gnome_screenshot } },
    { MODKEY,                       XK_Tab,     view,           {0} },
    { MODKEY,                       XK_h,       setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_j,       focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,       focusstack,     {.i = -1 } },
    { MODKEY,                       XK_l,       setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_i,       incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_d,       incnmaster,     {.i= -1 } },
	{ MODKEY,                       XK_n,       setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_period,  setlayout,      {.v = &layouts[0]} },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[1]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
EOF
        cp config.def.h config.h
        sudo pacman -S --noconfirm dmenu
        sudo make clean install
        cd
        sudo mkdir -p /usr/share/xsessions

sudo tee /usr/share/xsessions/dwm.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Dwm
Comment=Dynamic Window Manager
Exec=/usr/local/bin/dwm
Type=Application
Keywords=windowmanager;
EOF

}

terminal () {
        echo "Installing Alacritty..."
        sudo pacman -S --needed --noconfirm alacritty
        mkdir -p ~/.config/alacritty/ 

tee ~/.config/alacritty/alacritty.toml >/dev/null <<'EOF'
[general]
live_config_reload = true

[window]
padding = { x = 0 , y = 0 }
dynamic_padding = false 

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular"}
bold = { family = "JetBrainsMono Nerd Font", style = "Bold"}
italic = { family = "JetBrainsMono Nerd Font", style = "Italic"}
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic"}
size = 12.2

[keyboard]
bindings = [
  { key = "Back", mods = "Control", chars = "\u001B\u007F" }
]

# [selection]
# save_to_clipboard = false 

# [cursor]
# style = {shape= "Block"}

# [terminal]
# osc52 = "CopyPaste"

# [mouse]
# hide_when_typing = true

# Default colors
[colors.primary]
background = '#fdf6e3'
foreground = '#5c6a72'

# Normal colors
[colors.normal]
black = '#5c6a72'
red = '#f85552'
green = '#8da101'
yellow = '#dfa000'
blue = '#3a94c5'
magenta = '#df69ba'
cyan = '#35a77c'
white = '#e0dcc7'

# Bright Colors
[colors.bright]
black = '#5c6a72'
red = '#f85552'
green = '#8da101'
yellow = '#dfa000'
blue = '#3a94c5'
magenta = '#df69ba'
cyan = '#35a77c'
white = '#e0dcc7'
EOF

}

F_manager () {
        echo "Installing Thunar File Manager..."
        sudo pacman -S --needed --noconfirm thunar tumbler thunar-volman
}

Jetbrains_font () {
        echo "Installing JetBrainsMono Nerd Font..."
        curl -fLo /tmp/JetBrainsMono.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip && \
        7z x /tmp/JetBrainsMono.zip -o"$HOME/JetBrainsMono" -y && \
        rm -rf /tmp/JetBrainsMono.zip

        sudo mv ~/JetBrainsMono/ /usr/share/fonts/
}

Def_applications () {
        echo "Installing Additional Packages..."
        yay -S --needed --noconfirm $(grep -v '^#' "$Conf_Dir/pkg_list.txt" | grep -v '^$')
}

D_server

clear
Jetbrains_font

clear
window_manager

clear
login_manager

clear
terminal

clear
F_manager


clear
Def_applications
xdg-user-dirs-update
clear
