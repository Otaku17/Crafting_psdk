<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1457770649970802779/1472596616438612078/logo_github.png?ex=699325f8&is=6991d478&hm=f51643db05c10dfc41b2a3a125e1e46fba6ee140126b4f390c6b3a3665081a61&" width="300">
</p>

# Crafting System (Advanced Recipes & Unlock Logic)

> Modern crafting system for Ruby / Pokémon SDK projects  
> Fully configurable JSON recipes + advanced unlock logic + UI integration

---

<img src="https://cdn.discordapp.com/attachments/1469612417020461163/1472664631599431893/image.png?ex=69936550&is=699213d0&hm=a6721a9fa0cc0e9789938bc9dc6bcd591efe64da66538e92d820daf884a51d0f&">

## Installation / Update

1. Place the plugin in your project/scripts:

   ```
   Crafting.psdkplug
   ```

2. Run this command at the root of your project:

   ```bash
   .\psdk --util=plugin load
   ```

3. Configure crafting settings:

   ```
   Data/configs/crafting_config.json
   ```

---

## Open Crafting UI

```ruby
GamePlay.open_craft_system_ui
```

You can call this from:
- Events
- NPC interactions
- Menus
- Scripts

---

# CONFIGURATION

All crafting data is defined in:

```
Data/configs/crafting_config.json
```

---

## Categories

You can define custom recipe categories:

```json
"categories": [
  { "all": 3 },
  { "ball": 4 },
  { "medical": 5 },
  { "tm": 6 }
]
```

| Field | Required | Description |
|-------|----------|-------------|
| category_name | ✅ | Internal symbol used by recipes |
| index_csv | ✅ | CSV/UI index reference |

You can add unlimited categories.

**Example:**

```json
{ "legendary": 7 }
```

Then assign it inside a recipe:

```json
"category": "legendary"
```

---

# RECIPE STRUCTURE

```json
"poke_ball": {
  "ingredients": {
    "red_apricorn": 2
  },
  "result": "poke_ball",
  "quantity": 1,
  "category": "ball",
  "unlock_condition": {
    "type": "manual",
    "value": true
  }
}
```

---

## Recipe Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| ingredients | ✅ | Object | Required items |
| result | ✅ | String | Crafted item |
| quantity | ✅ | Integer | Amount produced |
| category | ✅ | String | Recipe category |
| unlock_condition | ✅ | Object | Unlock logic |

> Every recipe must have an unlock condition defined.

---

# UNLOCK CONDITIONS

## Switch

```json
{
  "type": "switch",
  "id": 12
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| id | ✅ | Integer | Switch ID |

---

## Variable

```json
{
  "type": "variable",
  "id": 5,
  "value": 10
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| id | ✅ | Integer | Variable ID |
| value | ✅ | Integer | Required value |

---

## Quest

```json
{
  "type": "quest",
  "id": 3
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| id | ✅ | Integer | Quest ID |

---

## Recipe Dependency

```json
{
  "type": "recipe",
  "key": "poke_ball_basic"
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| key | ✅ | String | Recipe key |

---

## Item Requirement

```json
{
  "type": "item",
  "item": "hammer_tool",
  "quantity": 1
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| item | ✅ | String | Item name |
| quantity | ✅ | Integer | Required quantity |

---

## Manual Unlock

```json
{
  "type": "manual",
  "value": true
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| type | ✅ | String | Condition type |
| value | ✅ | Boolean | Initial unlock state |

**Usage:**

- `"value": true` → Recipe is **unlocked by default**
- `"value": false` → Recipe is **locked by default**

Controlled dynamically with:

```ruby
CraftSystem.unlock(:recipe_key)
CraftSystem.lock(:recipe_key)
```

> Use manual unlock for recipes that should be available from the start or controlled via scripts/events.

---

# LOGICAL OPERATORS

## AND / ALL

```json
{
  "operator": "and",
  "conditions": []
}
```

All conditions must be met.

## OR / ANY

```json
{
  "operator": "or",
  "conditions": []
}
```

At least one condition must be met.

## NOT / NONE

```json
{
  "operator": "not",
  "conditions": []
}
```

Inverts the condition result.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| operator | ✅ | String | Logic type (and/or/not) |
| conditions | ✅ | Array | Array of conditions |

> Nested operators are fully supported.

---

## Complex Example

```json
"great_ball": {
  "ingredients": {
    "poke_ball": 1,
    "blue_apricorn": 1
  },
  "result": "great_ball",
  "quantity": 1,
  "category": "ball",
  "unlock_condition": {
    "operator": "and",
    "conditions": [
      {
        "type": "switch",
        "id": 500
      },
      {
        "type": "variable",
        "id": 988,
        "value": 3
      },
      {
        "type": "recipe",
        "key": "poke_ball"
      }
    ]
  }
}
```

This unlocks when:
- Switch 500 is ON **AND**
- Variable 988 equals 3 **AND**
- Recipe "poke_ball" is unlocked

---

# CRAFT SYSTEM API

Returns all recipes.
```ruby
CraftSystem.all_recipes
```

Check if recipe is unlocked.
```ruby
CraftSystem.unlocked?(:recipe_key)
```

Manually unlock/lock a recipe.
```ruby
CraftSystem.unlock(:recipe_key)
CraftSystem.lock(:recipe_key)
```

Check if player can craft.
```ruby
CraftSystem.can_craft?(:recipe_key, amount)
```

Craft a specific amount.
```ruby
CraftSystem.craft(:recipe_key, amount)
```

Craft maximum possible amount.
```ruby
CraftSystem.craft_all(:recipe_key)
```

Get maximum craftable amount.
```ruby
CraftSystem.max_craft(:recipe_key)
```

Get recipe data.
```ruby
CraftSystem.data_craft(:recipe_key)
```

---

# AUTOMATIC STATE MANAGEMENT

The system automatically:

- Synchronizes crafting state
- Updates dependent recipes
- Removes invalid states
- Re-evaluates unlock conditions dynamically
- Prevents circular dependency issues

---

# BEST PRACTICES

- **Always define unlock_condition**: Every recipe must have an unlock condition, use `{"type": "manual", "value": true}` for default availability
- **Avoid circular dependencies**: Don't make Recipe A depend on Recipe B while Recipe B depends on Recipe A
- **Use manual unlocks for tutorials**: Control progression with manual unlock/lock
- **Keep categories consistent**: Use the same category names across recipes
- **Use nested operators for advanced progression**: Combine AND/OR/NOT for complex unlock logic

---

## Configuration Reference

```json
{
  "categories": [
    { "all": 3 },
    { "ball": 4 },
    { "medical": 5 },
    { "tm": 6 }
  ],
  "data": {
    "poke_ball": {
      "ingredients": {
        "red_apricorn": 2
      },
      "result": "poke_ball",
      "quantity": 1,
      "category": "ball",
      "unlock_condition": {
        "type": "manual",
        "value": true
      }
    },
    "great_ball": {
      "ingredients": {
        "poke_ball": 1,
        "blue_apricorn": 1
      },
      "result": "great_ball",
      "quantity": 1,
      "category": "ball",
      "unlock_condition": {
        "operator": "and",
        "conditions": [
          {
            "type": "switch",
            "id": 500
          },
          {
            "type": "variable",
            "id": 988,
            "value": 3
          },
          {
            "type": "recipe",
            "key": "poke_ball"
          }
        ]
      }
    },
    "potion": {
      "ingredients": {
        "tiny_mushroom": 2
      },
      "result": "potion",
      "quantity": 1,
      "category": "medical",
      "unlock_condition": {
        "type": "manual",
        "value": false
      }
    },
    "super_potion": {
      "ingredients": {
        "big_mushroom": 1,
        "potion": 1
      },
      "result": "super_potion",
      "quantity": 1,
      "category": "medical",
      "unlock_condition": {
        "type": "recipe",
        "key": "potion"
      }
    }
  }
}
```

> **Important:** Every recipe should have an `unlock_condition`. Use `{"type": "manual", "value": true}` for recipes available by default.

---

## License

Free to use, modify and distribute.

---

## Credits

Made with ❤️ for Pokémon SDK & Ruby projects.
