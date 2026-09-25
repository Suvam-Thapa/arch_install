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
/* Max Scratchpads */
#define MAX_SCRATCHPADS 4

/* key definitions */
#define MODKEY Mod1Mask

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd)                                                                                           \
  {                                                                                                          \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                                                     \
  }

/* Dynamic Tag Tracking Memory */
static unsigned int markedtag = 1 << 0; /* "home" tag bookmark, defaults to tag 1 */
static unsigned int lasttag = 1 << 0;   /* tag you were on before your last jump/shift */

/* Dynamic Scratchpad Memory & Saved Geometry */
static Client *scratchpads[MAX_SCRATCHPADS] = {NULL};
static int scratchpad_was_floating[MAX_SCRATCHPADS] = {0};
static int scratchpad_count = 0;
static int current_scratchpad_idx = -1;

/* appearance */
static const unsigned int borderpx = 0; /* window border width in pixels */
static const unsigned int snap = 24;    /* snap distance for window edges, in pixels */
static const int showbar = 0;           /* 0 = bar hidden by default */
static const int topbar = 1;            /* 1 = bar on top, 0 = bottom */
static const char *fonts[] = {"CaskaydiaCove NF SemiBold:size=12"};  /* bar font */
static const char dmenufont[] = "CaskaydiaCove NF SemiBold:size=12"; /* dmenu font */
static const char col_bg[] = "#f2e5bc";
static const char col_fg[] = "#3c3836";
static const char col_sel_bg[] = "#d5c4a1";
static const char col_sel_fg[] = "#3c3836";
static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = {col_fg, col_bg, col_bg},
    [SchemeSel] = {col_sel_fg, col_sel_bg, col_sel_fg},
};

/* tagging */
static const char *tags[] = {"1", "2", "3", "4"}; /* tag/workspace names */
static const Rule rules[] = {
    {0}, /* no client rules defined */
};

/* layout(s) */
static const float mfact = 0.50;     /* master area size as a fraction of screen [0.05..0.95] */
static const int nmaster = 1;        /* number of clients kept in the master area */
static const int resizehints = 1;    /* 1 = respect size hints when resizing tiled clients */
static const int lockfullscreen = 1; /* 1 = force focus to stay on a fullscreen window */
static const int refreshrate = 144;  /* refresh rate (Hz) used while moving/resizing clients */
static const Layout layouts[] = {
    /* symbol     arrange function */
    {"[]=", tile},
    {"[M]", monocle},
};

/* commands */
static char dmenumon[2] = "0"; /* which monitor dmenu opens on */
static const char *dmenucmd[] = {"dmenu_run", "-m",   dmenumon, "-fn",      dmenufont, "-nb",      col_bg,
                                 "-nf",       col_fg, "-sb",    col_sel_bg, "-sf",     col_sel_fg, NULL};
static const char *termcmd[] = {"alacritty", NULL};
static const char *browser[] = {"vivaldi-stable", "--disable-gpu-vsync", NULL};
static const char *gnome_screenshot[] = {"gnome-screenshot", "-i", NULL};
static const char *thunar[] = {"thunar", NULL};
static const char *brightness_inc[] = {"brightnessctl", "s", "+8%", NULL};
static const char *brightness_dec[] = {"brightnessctl", "s", "8%-", NULL};
static const char *volume[] = {"pavucontrol", NULL};
static const char *reboot[] = {"reboot", NULL};
static const char *emacs[] = {"emacsclient", "-c", "-a", "", NULL};

/* Function Declarations */
static void view_w(const Arg *arg);
static void marktag(const Arg *arg);
static void jumptomark(const Arg *arg);
static void shiftview(const Arg *arg);
static void shifttag(const Arg *arg);
static void cyclelayout(const Arg *arg);
static void moveresize(const Arg *arg);

/* Scratchpad Declarations */
static void showscratchpad(Client *c, unsigned int curtag);
static void remove_scratchpad_slot(int i);
static void cleanup_scratchpads(void);
void markscratchpad(const Arg *arg);
void togglescratchpad(const Arg *arg);
void cyclescratchpad(const Arg *arg);
void unmarkscratchpad(const Arg *arg);

/* Gather all window  */
void gatherall(const Arg *arg);

/* Custom tracked view wrapper */
void view_w(const Arg *arg) {
  unsigned int prevtag = selmon->tagset[selmon->seltags]; /* tag we're about to leave */

  if ((arg->ui & TAGMASK) == prevtag)
    return;

  /* Clean dead window pointers before inspecting tags */
  cleanup_scratchpads();

  if (current_scratchpad_idx >= 0 && scratchpads[current_scratchpad_idx]) {
    Client *c = scratchpads[current_scratchpad_idx];
    if (c->tags & prevtag)
      c->tags = 0; /* hide it */
  }

  if (prevtag != markedtag)
    lasttag = prevtag;

  view(arg);
}

/* Save active workspace as markedtag */
void marktag(const Arg *arg) { markedtag = selmon->tagset[selmon->seltags]; }

/* Smart Jump: Toggle between Home (markedtag) and Dynamic Previous (lasttag) */
void jumptomark(const Arg *arg) {
  unsigned int current = selmon->tagset[selmon->seltags];
  Arg a;
  a.ui = (current != markedtag) ? markedtag : lasttag;
  view_w(&a);
}

/* cyclic tag */
void shiftview(const Arg *arg) {
  Arg shifted;
  unsigned int numtags = LENGTH(tags);
  unsigned int current = selmon->tagset[selmon->seltags];
  int shift = arg->i % numtags;
  if (shift > 0)
    shifted.ui = (current << shift) | (current >> (numtags - shift));
  else if (shift < 0)
    shifted.ui = (current >> -shift) | (current << (numtags + shift));
  else
    return;
  shifted.ui &= TAGMASK;
  if (shifted.ui)
    view_w(&shifted);
}

/* cyclic window and follow it */
void shifttag(const Arg *arg) {
  if (!selmon->sel)
    return;
  Arg shifted;
  unsigned int numtags = LENGTH(tags);
  unsigned int curtags = selmon->sel->tags;
  if (arg->i > 0)
    shifted.ui = (curtags << arg->i) | (curtags >> (numtags - arg->i));
  else
    shifted.ui = (curtags >> (-arg->i)) | (curtags << (numtags - (-arg->i)));

  shifted.ui &= (1 << numtags) - 1;
  if (shifted.ui) {
    tag(&shifted);
    shiftview(arg);
  }
}

/* cycle layout */
void cyclelayout(const Arg *arg) {
  int i;
  int numlayouts = LENGTH(layouts);
  for (i = 0; i < numlayouts; i++) {
    if (selmon->lt[selmon->sellt] == &layouts[i])
      break;
  }
  if (arg->i > 0)
    i = (i + 1) % numlayouts;
  else
    i = (i - 1 + numlayouts) % numlayouts;
  setlayout(&((Arg){.v = &layouts[i]}));
}

/* resize/move floating windows */
void moveresize(const Arg *arg) {
  XEvent ev;
  Monitor *m = selmon;
  if (!(m->sel && arg && arg->v && m->sel->isfloating))
    return;
  resize(m->sel, m->sel->x + ((int *)arg->v)[0], m->sel->y + ((int *)arg->v)[1],
         m->sel->w + ((int *)arg->v)[2], m->sel->h + ((int *)arg->v)[3], 1);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev))
    ;
}

/* Helper: clean fullscreen before showing scratchpad */
static void showscratchpad(Client *c, unsigned int curtag) {
  int w, h, x, y;
  if (c->isfullscreen)
    setfullscreen(c, 0);
  c->isfloating = 1;
  w = selmon->ww * 0.88;
  h = selmon->wh * 0.88;
  x = selmon->wx + (selmon->ww - w) / 2;
  y = selmon->wy + (selmon->wh - h) / 2;
  c->tags = curtag;
  resize(c, x, y, w, h, 0);
  XRaiseWindow(dpy, c->win);
  focus(c);
  arrange(selmon);
}

/* Helper: index management */
static void remove_scratchpad_slot(int i) {
  int j;
  for (j = i; j < scratchpad_count - 1; j++) {
    scratchpads[j] = scratchpads[j + 1];
    scratchpad_was_floating[j] = scratchpad_was_floating[j + 1];
  }
  scratchpad_count--;
  scratchpads[scratchpad_count] = NULL;
  scratchpad_was_floating[scratchpad_count] = 0;

  if (scratchpad_count == 0) {
    current_scratchpad_idx = -1;
    return;
  }

  if (current_scratchpad_idx > i) {
    current_scratchpad_idx--;
  } else if (current_scratchpad_idx == i) {
    if (current_scratchpad_idx >= scratchpad_count)
      current_scratchpad_idx = scratchpad_count - 1;
  }
}

/* Helper: Remove closed windows automatically */
static void cleanup_scratchpads(void) {
  int i;
  for (i = 0; i < scratchpad_count; i++) {
    int exists = 0;
    Client *c;
    for (c = selmon->clients; c; c = c->next) {
      if (c == scratchpads[i]) {
        exists = 1;
        break;
      }
    }
    if (!exists) {
      remove_scratchpad_slot(i);
      i--;
    }
  }
}

/* Attach focused window to scratchpad pool or detach it */
void markscratchpad(const Arg *arg) {
  unsigned int curtag = selmon->tagset[selmon->seltags];
  int i;
  if (!selmon->sel)
    return;
  cleanup_scratchpads();

  for (i = 0; i < scratchpad_count; i++) {
    if (scratchpads[i] == selmon->sel) {
      selmon->sel->isfloating = scratchpad_was_floating[i];
      selmon->sel->tags = curtag;
      remove_scratchpad_slot(i);
      arrange(selmon);
      return;
    }
  }

  if (scratchpad_count >= MAX_SCRATCHPADS)
    return;

  if (current_scratchpad_idx >= 0 && scratchpads[current_scratchpad_idx])
    scratchpads[current_scratchpad_idx]->tags = 0;

  int idx = scratchpad_count;
  scratchpads[idx] = selmon->sel;
  scratchpad_was_floating[idx] = selmon->sel->isfloating;
  scratchpad_count++;
  current_scratchpad_idx = idx;
  showscratchpad(selmon->sel, curtag);
}

/* Show/hide active scratchpad */
void togglescratchpad(const Arg *arg) {
  cleanup_scratchpads();

  if (scratchpad_count == 0 || current_scratchpad_idx < 0)
    return;
  Client *c = scratchpads[current_scratchpad_idx];
  unsigned int curtag = selmon->tagset[selmon->seltags];

  if ((c->tags & curtag) && c == selmon->sel) {
    c->tags = 0;
    focus(NULL);
    arrange(selmon);
  } else {
    showscratchpad(c, curtag);
  }
}

/* Cycle to next/previous scratchpad in pool */
void cyclescratchpad(const Arg *arg) {
  cleanup_scratchpads();
  if (scratchpad_count < 2)
    return;

  if (current_scratchpad_idx >= 0 && scratchpads[current_scratchpad_idx]) {
    scratchpads[current_scratchpad_idx]->tags = 0;
  }

  int step = (arg && arg->i < 0) ? -1 : 1;
  current_scratchpad_idx = (current_scratchpad_idx + step) % scratchpad_count;
  if (current_scratchpad_idx < 0)
    current_scratchpad_idx += scratchpad_count;

  showscratchpad(scratchpads[current_scratchpad_idx], selmon->tagset[selmon->seltags]);
}

/* Detach active scratchpad from pool */
void unmarkscratchpad(const Arg *arg) {
  cleanup_scratchpads();

  if (scratchpad_count == 0 || current_scratchpad_idx < 0)
    return;

  Client *c = scratchpads[current_scratchpad_idx];
  c->isfloating = scratchpad_was_floating[current_scratchpad_idx];
  c->tags = selmon->tagset[selmon->seltags];
  remove_scratchpad_slot(current_scratchpad_idx);
  arrange(selmon);
  focus(c);
}

void gatherall(const Arg *arg) {
  Client *c;
  unsigned int curtag = selmon->tagset[selmon->seltags];
  int i, is_scratch;

  cleanup_scratchpads();

  for (c = selmon->clients; c; c = c->next) {
    is_scratch = 0;
    for (i = 0; i < scratchpad_count; i++) {
      if (c == scratchpads[i]) {
        is_scratch = 1;
        break;
      }
    }
    if (!is_scratch)
      c->tags = curtag;
  }
  focus(NULL);
  arrange(selmon);
}

static Key keyseq_ctrlsemicolon[] = {
    /* Tag Keys */
    {0, XK_1, tag, {.ui = 1 << 0}},
    {0, XK_2, tag, {.ui = 1 << 1}},
    {0, XK_3, tag, {.ui = 1 << 2}},
    {0, XK_4, tag, {.ui = 1 << 3}},

    /* Essential bindings  */
    {0, XK_r, spawn, {.v = reboot}},
    {0, XK_q, killclient, {0}},
    {0, XK_c, quit, {0}},
    {0, XK_Return, zoom, {0}},

    /* Essential bindings  */
    {0, XK_h, incnmaster, {.i = +1}},
    {0, XK_j, focusstack, {.i = +1}},
    {0, XK_k, focusstack, {.i = -1}},
    {0, XK_l, incnmaster, {.i = -1}},

    /* Send window & follow to Prev/Next tag cyclically */
    {0, XK_s, shifttag, {.i = -1}},
    {0, XK_f, shifttag, {.i = +1}},

    {0}};

static Key keyseq_ctrlperiod[] = {
    /* Applications */
    {0, XK_x, spawn, {.v = dmenucmd}},
    {0, XK_b, spawn, {.v = browser}},
    {0, XK_e, spawn, {.v = thunar}},
    {0, XK_v, spawn, {.v = volume}},
    {0, XK_o, spawn, {.v = emacs}},
    {0, XK_i, spawn, {.v = gnome_screenshot}},
    {0, XK_Return, spawn, {.v = termcmd}},

    /* Tag Keys */
    {0, XK_1, view_w, {.ui = 1 << 0}},
    {0, XK_2, view_w, {.ui = 1 << 1}},
    {0, XK_3, view_w, {.ui = 1 << 2}},
    {0, XK_4, view_w, {.ui = 1 << 3}},

    /* Bookmark Navigation */
    {0, XK_m, marktag, {0}},
    {0, XK_j, jumptomark, {0}},

    /* Layouts */
    {0, XK_k, cyclelayout, {.i = +1}},

    /* Tag Navigation (Cyclic) */
    {0, XK_s, shiftview, {.i = -1}},
    {0, XK_f, shiftview, {.i = +1}},

    /* Dynamic Multi-Scratchpad Controls */
    {0, XK_a, markscratchpad, {0}},
    {0, XK_t, togglescratchpad, {0}},
    {0, XK_n, cyclescratchpad, {.i = +1}},
    {0, XK_p, cyclescratchpad, {.i = -1}},
    {0, XK_u, unmarkscratchpad, {0}},

    /* Window Management / Layout Extras */
    {0, XK_g, gatherall, {0}},
    {0}};

static Key keys[] = {
    /* Essential bindings */
    {MODKEY, XK_b, togglebar, {0}},
    {MODKEY | ShiftMask, XK_minus, spawn, {.v = brightness_dec}},
    {MODKEY | ShiftMask, XK_equal, spawn, {.v = brightness_inc}},

    /* Window navigation */
    {MODKEY, XK_h, setmfact, {.f = -0.05}},
    {MODKEY, XK_l, setmfact, {.f = +0.05}},

    /* Move floating windows with Mod + Ctrl + H/J/K/L */
    {MODKEY | ControlMask, XK_h, moveresize, {.v = (int[]){-25, 0, 0, 0}}},
    {MODKEY | ControlMask, XK_l, moveresize, {.v = (int[]){25, 0, 0, 0}}},
    {MODKEY | ControlMask, XK_j, moveresize, {.v = (int[]){0, 25, 0, 0}}},
    {MODKEY | ControlMask, XK_k, moveresize, {.v = (int[]){0, -25, 0, 0}}},

    /* Resize floating windows with Mod + Shift + H/J/K/L */
    {MODKEY | ShiftMask, XK_h, moveresize, {.v = (int[]){0, 0, -25, 0}}},
    {MODKEY | ShiftMask, XK_l, moveresize, {.v = (int[]){0, 0, 25, 0}}},
    {MODKEY | ShiftMask, XK_j, moveresize, {.v = (int[]){0, 0, 0, 25}}},
    {MODKEY | ShiftMask, XK_k, moveresize, {.v = (int[]){0, 0, 0, -25}}},

    /* Ctrl+; && Ctrl+. sequence prefix */
    {ControlMask, XK_semicolon, keypress_other, {.v = keyseq_ctrlsemicolon}},
    {ControlMask, XK_period, keypress_other, {.v = keyseq_ctrlperiod}},
    {0}};

static const Button buttons[] = {
    /* click                event mask      button          function        argument */
    {ClkLtSymbol, 0, Button1, setlayout, {0}},
    {ClkLtSymbol, 0, Button3, setlayout, {.v = &layouts[1]}},
    {ClkWinTitle, 0, Button2, zoom, {0}},
    {ClkStatusText, 0, Button2, spawn, {.v = termcmd}},
    {ClkClientWin, MODKEY, Button1, movemouse, {0}},
    {ClkClientWin, MODKEY, Button2, togglefloating, {0}},
    {ClkClientWin, MODKEY, Button3, resizemouse, {0}},
    {ClkTagBar, 0, Button1, view, {0}},
    {ClkTagBar, 0, Button3, toggleview, {0}},
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
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
normal = { family = "CaskaydiaCove NF SemiBold", style = "Regular"}
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

# gruvbox light soft
[colors.primary]
background = "#f2e5bc"
foreground = "#3c3836"
dim_foreground = "#7c6f64"

[colors.cursor]
text = "#f2e5bc"
cursor = "#3c3836"

[colors.vi_mode_cursor]
text = "#f2e5bc"
cursor = "#427b58"

[colors.selection]
text = "#f2e5bc"
background = "#3c3836"

[colors.search.matches]
foreground = "#f2e5bc"
background = "#b57614"

[colors.search.focused_match]
foreground = "#f2e5bc"
background = "#8f3f71"

[colors.normal]
black   = "#f2e5bc" 
red     = "#cc241d" 
green   = "#98971a" 
yellow  = "#d79921" 
blue    = "#458588" 
magenta = "#b16286" 
cyan    = "#689d6a" 
white   = "#7c6f64" 

[colors.bright]
black   = "#928374" 
red     = "#9d0006" 
green   = "#79740e" 
yellow  = "#b57614" 
blue    = "#076678" 
magenta = "#8f3f71" 
cyan    = "#427b58" 
white   = "#3c3836" 

[colors.line_indicator]
foreground = "None"
background = "#ebdbb2"

[[colors.indexed_colors]]
index = 16
color = "#af3a03"

[[colors.indexed_colors]]
index = 17
color = "#d65d0e"
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
