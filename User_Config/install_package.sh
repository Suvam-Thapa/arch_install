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
        curl -O https://dwm.suckless.org/patches/keysequence/keysequence-20250606-0d6af14.diff
        patch -p1 < keysequence-20250606-0d6af14.diff

tee ~/.config/dwm/config.def.h > /dev/null <<'EOF'
/* appearance */
static const unsigned int borderpx  = 0;
static const unsigned int snap      = 24; 
static const int showbar            = 0;   
static const int topbar             = 1;  
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=12" };
static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=14";
static const char col_bg[]          = "#FDF6E3";
static const char col_fg[]          = "#5C6A72";
static const char col_sel_bg[]      = "#F0F1D2";
static const char col_sel_fg[]      = "#F57D26";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_fg, col_bg, col_bg },
	[SchemeSel]  = { col_sel_fg, col_sel_bg,  col_sel_fg }, 
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4" };
static const Rule rules[] = { NULL };

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 144;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; 
static const char *dmenucmd[] = {"dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_bg, "-nf", col_fg, "-sb", col_sel_bg, "-sf", col_sel_fg, NULL};
static const char *termcmd[]  = {"alacritty", NULL};
static const char *browser[] = {"vivaldi-stable" , "--disable-gpu-vsync", NULL};
static const char *gnome_screenshot[] = {"gnome-screenshot", "-i", NULL};
static const char *thunar[] = {"thunar", NULL};
static const char *brightness_inc[] = {"brightnessctl", "s", "+10%", NULL};
static const char *brightness_dec[] = {"brightnessctl", "s", "10%-", NULL};
static const char *volume[] = {"pavucontrol", NULL};
static const char *reboot[] = {"reboot", NULL};

static Key keyseq_ctrlsemicolon[] = {

	/* modifier      key        function        argument */

    /* Essential bindings  */
    { 0,            XK_r,       spawn,          {.v = reboot } },
	{ 0,            XK_q,       killclient,     {0} },
	{ 0,            XK_c,       quit,           {0} },
    { 0,            XK_Tab,     view,           {0} },
    { 0,            XK_Return,  zoom,           {0} },

    /* Tag Keys */
    { 0,            XK_1,       view,           {.ui = 1 << 0 } },
    { 0,            XK_2,       view,           {.ui = 1 << 1 } },
    { 0,            XK_3,       view,           {.ui = 1 << 2 } },
    { 0,            XK_4,       view,           {.ui = 1 << 3 } },

	/* Layouts */
	{ 0,            XK_j,       setlayout,      {.v = &layouts[0]} },
	{ 0,            XK_k,       setlayout,      {.v = &layouts[1]} },
    {0}
};


static Key keyseq_ctrlperiod[] = {

    /* Applications */
    { 0,            XK_p,       spawn,          {.v = dmenucmd } },
    { 0,            XK_b,       spawn,          {.v = browser } },
    { 0,            XK_e,       spawn,          {.v = thunar } },
    { 0,            XK_s,       spawn,          {.v = gnome_screenshot } },
    { 0,            XK_v,       spawn,          {.v = volume } },
    { 0,            XK_Return,  spawn,          {.v = termcmd } },


    /* Essential bindings  */
    { 0,            XK_h,       incnmaster,     {.i = +1 } },
    { 0,            XK_j,       focusstack,     {.i = +1 } },
    { 0,            XK_k,       focusstack,     {.i = -1 } },
    { 0,            XK_l,       incnmaster,     {.i = -1 } },

    /* Tag Keys */
    { 0,            XK_1,       tag,           {.ui = 1 << 0 } },
    { 0,            XK_2,       tag,           {.ui = 1 << 1 } },
    { 0,            XK_3,       tag,           {.ui = 1 << 2 } },
    { 0,            XK_4,       tag,           {.ui = 1 << 3 } },
	{0}
};


static Key keys[] = {
	/* modifier                     key        function        argument */
	
	/* Essential bindings */
    { MODKEY,                       XK_b,       togglebar,      {0} },
    { MODKEY|ShiftMask,             XK_minus,   spawn,          {.v = brightness_dec } },
    { MODKEY|ShiftMask,             XK_equal,   spawn,          {.v = brightness_inc } },
	
	/* Window navigation */
	{ MODKEY,                       XK_h,       setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,       setmfact,       {.f = +0.05} },
	
	/* Ctrl+; && Ctrl+. sequence prefix */
	{ ControlMask,                  XK_semicolon,   keypress_other,     {.v = keyseq_ctrlsemicolon} },
    { ControlMask,                  XK_period,      keypress_other,     {.v = keyseq_ctrlperiod} },
	{0}
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
