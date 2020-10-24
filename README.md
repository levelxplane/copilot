# copilot
Windower addon for healing and stuff.


# Instructions
- Download ZIP using Green button to the top right of this section.
- Extract to Windower/addons/copilot. ex below.
```
Windower
    - addons
        - copilot
            - copilot.lua
            - maps.lua
```

- In Game `//lua l copilot`
- Console `lua l copilot`

# Usage
In `copilot.lua`, be sure to set `LEADER_NAME` to your main character's name.
And the mount if you intend on using that.


Most commands are read through party chat or tell chat(leader only).
- `maps.lua` is basically your list of commands.
  - `mb_ws` is used to detect what weaponskill is being used to attempt a magic burst.
    - ie, Catastrophe uses `mb_dark` which casts Stone, Water, and Blizzard.
    - Magicburst functionality can be toggled by typing `mb` into party/tell chat.
    - Feel free to create tables like mb_dark or mb_light to make your own list of spells.
    - You can limit the tier by typing `mb 0|1|2|3|4|`. 0 will remove the limiter.
- Each element in these lists should have a matching element in the `spell_flag_map`

# Spell Flags
I've put a number of spells that I use as defaults. For example,
`["cure"] = {name="Cure", geo_spell=false, offensive=false, tiers={" V", " IV", " III", " II", ""}}`

Typing 'cure' in to party chat will cause the script to use the highest tier Cure spell available to it.


# Geo Flags
The Geo flags work similar to spells, only they need to be preceded by the commands `lp` or `ind`.
Indi spells can be cast using `ind refresh` or `ent refresh Vivi` to use Entrust.

Similarly, Geo type spells are cast using `lp haste`. If you wish to specify a target, simply type their name after.
`lp haste Sephiroth` or `lpp haste Sephiroth` to do a Blaze of Glory Luopan


* Any given offensive spell can only be used on targets that are claimed by the party. Alliance targets will be ignored. *
To get around this, look into using the send addon.

# Leader Flags
These will only be read when the leader character sends them. These usually control fastfollow, mounts, and other misc commands.

# Custom Commands
The `CUSTOM_FLAG_MAP` in `copilot.lua` works similar the tables in `maps.lua`. The difference is here you can be specify entire functions to run when the proper flag is detected.

The functions `staq`, `proshe`, and `rr` are rudimentary examples, but you can get more creative with them. Probably.


# Addon Commands
- Misc controls
`//copilot autoheal` will toggle autohealing.
`//copilot autoheal` will toggle party and alliance checking.
`//copilot leader` will toggle healing the leader and the alt character only.
`//copilot tm` will push notifications to party chat, or stay in tells.
