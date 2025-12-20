# Pinguim Christmas 🎅
PINGUIM-XMAS - The most advanced christmas script built for QBox. 

# Preview
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/554a73fe-7124-4eed-adda-f929e2eff05d" />


## Features:

* Fully interactive Christmas decorations (snowmen, Xmas trees)
* Place snowmen or Xmas trees dynamically with rotation, height adjustment, and arrow movement
* Smooth object placement with visual feedback and animations
* Cooldown system for picking up snowballs
* Snowball throwing triggers realistic ragdoll effects
* Persistent decorations saved to the database for all players
* Snowmen can be removed with a command (`/removechristmas`)
* Automatic random snowman model selection

* Useable items for placing snowmen (`snowman`) and Xmas trees (`xmastree`)
* Interactive Christmas shop with NPC and blip
* Fully compatible with **QBCore**, **QBox**, and **OX Inventory**
* Multi-language support with dynamic locale loading (`locales/*.json`)
* Easy to add new languages (`en.json`, `pt.json`) with automatic English fallback
* Cool NPC animations for shops and deer placement for a festive environment
* Configurable snowman and tree models through `config.lua`
* Database-backed persistence using `oxmysql` for all placed snowmen
* Supports server-wide events to sync snowmen placement and removal


# Features coming:
- Function to qb-inventory and qb-target
- Some decorations.
- Some more simple useful functions
- And more...

## Dependencies
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_target](https://github.com/overextended/ox_target)
* [oxmysql](https://github.com/overextended/oxmysql)
* [Christmas Park](https://kiiya.tebex.io/package/6015615)
  * https://www.youtube.com/watch?v=bgpQ6kp0O5Y
* [ox_inventory](https://github.com/overextended/ox_inventory)

## Installation
1. Place the resource folder in your `resources` directory.
2. Add to your `server.cfg`:
3. Configure your `Config.lua`:
   * Set `Locale` (`"en"` or `"pt"`)
4. Go to ox_inventory in the data\items.lua and put this:
```lua

['snowman'] = {
        label = 'Snowman',
        weight = 500,
        stack = true,
        close = true,
    },

    ['xmastree'] = {
        label = 'Christmas Tree',
        weight = 1,
        stack = true,
        close = true,
    },

```
