#!/bin/sh

/usr/bin/prime-offload

# Load profile
for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/.xprofile"; do
	if [ -f "$file" ]; then
		echo "Loading profile from $file"
		. "$file"
	fi
done

# Load resources
for file in "/etc/X11/Xresources" "$HOME/.Xresources"; do
	if [ -f "$file" ]; then
		echo "Loading resource: $file"
		xrdb -merge "$file"
	fi
done

# Load keymaps
for file in "/etc/X11/Xkbmap" "$HOME/.Xkbmap"; do
	if [ -f "$file" ]; then
		echo "Loading keymap: $file"
		setxkbmap $(cat "$file")
		XKB_IN_USE=yes
	fi
done

# Load xmodmap if not using XKB
if [ -z "$XKB_IN_USE" ]; then
	for file in "/etc/X11/Xmodmap" "$HOME/.Xmodmap"; do
		if [ -f "$file" ]; then
			echo "Loading modmap: $file"
			xmodmap "$file"
		fi
	done
fi

unset XKB_IN_USE

# Run all system xinitrc shell scripts
xinitdir="/etc/X11/xinit/xinitrc.d"
if [ -d "$xinitdir" ]; then
	for script in $xinitdir/*; do
		echo "Loading xinit script $script"
		if [ -x "$script" -a ! -d "$script" ]; then
			. "$script"
		fi
	done
fi

xsetroot -cursor_name left_ptr
xrandr --dpi 141

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export QT4_IM_MODULE=ibus
export CLUTTER_IM_MODULE=ibus
ibus-daemon -rdx

ibus engine xkb:us::eng

bspwm

sudo /usr/bin/prime-switch
