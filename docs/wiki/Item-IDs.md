# Item IDs and resource kinds

Game **0.8.117**. 212 actual EItemType enum entries; IDs are sparse, so gaps are intentional.

EItemType reflected name/value pairs in the locally installed Steam executable. Enum entries include internal/unused values, not just deliverable items. Numeric IDs are authoritative; runtime mobs.items reads the live deliverable subset and localized names.

**This is the full enum, not a claim that every entry can be delivered.** Recipes, equipment and internal/unused entries are included and marked. Use `mobs.items <search>` in your loaded game to obtain the supported deliverable subset and localized display names. Enum identifiers are not necessarily valid item-name aliases; use the numeric ID.

Example: `mobs.items 17`, then `mobs.pile 17 100` for planks. Live `mobs.items bread` finds the bread type/name available in your game. Do not assume item IDs are region IDs, card numbers, animal roles or node kinds.

## Spawnable natural resource kinds

| Argument | Node kind ID (reference only) | Notes |
| --- | --- | --- |
| salt | 1 | Surface clumps; underground reserves are separate |
| iron | 2 | Surface clumps; underground reserves are separate |
| clay | 3 | Surface clumps; underground reserves are separate |
| fish | 5 | Suitable water / pond attachment required |
| berries | 6 | Berry clumps and harvesting node |
| stone | 7 | Surface stone |
| mushrooms | 9 | Mushroom clumps |
| eel | 11 | Distinct from fish; repair_fishing, live confirmation pending |

Pass the **text argument** to resource commands, not the numeric node-kind ID. Deer (kind 4) and hare (kind 10) hunting nodes use `mobs.spawn_wildlife`, with native population settings and placement at your click. `mobs.animal` makes individuals only. The 0.16 alpha awaits hunting/save-load testing.

## Full item enum

| Item ID | Internal item identifier | Classification |
| --- | --- | --- |
| 0 | None | Sentinel / no item |
| 1 | WheatGrain | Check live mobs.items for deliverability |
| 2 | StagCarcass | Check live mobs.items for deliverability |
| 3 | Hides | Check live mobs.items for deliverability |
| 4 | Leather | Check live mobs.items for deliverability |
| 5 | WheatFlour | Check live mobs.items for deliverability |
| 6 | Irontools | Check live mobs.items for deliverability |
| 7 | WoodenParts | Check live mobs.items for deliverability |
| 8 | Recipe_Clothes_Woolen | Recipe / internal entry |
| 9 | Pelts | Check live mobs.items for deliverability |
| 10 | Shoes | Check live mobs.items for deliverability |
| 11 | Flax | Check live mobs.items for deliverability |
| 12 | Cloth_Linen | Check live mobs.items for deliverability |
| 13 | Charcoal | Check live mobs.items for deliverability |
| 14 | IronOre | Check live mobs.items for deliverability |
| 15 | Rubble | Check live mobs.items for deliverability |
| 16 | Timber | Check live mobs.items for deliverability |
| 17 | planks | Check live mobs.items for deliverability |
| 18 | Herbs | Check live mobs.items for deliverability |
| 20 | fellingAxe | Check live mobs.items for deliverability |
| 21 | huntingBow | Check live mobs.items for deliverability |
| 22 | Mallet | Check live mobs.items for deliverability |
| 23 | Wool | Check live mobs.items for deliverability |
| 24 | Saw | Check live mobs.items for deliverability |
| 25 | Knife | Check live mobs.items for deliverability |
| 26 | Sickle | Check live mobs.items for deliverability |
| 27 | RoughStone | Check live mobs.items for deliverability |
| 28 | Ale | Check live mobs.items for deliverability |
| 29 | Malt | Check live mobs.items for deliverability |
| 30 | fish | Check live mobs.items for deliverability |
| 31 | plow | Check live mobs.items for deliverability |
| 32 | Eel | Check live mobs.items for deliverability |
| 33 | RyeFlour | Check live mobs.items for deliverability |
| 34 | Recipe_Clothes_Linen | Recipe / internal entry |
| 35 | IronSlabs | Check live mobs.items for deliverability |
| 36 | Deer | Check live mobs.items for deliverability |
| 42 | Chicken | Check live mobs.items for deliverability |
| 43 | Hare | Check live mobs.items for deliverability |
| 44 | HareCarcass | Check live mobs.items for deliverability |
| 45 | Pears | Check live mobs.items for deliverability |
| 46 | Quinces | Check live mobs.items for deliverability |
| 52 | body_male_lv1_variations | Check live mobs.items for deliverability |
| 72 | Sheep | Check live mobs.items for deliverability |
| 89 | body_female_lv1_variations | Check live mobs.items for deliverability |
| 93 | headwear_female_lv1_variations | Check live mobs.items for deliverability |
| 98 | Horse | Check live mobs.items for deliverability |
| 108 | HorsewithCarriageReins | Check live mobs.items for deliverability |
| 109 | BigCart | Check live mobs.items for deliverability |
| 110 | bigCart_Axel | Check live mobs.items for deliverability |
| 133 | spears | Check live mobs.items for deliverability |
| 136 | ShepherdsCrook | Check live mobs.items for deliverability |
| 137 | HorseReins_Rider | Check live mobs.items for deliverability |
| 138 | Pickaxe | Check live mobs.items for deliverability |
| 139 | HideWashed | Check live mobs.items for deliverability |
| 140 | BeekeeperMask | Check live mobs.items for deliverability |
| 141 | Honey | Check live mobs.items for deliverability |
| 142 | Wax | Check live mobs.items for deliverability |
| 143 | Honeycomb | Check live mobs.items for deliverability |
| 144 | Robe | Check live mobs.items for deliverability |
| 145 | Salt | Check live mobs.items for deliverability |
| 146 | Clay | Check live mobs.items for deliverability |
| 147 | meat | Check live mobs.items for deliverability |
| 148 | Yarn | Check live mobs.items for deliverability |
| 149 | Clothes | Check live mobs.items for deliverability |
| 150 | Saddle | Check live mobs.items for deliverability |
| 153 | Candle | Check live mobs.items for deliverability |
| 154 | BasketArmour | Check live mobs.items for deliverability |
| 156 | Warhorse | Check live mobs.items for deliverability |
| 157 | Banner | Check live mobs.items for deliverability |
| 163 | gambesons | Check live mobs.items for deliverability |
| 164 | mail_armor | Check live mobs.items for deliverability |
| 165 | Barley | Check live mobs.items for deliverability |
| 166 | Hops | Check live mobs.items for deliverability |
| 167 | Beer | Check live mobs.items for deliverability |
| 170 | RyeBread | Check live mobs.items for deliverability |
| 171 | Berries | Check live mobs.items for deliverability |
| 172 | WheatBread | Check live mobs.items for deliverability |
| 173 | Pastries | Check live mobs.items for deliverability |
| 175 | Silk | Check live mobs.items for deliverability |
| 176 | Spices | Check live mobs.items for deliverability |
| 177 | weapons_sidearms | Check live mobs.items for deliverability |
| 178 | weapons_polearms | Check live mobs.items for deliverability |
| 204 | hat_variations_lv2 | Check live mobs.items for deliverability |
| 205 | warbows | Check live mobs.items for deliverability |
| 206 | crossbows | Check live mobs.items for deliverability |
| 207 | hood_up | Check live mobs.items for deliverability |
| 213 | bludgeon_2h_maul | Check live mobs.items for deliverability |
| 216 | Firewood | Check live mobs.items for deliverability |
| 217 | WheatSheaves | Check live mobs.items for deliverability |
| 218 | Handcart | Check live mobs.items for deliverability |
| 219 | Woad | Check live mobs.items for deliverability |
| 220 | Eggs | Check live mobs.items for deliverability |
| 221 | Milk | Check live mobs.items for deliverability |
| 222 | Goat | Check live mobs.items for deliverability |
| 223 | shortAxe | Check live mobs.items for deliverability |
| 224 | work_hoe | Check live mobs.items for deliverability |
| 225 | work_flail | Check live mobs.items for deliverability |
| 226 | work_rollingPin | Check live mobs.items for deliverability |
| 227 | work_woodenSpade | Check live mobs.items for deliverability |
| 228 | water | Check live mobs.items for deliverability |
| 229 | empty_bucket | Check live mobs.items for deliverability |
| 230 | vegetables | Check live mobs.items for deliverability |
| 231 | empty_bag | Check live mobs.items for deliverability |
| 232 | Lamb | Check live mobs.items for deliverability |
| 233 | corpse | Check live mobs.items for deliverability |
| 234 | Ox | Check live mobs.items for deliverability |
| 236 | oxwhip | Check live mobs.items for deliverability |
| 237 | debranching_target | Check live mobs.items for deliverability |
| 246 | hat_variations | Check live mobs.items for deliverability |
| 247 | scabbard | Check live mobs.items for deliverability |
| 250 | retinue_polearms | Check live mobs.items for deliverability |
| 252 | embeded_arrow | Check live mobs.items for deliverability |
| 254 | tradingWagon | Check live mobs.items for deliverability |
| 255 | Brushwood | Check live mobs.items for deliverability |
| 256 | backpack | Check live mobs.items for deliverability |
| 257 | smallLog | Check live mobs.items for deliverability |
| 258 | CONSUM_ale | Check live mobs.items for deliverability |
| 259 | mug | Check live mobs.items for deliverability |
| 260 | distaff | Check live mobs.items for deliverability |
| 261 | slag | Check live mobs.items for deliverability |
| 262 | body_male_smith | Check live mobs.items for deliverability |
| 263 | hammer | Check live mobs.items for deliverability |
| 264 | iron_rod | Check live mobs.items for deliverability |
| 267 | basket | Check live mobs.items for deliverability |
| 268 | Fieldstone_DEPREC | Check live mobs.items for deliverability |
| 269 | clayTILES | Check live mobs.items for deliverability |
| 270 | shields_small | Check live mobs.items for deliverability |
| 271 | shields_large | Check live mobs.items for deliverability |
| 273 | militia_helmets_resource | Check live mobs.items for deliverability |
| 274 | townguard_weapon | Check live mobs.items for deliverability |
| 276 | helmets_retinue_tier1 | Check live mobs.items for deliverability |
| 277 | archer_sidearm | Check live mobs.items for deliverability |
| 278 | retinue_sidearms | Check live mobs.items for deliverability |
| 279 | mushrooms | Check live mobs.items for deliverability |
| 280 | accessories_civilian_lv1_hoodDown | Check live mobs.items for deliverability |
| 281 | heads_male_variations | Check live mobs.items for deliverability |
| 282 | hair_male_variations | Check live mobs.items for deliverability |
| 283 | DressedStone | Check live mobs.items for deliverability |
| 284 | handcart_axel | Check live mobs.items for deliverability |
| 285 | helmets_militia_tier0 | Check live mobs.items for deliverability |
| 286 | heads_female_variations | Check live mobs.items for deliverability |
| 287 | Hound | Check live mobs.items for deliverability |
| 288 | mercenary_helmet_poor | Check live mobs.items for deliverability |
| 289 | mercenary_helmet_medium | Check live mobs.items for deliverability |
| 290 | shields_retinue_small | Check live mobs.items for deliverability |
| 291 | arrow | Check live mobs.items for deliverability |
| 292 | retinue_hats | Check live mobs.items for deliverability |
| 293 | PlateArmor | Check live mobs.items for deliverability |
| 294 | helmets_retinue_tier3 | Check live mobs.items for deliverability |
| 295 | plow_axel | Check live mobs.items for deliverability |
| 296 | apples | Check live mobs.items for deliverability |
| 297 | empty_stone_basket | Check live mobs.items for deliverability |
| 298 | RyeSheaves | Check live mobs.items for deliverability |
| 299 | RyeGrain | Check live mobs.items for deliverability |
| 300 | Dung | Check live mobs.items for deliverability |
| 301 | Fertilizer | Check live mobs.items for deliverability |
| 302 | dyes | Check live mobs.items for deliverability |
| 303 | horse_harness_wagon | Check live mobs.items for deliverability |
| 304 | body_male_lv2_variations | Check live mobs.items for deliverability |
| 305 | horse_cart_axel | Check live mobs.items for deliverability |
| 306 | mule | Check live mobs.items for deliverability |
| 307 | head_male_chubby | Check live mobs.items for deliverability |
| 308 | body_male_lv1_chubby | Check live mobs.items for deliverability |
| 309 | head_female_chubby | Check live mobs.items for deliverability |
| 310 | body_female_lv1_chubby | Check live mobs.items for deliverability |
| 311 | body_male_variations_combat | Check live mobs.items for deliverability |
| 312 | banner_carrier_sword | Check live mobs.items for deliverability |
| 313 | stirring_stick | Check live mobs.items for deliverability |
| 314 | crossbow_bolt | Check live mobs.items for deliverability |
| 315 | fishingRod | Check live mobs.items for deliverability |
| 316 | fishingFish | Check live mobs.items for deliverability |
| 317 | iron_parts | Check live mobs.items for deliverability |
| 318 | hunting_limit | Check live mobs.items for deliverability |
| 319 | fishing_limit | Check live mobs.items for deliverability |
| 320 | sausage | Check live mobs.items for deliverability |
| 321 | Pig | Check live mobs.items for deliverability |
| 322 | siege_ladders | Check live mobs.items for deliverability |
| 323 | smokedfish | Check live mobs.items for deliverability |
| 324 | zweiback | Check live mobs.items for deliverability |
| 325 | mead | Check live mobs.items for deliverability |
| 326 | lebkuchen | Check live mobs.items for deliverability |
| 327 | cider | Check live mobs.items for deliverability |
| 328 | chisel | Check live mobs.items for deliverability |
| 329 | Mortar | Check live mobs.items for deliverability |
| 330 | SmallGame | Check live mobs.items for deliverability |
| 331 | Venison | Check live mobs.items for deliverability |
| 332 | Mutton | Check live mobs.items for deliverability |
| 333 | Chevon | Check live mobs.items for deliverability |
| 334 | Pork | Check live mobs.items for deliverability |
| 335 | Beef | Check live mobs.items for deliverability |
| 336 | ChickenMeat | Check live mobs.items for deliverability |
| 337 | Carrots | Check live mobs.items for deliverability |
| 338 | Cabbages | Check live mobs.items for deliverability |
| 339 | Beetroots | Check live mobs.items for deliverability |
| 340 | VirtualRequirementItem_Faith_Lv1 | Check live mobs.items for deliverability |
| 341 | VirtualRequirementItem_Faith_Lv2 | Check live mobs.items for deliverability |
| 342 | VirtualRequirementItem_Faith_Lv3 | Check live mobs.items for deliverability |
| 343 | VirtualRequirementItem_Faith_Lv4 | Check live mobs.items for deliverability |
| 345 | TimberCart | Check live mobs.items for deliverability |
| 346 | TimberCart_Axel | Check live mobs.items for deliverability |
| 347 | Cow | Check live mobs.items for deliverability |
| 348 | Cheese | Check live mobs.items for deliverability |
| 349 | OatGrain | Check live mobs.items for deliverability |
| 350 | OatSheaves | Check live mobs.items for deliverability |
| 351 | AnimalFeed | Check live mobs.items for deliverability |
| 352 | Calf | Check live mobs.items for deliverability |
| 353 | CONSUM_mead | Check live mobs.items for deliverability |
| 354 | CONSUM_cider | Check live mobs.items for deliverability |
| 355 | Recipe_Sausage_Beef | Recipe / internal entry |
| 356 | Recipe_Sausage_Pork | Recipe / internal entry |
| 357 | Recipe_Smoked_Eel | Recipe / internal entry |
| 358 | Recipe_Smoked_Carp | Recipe / internal entry |

Machine-readable sources: [JSON](https://github.com/Zacxxx/ml-console-commands-by-mobs/blob/main/config/item_ids.json) · [CSV](https://github.com/Zacxxx/ml-console-commands-by-mobs/blob/main/docs/wiki/item_ids.csv).
