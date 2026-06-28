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
	sudo mkdir -p /etc/sddm.conf.d/
	sudo cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf.d/
	sudo sed -i '/\[Autologin\]/,/\[General\]/ s/^Session=/Session=dwm/' /etc/sddm.conf.d/default.conf
	sudo sed -i '/\[Autologin\]/,/\[General\]/ s/^Relogin=false/Relogin=true/' /etc/sddm.conf.d/default.conf
	sudo sed -i '/\[Autologin\]/,/\[General\]/ s/^User=/User=suvam/' /etc/sddm.conf.d/default.conf
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
static const char *fonts[]          = { "CaskaydiaCove Nerd Font:size=12" };
static const char dmenufont[]       = "CaskaydiaCove Nerd Font:size=14";
static const char col_bg[]          = "#101319";
static const char col_fg[]          = "#f4f3ee";
static const char col_sel_bg[]      = "#956dca";
static const char col_sel_fg[]      = "#101319";
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
static const char *emacs[] = {"emacs", NULL};

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
    { 0,            XK_o,       spawn,          {.v = emacs } },
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
padding = { x = 0 , y = 10 }
dynamic_padding = false 

[font]
normal = { family = "CaskaydiaCove Nerd Font", style = "Regular"}
bold = { family = "CaskaydiaCove Nerd Font", style = "Bold"}
italic = { family = "CaskaydiaCove Nerd Font", style = "Italic"}
bold_italic = { family = "CaskaydiaCove Nerd Font", style = "Bold Italic"}
size=12.45

[keyboard]
bindings = [
  { key = "Back", mods = "Control", chars = "\u0017" }
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
background = "#101319"
foreground = "#f4f3ee"
dim_foreground = "#dddbcf"

[colors.cursor]
text = "#101319"
cursor = "#e34f4f"

[colors.vi_mode_cursor]
text = "#101319"
cursor = "#956dca"

[colors.selection]
text = "#171b24"
background = "#956dca"

[colors.search.matches]
foreground = "#171b24"
background = "#de642b"

[colors.search.focused_match]
foreground = "#171b24"
background = "#885ac4"

[colors.normal]
black = "#171b24"
red = "#de2b2b"
green = "#69bfce"
yellow = "#de642b"
blue = "#3f8cde"
magenta = "#956dca"
cyan = "#56b7c8"
white = "#dddbcf"

[colors.bright]
black = "#3a435a"
red = "#e34f4f"
green = "#885ac4"
yellow = "#e37e4f"
blue = "#5679e3"
magenta = "#5599e2"
cyan = "#3e66e0"
white = "#f4f3ee"

[colors.line_indicator]
foreground = "None"
background = "#171b24"

[[colors.indexed_colors]]
index = 16
color = "#de642b"

[[colors.indexed_colors]]
index = 17
color = "#5679e3"
EOF

}

F_manager () {
        echo "Installing Thunar File Manager..."
        sudo pacman -S --needed --noconfirm thunar tumbler thunar-volman
}

CascadiaCode_font () {
        echo "Installing CascadiaCode Nerd Font..."
        curl -fLo /tmp/CascadiaCode.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip && \
        7z x /tmp/CascadiaCode.zip -o"$HOME/CascadiaCode" -y && \
        rm -rf /tmp/CascadiaCode.zip

        sudo mv ~/CascadiaCode/ /usr/share/fonts/
}

zram_initialize () {
        echo "Zram Initialization..."
sudo tee /etc/systemd/zram-generator.conf > /dev/null <<'EOF'
# /etc/systemd/zram-generator.conf
[zram0]
zram-size = 3072
compression-algorithm = zstd
swap-priority = 120
EOF

sudo tee /etc/sysctl.d/99-zram.conf > /dev/null <<'EOF'
# /etc/sysctl.d/99-zram.conf
vm.swappiness = 80
EOF
}

Def_applications () {
        echo "Installing Additional Packages..."
        yay -S --needed --noconfirm $(grep -v '^#' "$Conf_Dir/pkg_list.txt" | grep -v '^$')
}

D_server

clear
CascadiaCode_font

clear
window_manager

clear
login_manager

clear
terminal

clear
F_manager

clear
zram_initialize

clear
Def_applications
xdg-user-dirs-update
clear
