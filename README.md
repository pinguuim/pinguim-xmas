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
   * Choose your `InventorySystem` (`"ox" You can only choose “ox” because qb inventory and qb target do not function.`)
   * Adjust cooldown, reward chance, and NPC models as desired
4. Go to ox_inventory in the data\items.lua and put this:
```lua
['halloween-candycorn'] = {
    label = 'Candy Corn',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You enjoyed a candy corn!',
        image = 'halloween-candycorn.png'
    },
},

['halloween-chocolateskull'] = {
    label = 'Chocolate Skull',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You ate a chocolate skull!',
        image = 'halloween-chocolateskull.png'
    },
},

['halloween-ghostmarshmallow'] = {
    label = 'Ghost Marshmallow',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You ate a ghost-shaped marshmallow!',
        image = 'halloween-ghostmarshmallow.png'
    },
},

['halloween-caramelapple'] = {
    label = 'Caramel Apple',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You enjoyed a caramel apple!',
        image = 'halloween-caramelapple.png'
    },
},


['halloween-licorice'] = {
    label = 'Licorice',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You chewed on some licorice!',
        image = 'halloween-licorice.png'
    },
},

['halloween-eyeballcandy'] = {
    label = 'Eyeball Candy',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You ate some eyeball candy!',
        image = 'halloween-eyeballcandy.png'
    },
},

['halloween-witchsbrew'] = {
    label = "Witch's Brew",
    weight = 120,
    client = {
        status = { thirst = 250000 },
        anim = 'drinking',
        prop = 'cup',
        usetime = 3000,
        notification = "You drank some Witch's Brew... spooky!",
        image = 'halloween-witchsbrew.png'
    },
},

['halloween-caramelpopcorn'] = {
    label = 'Caramel Popcorn',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You enjoyed some caramel popcorn!',
        image = 'halloween-caramelpopcorn.png'
    },
},

['halloween-pumpkinlollipop'] = {
    label = 'Pumpkin Lollipop',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You licked a pumpkin lollipop!',
        image = 'halloween-pumpkinlollipop.png'
    },
},

['halloween-sugarspider'] = {
    label = 'Sugar Spider',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You ate a sugar spider!',
        image = 'halloween-sugarspider.png'
    },
},


['halloween-sweetfangs'] = {
    label = 'Sweet Fangs',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You bit into some sweet fangs!',
        image = 'halloween-sweetfangs.png'
    },
},


['halloween-vampireblood'] = {
    label = 'Vampire Blood',
    weight = 100,
    client = {
        status = { thirst = 250000 },
        anim = 'drinking',
        prop = 'cup',
        usetime = 3000,
        notification = 'You drank some Vampire Blood... deliciously eerie!',
        image = 'halloween-vampireblood.png'
    },
},

['halloween-ghostlygummies'] = {
    label = 'Ghostly Gummies',
    weight = 100,
    client = {
        status = { hunger = 250000 },
        anim = 'eating',
        prop = 'ramen',
        usetime = 3000,
        notification = 'You chewed on some ghostly gummies!',
        image = 'halloween-ghostlygummies.png'
    },
},

```
