"""wikigen.py REPO_KEY CHECKOUT WIKI: a repository's wiki generated from its docs, whole: one page
per doc (links rewritten, the "← Documentation" line dropped), Home from docs/README.md, the
sidebar, and for recomp the Recompilation-status page from RECOMPILATION.md's Milestones and
Progress. Pages the config no longer names are deleted."""
import pathlib, re, sys

ORG = 'https://github.com/bloodborne-native'
REPOS = {
    'app': ('bloodborne-mac', {
        'docs/STATUS.md': 'Status', 'docs/ROADMAP.md': 'Roadmap', 'docs/ARCHITECTURE.md': 'Architecture',
        'docs/BUILDING.md': 'Building-and-releasing', 'docs/CREDITS.md': 'Credits-and-licenses',
        'docs/guide/installation.md': 'Installation', 'docs/guide/game-files.md': 'Game-files',
        'docs/guide/settings.md': 'Settings', 'docs/guide/saves.md': 'Profiles-and-saves',
        'docs/guide/mods-and-patches.md': 'Mods-and-patches', 'docs/guide/performance.md': 'Performance',
        'docs/guide/troubleshooting.md': 'Troubleshooting', 'docs/guide/updates.md': 'Updates'},
        [('Playing', ['Installation', 'Game-files', 'Settings', 'Profiles-and-saves', 'Mods-and-patches',
                      'Performance', 'Troubleshooting', 'Updates']),
         ('Project', ['Status', 'Roadmap']),
         ('Developing', ['Architecture', 'Building-and-releasing', 'Credits-and-licenses'])]),
    'runtime': ('bloodborne-runtime', {
        'docs/ARCHITECTURE.md': 'Architecture', 'docs/BUILDING.md': 'Building', 'docs/STABILITY.md': 'Stability',
        'docs/PERFORMANCE.md': 'Performance', 'docs/NATIVE_RENDERER.md': 'Native-renderer',
        'docs/RENDER_ADAPTER.md': 'Render-adapter', 'docs/TROPHIES.md': 'Trophies', 'docs/UPSTREAM.md': 'Upstream',
        'docs/CREDITS.md': 'Credits-and-licenses', 'docs/layers/README.md': 'PS4-layers',
        'docs/layers/executable.md': 'Layer-executable', 'docs/layers/system.md': 'Layer-system',
        'docs/layers/c-libraries.md': 'Layer-C-and-file-libraries', 'docs/layers/renderer.md': 'Layer-renderer',
        'docs/layers/gpu-commands.md': 'Layer-GPU-commands', 'docs/layers/user-data.md': 'Layer-user-data',
        'docs/layers/shaders.md': 'Layer-shaders', 'docs/layers/textures-memory.md': 'Layer-textures-and-memory'},
        [('Documentation', ['Architecture', 'Building', 'Native-renderer', 'Render-adapter', 'Performance',
                            'Stability', 'Trophies', 'Upstream', 'Credits-and-licenses']),
         ('The PS4 layers', ['PS4-layers', 'Layer-executable', 'Layer-system', 'Layer-C-and-file-libraries',
                             'Layer-renderer', 'Layer-GPU-commands', 'Layer-user-data', 'Layer-shaders',
                             'Layer-textures-and-memory'])]),
    'recomp': ('bloodborne-recomp', {
        'docs/RECOMPILATION.md': 'Recompilation',
        'docs/CREDITS.md': 'Credits-and-licenses', 'docs/layers/README.md': 'PS4-layers',
        'docs/layers/game-code.md': 'Layer-game-code', 'docs/layers/memory-ordering.md': 'Layer-memory-ordering'},
        [('Documentation', ['Recompilation-status', 'Recompilation', 'Credits-and-licenses']),
         ('The PS4 layers', ['PS4-layers', 'Layer-game-code', 'Layer-memory-ordering'])]),
    'bbcpu': ('bbcpu', {
        'docs/ARCHITECTURE.md': 'Architecture', 'docs/API.md': 'Writing-a-host',
        'docs/CREDITS.md': 'Credits-and-licenses'},
        [('Documentation', ['Architecture', 'Writing-a-host', 'Credits-and-licenses'])]),
    'launcher': ('bloodborne-launcher', {},
        [('Documentation', [])]),
}


def title(page):
    return page.replace('-', ' ')


def convert(repo, pages, doc, text):
    base = pathlib.PurePosixPath(doc).parent
    text = '\n'.join(l for l in text.split('\n') if not l.startswith('[← '))
    text = re.sub(r'\n{3,}', '\n\n', text)

    def link(m):
        image, label, target = m.group(1), m.group(2), m.group(3)
        if re.match(r'[a-z]+:', target) or target.startswith('#'):
            return m.group(0)
        if target.split('#')[0] in set(pages.values()) | {'Home', 'Recompilation-status'}:
            return m.group(0)  # already a wiki page
        path, _, anchor = target.partition('#')
        full = str(pathlib.PurePosixPath(*(base / path).parts))
        while re.search(r'[^/]+/\.\./', full):
            full = re.sub(r'[^/]+/\.\./', '', full, count=1)
        full = full.lstrip('./') if full.startswith('./') else full
        if full in pages and not image:
            return f'[{label}]({pages[full]}' + (f'#{anchor}' if anchor else '') + ')'
        if full in ('docs/README.md', 'README.md') and not image and full == 'docs/README.md':
            return f'[{label}](Home)'
        if image:
            return f'![{label}](https://raw.githubusercontent.com/bloodborne-native/{repo}/main/{full})'
        kind = 'tree' if '.' not in full.rsplit('/', 1)[-1] else 'blob'
        return f'[{label}]({ORG}/{repo}/{kind}/main/{full}' + (f'#{anchor}' if anchor else '') + ')'
    return re.sub(r'(!?)\[([^\]]+)\]\(([^)\s]+)\)', link, text)


def section(text, heading):
    m = re.search(rf'^## {re.escape(heading)}\n(.*?)(?=^## )', text, re.M | re.S)
    return m.group(1).strip() if m else ''


def main():
    key, checkout, wiki = sys.argv[1], pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
    repo, pages, groups = REPOS[key]
    if key == 'launcher':  # every doc but the index, by its file name
        for p in sorted((checkout / 'docs').glob('*.md')):
            if p.name == 'README.md':
                continue
            page = {'CREDITS': 'Credits-and-licenses'}.get(p.stem, p.stem.lower().replace('_', '-').capitalize())
            pages[f'docs/{p.name}'] = page
            groups[0][1].append(page)
    out = {}
    for doc, page in pages.items():
        out[page] = convert(repo, pages, doc, (checkout / doc).read_text())
    out['Home'] = convert(repo, pages, 'docs/README.md', (checkout / 'docs/README.md').read_text())
    out['Home'] = re.sub(r'^# .*', f'# {repo}', out['Home'], count=1)
    if key == 'app':
        def order(p):  # newest first; a final release before its candidates (0.9.0, then 0.9.0-rc.2)
            version, _, candidate = p.stem[1:].partition('-')
            numbers = [int(x) for x in version.split('.')]
            return numbers, not candidate, [int(x) if x.isdigit() else x for x in candidate.split('.')]
        rel = sorted((checkout / 'docs/releases').glob('v*.md'), reverse=True, key=order)
        names = []
        for p in rel:
            page = 'Release-' + p.stem[1:]
            out[page] = convert(repo, pages, f'docs/releases/{p.name}', p.read_text())
            names.append(page)
        groups = groups + [('Releases', names)]
    if key == 'recomp':
        doc = (checkout / 'docs/RECOMPILATION.md').read_text()
        body = ('# Recompilation status\n\nGenerated from [Recompilation](Recompilation): its layers and '
                'progress.\n\n## The layers\n\n' + section(doc, 'The layers') + '\n\n## Progress\n\n'
                + section(doc, 'Progress') + '\n')
        out['Recompilation-status'] = convert(repo, pages, 'docs/RECOMPILATION.md', body)
    side = ['[Home](Home)', '']
    for name, items in groups:
        side += [f'**{name}**', ''] + [f'- [{title(i).replace("Release ", "")}]({i})' for i in items] + ['']
    side += ['**Repositories**', '']
    for r in ('bloodborne-mac', 'bloodborne-runtime', 'bbcpu', 'bloodborne-recomp', 'bloodborne-launcher'):
        side.append(f'- [{r}]({ORG}/{r}) ([wiki]({ORG}/{r}/wiki))')
    out['_Sidebar'] = '\n'.join(side) + '\n'
    for old in wiki.glob('*.md'):
        if old.stem not in out:
            old.unlink()
            print('removed', old.name)
    for page, text in out.items():
        (wiki / f'{page}.md').write_text(text.rstrip('\n') + '\n')
    print(len(out), 'pages')


main()
