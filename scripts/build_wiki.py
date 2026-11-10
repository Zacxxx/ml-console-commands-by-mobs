#!/usr/bin/env python3
"""Generate the versioned wiki from the live registry and shared runtime guides."""
import argparse
import csv
import io
import json
from pathlib import Path
import re
import subprocess
ROOT=Path(__file__).resolve().parents[1]
WIKI='https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki'
def rows():
    result=subprocess.run(['lua','scripts/export_command_reference.lua'],cwd=ROOT,text=True,capture_output=True,check=True)
    return [dict(zip(('name','category','usage','description'),row)) for row in csv.reader(io.StringIO(result.stdout),delimiter='\t')]
def short(name): return name.removeprefix('mobs.')
def page(name): return 'Command-'+short(name)
def render():
    commands=rows(); guides=json.loads((ROOT/'config/command_guides.json').read_text())
    tutorial=json.loads((ROOT/'config/tutorial.json').read_text()); items=json.loads((ROOT/'config/item_ids.json').read_text())
    version=re.search(r'local VERSION = "([^"]+)"',(ROOT/'src/mobs_console/Scripts/main.lua').read_text())[1]
    if set(guides)!=set(row['name'] for row in commands): raise ValueError('Registry and guide coverage differ')
    by_name={row['name']:row for row in commands}; files={}
    for row in commands:
        name=row['name']; guide=guides[name]
        lines=['# '+name,'',f'Guide for **{version}**, game **0.8.117**.','',row['description'],'','```text',row['usage'],'```','',
               '## In-game advice','',f'`mobs.advice.{short(name)}` or `mobs.advice {short(name)}`. These display help without executing the action.','',
               '## Target','',guide['target'],'','## Steps','',guide['steps'],'','## Examples','',
               'Examples below are command text to enter yourself; reading this page never runs them.','','```text',*guide['examples'],'```','',
               '## Limits and expected results','',guide['notes'],'','## Related commands','']
        for target in guide['related']:
            canonical='mobs.'+target
            if canonical not in by_name: raise ValueError('Unknown related command '+canonical)
            lines.append(f'- [{canonical}]({WIKI}/{page(canonical)}) — `mobs.advice.{target}`')
        lines += ['',f'[All commands]({WIKI}/Commands) · [Tutorial]({WIKI}/Tutorial) · [Item IDs]({WIKI}/Item-IDs)','']
        files[page(name)+'.md']='\n'.join(lines)
    lines=['# All commands','',f'**{version} — {len(commands)} documented base names/aliases.** Each command has a detailed advice page. Dotted advice shortcuts are omitted from the base list to keep it readable.','',
           'Required input uses `<...>`, optional input uses `[...]`; replace placeholders and omit brackets. Examples live on each linked guide.','']
    for category in ('lord','region','army','misc'):
        lines += ['## '+category.title(),'','| Command and advice | Syntax | Behavior |','| --- | --- | --- |']
        for row in commands:
            if row['category']!=category: continue
            usage=row['usage'].replace('|','\\|');description=row['description'].replace('|','\\|')
            lines.append(f"| [{row['name']}]({WIKI}/{page(row['name'])})<br>`mobs.advice.{short(row['name'])}` | `{usage}` | {description} |")
        lines.append('')
    files['Commands.md']='\n'.join(lines)
    lines=['# Full tutorial','',f'For **{version}**, game **0.8.117**. In game: `mobs.tutorial` lists chapters, `mobs.tutorial all` prints everything.','']
    for i,c in enumerate(tutorial,1):
        lines += [f"## {i}. {c['title']}",'',f"In game: `mobs.tutorial {c['key']}` or `mobs.tutorial {i}`.",'']
        for paragraph in c['paragraphs']:lines += [paragraph,'']
        lines += ['Guides: '+', '.join(f'[{name}]({WIKI}/{page("mobs."+name.removeprefix("mobs.advice."))})' for name in c['guides']), '']
    files['Tutorial.md']='\n'.join(lines)
    lines=['# Item IDs and resource kinds','',f"Game **{items['game_version']}**. {len(items['entries'])} actual EItemType enum entries; IDs are sparse, so gaps are intentional.",'',items['provenance'],'',
           '**This is the full enum, not a claim that every entry can be delivered.** Recipes, equipment and internal/unused entries are included and marked. Use `mobs.items <search>` in your loaded game to obtain the supported deliverable subset and localized display names. Enum identifiers are not necessarily valid item-name aliases; use the numeric ID.','',
           'Example: `mobs.items 17`, then `mobs.pile 17 100` for planks. Live `mobs.items bread` finds the bread type/name available in your game. Do not assume item IDs are region IDs, card numbers, animal roles or node kinds.','',
           '## Spawnable natural resource kinds','','| Argument | Node kind ID (reference only) | Notes |','| --- | --- | --- |',
           '| salt | 1 | Surface clumps; underground reserves are separate |','| iron | 2 | Surface clumps; underground reserves are separate |',
           '| clay | 3 | Surface clumps; underground reserves are separate |','| fish | 5 | Suitable water / pond attachment required |',
           '| berries | 6 | Berry clumps and harvesting node |','| stone | 7 | Surface stone |','| mushrooms | 9 | Mushroom clumps |',
           '| eel | 11 | Distinct from fish; repair_fishing, live confirmation pending |','',
           'Pass the **text argument** to resource commands, not the numeric node-kind ID. Deer (kind 4) and hare (kind 10) hunting nodes use `mobs.spawn_wildlife`, with native population settings and placement at your click. `mobs.animal` makes individuals only. The 0.16 alpha awaits hunting/save-load testing.','',
           '## Full item enum','','| Item ID | Internal item identifier | Classification |','| --- | --- | --- |']
    for row in items['entries']:
        name=row['name'];kind='Recipe / internal entry' if name.lower().startswith('recipe') else 'Sentinel / no item' if row['id']==0 else 'Check live mobs.items for deliverability'
        lines.append(f"| {row['id']} | {name} | {kind} |")
    lines += ['','Machine-readable sources: [JSON](https://github.com/Zacxxx/ml-console-commands-by-mobs/blob/main/config/item_ids.json) · [CSV](https://github.com/Zacxxx/ml-console-commands-by-mobs/blob/main/docs/wiki/item_ids.csv).','']
    files['Item-IDs.md']='\n'.join(lines)
    stream=io.StringIO();writer=csv.writer(stream,lineterminator='\n');writer.writerow(['id','internal_name'])
    writer.writerows((r['id'],r['name']) for r in items['entries']);files['item_ids.csv']=stream.getvalue()
    files['Home.md']=f'''# ML Console Commands by Mobs wiki

Documentation for **{version}**, targeting **Manor Lords 0.8.117**. This is an alpha; read the [report status]({WIKI}/Bug-report-status) for what is fixed in source and what still needs gameplay confirmation.

- [Start-to-finish tutorial]({WIKI}/Tutorial) — installation, syntax, selection, regions, click placement, construction, piles, resources, fishing, forestry, farming, perks and troubleshooting.
- [All {len(commands)} base commands and aliases]({WIKI}/Commands) — every entry links to detailed advice, steps and copyable examples.
- [All {len(items['entries'])} item enum IDs]({WIKI}/Item-IDs) — names, delivery caveats, resource kinds, JSON and CSV.
- [Public bug-report audit]({WIKI}/Bug-report-status) — Nexus reports and remaining validation.
- [Downloads](https://github.com/Zacxxx/ml-console-commands-by-mobs/releases) · [Source](https://github.com/Zacxxx/ml-console-commands-by-mobs) · [Report an issue](https://github.com/Zacxxx/ml-console-commands-by-mobs/issues) · [Nexus page](https://www.nexusmods.com/manorlords/mods/433).

## Fast examples

```text
mobs.version
mobs.regions
mobs.region current
mobs.status
mobs.advice.pile
mobs.advice.spawn_resource
mobs.tutorial resources
mobs.tutorial all
```

Region IDs vary per save. Select actual owned buildings before opening the console for selection commands. Click tools require closing the console and placing/clicking after the command arms. Previews change nothing; run the real command and click again to apply it.

## Common questions

- **Berries:** `mobs.spawn_resource berries 100 4`, close console, click owned ground. This creates four clumps of 100 each. [Guide]({WIKI}/Command-spawn_resource).
- **Pond fish:** finish the pond, then `mobs.pond_fish 500` and click near it. [Guide]({WIKI}/Command-pond_fish).
- **Remove rich fish/eel:** `mobs.resource remove fish preview` (or eel). Close console and click near the actual shoal; repeat without preview to apply. Exact kind and ownership matter. [Guide]({WIKI}/Command-resource).
- **Underground vs surface:** `deposit` edits reserves; `resource` edits visible clumps. [Full explanation]({WIKI}/Tutorial#6-create-berriesminerals-understand-layers-and-remove-nodes).
- **Wild animals:** `mobs.spawn_wildlife deer` or `hare` creates a native herd/node at your clicked location. Hunting/save-load checks are pending. `mobs.animal` creates individuals separately. [Guide]({WIKI}/Command-spawn_wildlife).

The runtime guides and this wiki are generated from the same maintained data. Source/static checks do not establish harvesting, visual or save/load success for every command variant.
'''
    files['_Sidebar.md']='\n'.join(['[Home]('+WIKI+')','',*[f'- [{label}]({WIKI}/{target})' for label,target in [('Tutorial','Tutorial'),('All commands','Commands'),('Item IDs','Item-IDs'),('Bug report status','Bug-report-status')]],''])
    return files
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    folder=ROOT/'docs/wiki'
    for name,content in render().items():
        path=folder/name
        if args.check:
            if not path.exists() or path.read_text()!=content:raise SystemExit('Wiki drift: '+name)
        else:folder.mkdir(parents=True,exist_ok=True);path.write_text(content)
    print('Wiki registry, guide coverage, related links and generated files verified.' if args.check else 'Wiki generated.')
