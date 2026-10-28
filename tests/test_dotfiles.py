"""Non-secret fixtures. Requires Python 3.11+, Git, Fish 3.5+ and chezmoi."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
TOOLS = {name: shutil.which(name) for name in ('chezmoi', 'fish', 'git')}


class DotfilesTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='dotfiles-test-')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.home = self.root / 'home'
        self.home.mkdir()
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        # Keep native macOS Homebrew out of Linux-style startup fixtures.
        (self.bin / 'uname').write_text('#!/bin/sh\necho Linux\n')
        (self.bin / 'uname').chmod(0o755)
        (self.home / '.local').mkdir()
        (self.home / '.local/bin').symlink_to(self.bin, target_is_directory=True)
        self.config = self.root / 'chezmoi.toml'
        self.config.write_text('umask = 0o077\n[data]\nmachine = "newport"\n')
        self.env = {'HOME': str(self.home), 'PATH': f'{self.bin}:/usr/bin:/bin',
                    'XDG_CONFIG_HOME': str(self.home / '.config'),
                    'XDG_DATA_HOME': str(self.home / '.local/share'),
                    'XDG_CACHE_HOME': str(self.root / 'cache'),
                    'XDG_STATE_HOME': str(self.root / 'state'), 'LC_ALL': 'C',
                     'TMPDIR': str(self.root), 'MISE_OFFLINE': '1',
                     'GIT_CONFIG_NOSYSTEM': '1',
                    'MISE_NOT_FOUND_AUTO_INSTALL': '0'}

    def run_command(self, args, *, env=None):
        return subprocess.run(args, cwd=self.home, env=env or self.env,
                              text=True, capture_output=True, timeout=20)

    def chezmoi(self, *args, machine='newport', os_name='linux'):
        self.config.write_text(f'umask = 0o077\n[data]\nmachine = "{machine}"\n')
        return self.run_command([
            TOOLS['chezmoi'], '--source', str(ROOT), '--destination', str(self.home),
            '--config', str(self.config), '--cache', str(self.root / 'cache'),
            '--persistent-state', str(self.root / 'chezmoi-state.boltdb'), '--no-tty',
            '--override-data', json.dumps({'chezmoi': {'os': os_name}}), *args])

    def install_fixture(self):
        p = self.chezmoi('apply', '--force')
        self.assertEqual(p.returncode, 0, p.stderr)
        snippets = self.home / '.config/fish/conf.d'
        snippets.mkdir(exist_ok=True)
        # Normal startup still runs vendor snippets; reset their PATH additions
        # before config.fish so fixture commands cannot resolve to host tools.
        (snippets / 'zz-dotfiles-test-path.fish').write_text(
            f'set -gx PATH "{self.bin}" /usr/bin /bin\n')

    def executable(self, name, text):
        path = self.bin / name
        path.write_text('#!/bin/sh\n' + text)
        path.chmod(0o755)
        return path

    def fish(self, command, interactive=False, term=None):
        env = self.env.copy()
        if term:
            env['TERM'] = term
        return self.run_command([TOOLS['fish'], *(['--interactive'] if interactive else []),
                                 '-c', command], env=env)

    def test_explicit_tools_commands_use_home_and_refuse_legacy_selectors(self):
        self.install_fixture()
        self.executable('mise', 'printf "%s:%s\\n" "$PWD" "$*" >> "$HOME/tool-calls"\n')
        script = str(ROOT / 'scripts/tools.fish')
        for mode in ('install', 'update'):
            p = self.run_command([TOOLS['fish'], '--no-config', script, mode])
            self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual((self.home / 'tool-calls').read_text().splitlines(),
                         [f'{self.home}:install --yes', f'{self.home}:upgrade --yes'])
        (self.home / '.tool-versions').write_text('node latest\n')
        p = self.run_command([TOOLS['fish'], '--no-config', script, 'install'])
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('migrate ~/.tool-versions', p.stderr)
        self.assertEqual(len((self.home / 'tool-calls').read_text().splitlines()), 2)

    def test_mac_package_tasks_use_bundle_without_implicit_upgrade_or_cleanup(self):
        self.executable('uname', 'echo Darwin\n')
        self.executable('brew', 'printf "%s\\n" "$*" >> "$HOME/native-calls"\n')
        tasks = tomllib.loads((ROOT / 'mise.toml').read_text())['tasks']
        for mode in ('install', 'update'):
            task = tasks[f'packages:{mode}']
            p = self.run_command([TOOLS['fish'], '--no-config', '-c', task['run']],
                                 env={**self.env, **task['env']})
            self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual((self.home / 'native-calls').read_text().splitlines(), [
            'bundle install --file macos/Brewfile --no-upgrade',
            'update', 'bundle upgrade --file macos/Brewfile'])

    def test_fish_maintenance_syntax_and_failure_propagation(self):
        for script in (ROOT / 'scripts').glob('*.fish'):
            p = self.run_command([TOOLS['fish'], '--no-config', '--no-execute', str(script)])
            self.assertEqual(p.returncode, 0, p.stderr)
        tasks = tomllib.loads((ROOT / 'mise.toml').read_text())
        self.executable('brew', 'echo "$*" >> "$HOME/calls"\nexit 17\n')
        self.executable('uname', 'echo Darwin\n')
        p = self.run_command([TOOLS['fish'], '--no-config', '-c',
                              tasks['tasks']['packages:update']['run']])
        self.assertEqual(p.returncode, 17, p.stderr)
        self.assertEqual((self.home / 'calls').read_text(), 'update\n')
        self.executable('hostname', 'echo newport\n')
        self.executable('rustup', 'echo "$*" >> "$HOME/rust-calls"\nexit 19\n')
        for mode in ('install', 'update'):
            p = self.run_command([TOOLS['fish'], '--no-config',
                                  str(ROOT / 'scripts/rust.fish'), mode])
            self.assertEqual(p.returncode, 19, p.stderr)
        self.assertEqual((self.home / 'rust-calls').read_text().splitlines(),
                         ['toolchain list', 'update stable'])

    def test_apt_installer_only_installs_missing_or_updates_declared_packages(self):
        self.executable('uname', 'echo Linux\n')
        self.executable('hostname', 'echo newport\n')
        self.executable('sudo', 'printf "%s\\n" "$*" >> "$HOME/native-calls"\n')
        self.executable('dpkg-query', '''case "$3" in
    fish|age|ffmpeg) printf 'install ok installed' ;;
    *) exit 1 ;;
esac
''')
        for mode in ('install', 'update'):
            p = self.run_command([TOOLS['fish'], '--no-config', str(ROOT / 'scripts/packages-apt.fish'), mode])
            self.assertEqual(p.returncode, 0, p.stderr)
        prefix = ('env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l apt-get '
                  'install --yes --no-remove --no-install-recommends ')
        self.assertEqual((self.home / 'native-calls').read_text().splitlines(), [
            prefix + 'gnupg tokei', 'apt-get update',
            prefix + '--only-upgrade fish age ffmpeg'])

    def test_compose_plugin_symlink_is_mac_only(self):
        target = self.home / '.docker/cli-plugins/docker-compose'
        config = self.home / '.docker/config.json'
        config.parent.mkdir()
        config.write_text('{"currentContext":"fixture"}\n')
        for machine, os_name in [('drill', 'darwin'), ('blue', 'darwin'),
                                 ('newport', 'linux'), ('mug', 'linux')]:
            p = self.chezmoi('apply', '--force', machine=machine, os_name=os_name)
            self.assertEqual(p.returncode, 0, p.stderr)
            self.assertEqual(config.read_text(), '{"currentContext":"fixture"}\n')
            self.assertEqual(target.is_symlink(), os_name == 'darwin')
            if target.is_symlink():
                self.assertEqual(str(target.readlink()),
                                 '/opt/homebrew/opt/docker-compose/bin/docker-compose')
                target.unlink()

    def test_fish_plugin_tasks_are_explicit_and_preserve_extra_plugins(self):
        self.install_fixture()
        path = self.home / '.config/fish/functions/fisher.fish'
        path.write_text('''function fisher
    switch $argv[1]
        case list
            printf '%s\\n' jorgebucaran/fisher meaningful-ooo/sponge fixture/extra
        case '*'
            string join ' ' -- $argv >> "$HOME/plugin-calls"
    end
end
''')
        script = str(ROOT / 'scripts/fish-plugins.fish')
        p = self.run_command([TOOLS['fish'], script, 'install'])
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertFalse((self.home / 'plugin-calls').exists())
        p = self.run_command([TOOLS['fish'], script, 'update'])
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual((self.home / 'plugin-calls').read_text(),
                         'update jorgebucaran/fisher meaningful-ooo/sponge\n')

    def test_fish_preserves_environment_and_adds_existing_paths_once(self):
        self.install_fixture()
        for name in ['.cargo/bin', '.opencode/bin', '.local/lib/pkgconfig']:
            (self.home / name).mkdir(parents=True, exist_ok=True)
        env = {**self.env, 'TERM': 'xterm-ghostty', 'BASH_ENV': '/private/existing-bridge',
               'PKG_CONFIG_PATH': '/existing/pkgconfig'}
        p = self.run_command([TOOLS['fish'], '--no-config', '-c', '''
source ~/.config/fish/config.fish
source ~/.config/fish/config.fish
test "$TERM" = xterm-ghostty; or exit 1
test "$BASH_ENV" = /private/existing-bridge; or exit 2
contains -- "$HOME/.local/bin" $PATH; or exit 3
contains -- "$HOME/.cargo/bin" $PATH; or exit 4
contains -- "$HOME/.opencode/bin" $PATH; or exit 5
contains -- "$HOME/bin" $PATH; and exit 6
test (count $PKG_CONFIG_PATH) -eq 2; or exit 7
test "$PKG_CONFIG_PATH[1]" = "$HOME/.local/lib/pkgconfig"; or exit 8
test "$PKG_CONFIG_PATH[2]" = /existing/pkgconfig; or exit 9
'''], env=env)
        self.assertEqual(p.returncode, 0, p.stderr)

    def test_shared_ssh_aliases_preserve_host_config(self):
        ssh = shutil.which('ssh')
        if not ssh:
            self.skipTest('requires ssh -G (no connection made)')
        folder = self.home / '.ssh'
        folder.mkdir(mode=0o700)
        config = folder / 'config'
        original = 'Host private-work\n    HostName work.example.invalid\n'
        config.write_text(original)
        self.install_fixture()
        self.assertEqual(config.read_text(), original)
        fragment = folder / 'config.d/fleet.conf'
        for name in ['drill', 'blue', 'newport', 'mug']:
            p = self.run_command([ssh, '-G', '-F', str(fragment), name])
            self.assertEqual(p.returncode, 0, p.stderr)
            values = dict(line.split(' ', 1) for line in p.stdout.splitlines())
            self.assertEqual(values['hostname'], f'{name}.hedgehog-python.ts.net')
            self.assertEqual(values['user'], 'jackharrhy' if name == 'drill' else 'jack')
        self.assertEqual(folder.stat().st_mode & 0o777, 0o700)

    def test_profiles_disable_auto_installs_and_preserve_skill_payloads(self):
        existing = self.home / '.agents/skills/local-user/SKILL.md'
        existing.parent.mkdir(parents=True)
        existing.write_text('unmanaged user skill\n')
        bundled = self.home / '.codex/skills/.system/keep'
        bundled.parent.mkdir(parents=True)
        bundled.write_text('bundled\n')
        for machine, os_name in [('drill', 'darwin'), ('blue', 'darwin'), ('newport', 'linux'), ('mug', 'linux')]:
            with self.subTest(machine=machine):
                p = self.chezmoi('apply', '--force', machine=machine, os_name=os_name)
                self.assertEqual(p.returncode, 0, p.stderr)
                config = tomllib.loads((self.home / '.config/mise/config.toml').read_text())
                for setting in ('auto_install', 'exec_auto_install', 'not_found_auto_install'):
                    self.assertFalse(config['settings'][setting])
                self.assertFalse(config['settings']['task']['run_auto_install'])
                if machine == 'mug':
                    self.assertFalse({'rust', 'core:erlang', 'elixir', 'github:odin-lang/Odin'}
                                     & config['tools'].keys())
                lock = json.loads((self.home / 'skills-lock.json').read_text())
                self.assertEqual('reverse-engineer-anything' in lock['skills'],
                                 machine == 'newport')
                self.assertEqual(existing.read_text(), 'unmanaged user skill\n')
                self.assertEqual(bundled.read_text(), 'bundled\n')
                self.assertFalse((self.home / '.claude').exists())
                self.assertEqual(list((self.home / '.agents/skills').iterdir()), [existing.parent])

    def test_explicit_skill_install_runs_from_home_without_backups(self):
        self.install_fixture()
        self.executable('skills', '''test "$1" = experimental_install || exit 11
test "$DISABLE_TELEMETRY" = 1 || exit 12
test "$DO_NOT_TRACK" = 1 || exit 13
pwd > "$HOME/skill-restore-cwd"
''')
        p = self.run_command([TOOLS['fish'], '--no-config', str(ROOT / 'scripts/install-skills.fish')])
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual((self.home / 'skill-restore-cwd').read_text().strip(), str(self.home))
        self.assertFalse((self.root / 'state/dotfiles-skills').exists())

    def test_explicit_skill_install_requires_home_manifest(self):
        self.executable('skills', 'touch "$HOME/unexpected-skill-install"\n')
        p = self.run_command([TOOLS['fish'], '--no-config', str(ROOT / 'scripts/install-skills.fish')])
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('skills-lock.json', p.stderr)
        self.assertFalse((self.home / 'unexpected-skill-install').exists())

    def test_full_startup_and_local_override(self):
        self.install_fixture()
        fishdir = self.home / '.config/fish'
        (fishdir / 'conf.d/fixture.fish').write_text('set -gx CONF_D_LOADED yes\n')
        (fishdir / 'local.fish').write_text('function fish_greeting; echo local-greeting; end\n')
        (self.home / '.bash_env').write_text('export DOTFILES_BASH_BRIDGE=preserved\n')
        self.executable('mise', '''case "$*" in
    *--shims*) echo 'set -gx ACTIVATION shims' ;;
    *) echo 'set -gx ACTIVATION full' ;;
esac
''')
        for interactive in (False, True):
            with self.subTest(interactive=interactive):
                p = self.fish('''test "$CONF_D_LOADED" = yes; or exit 11
test "$ACTIVATION" = ''' + ('full' if interactive else 'shims') + '''; or exit 12
set -q BASH_ENV; and exit 13
bash -c 'test -z "$DOTFILES_BASH_BRIDGE"'; or exit 14
functions -q ytdl-audio; or exit 15
''', interactive=interactive)
                self.assertEqual(p.returncode, 0, p.stderr)
        p = self.fish('fish_greeting', interactive=True, term='xterm-256color')
        self.assertEqual(p.stdout.strip(), 'local-greeting')

    def test_optional_mise_shims_never_run_at_startup(self):
        self.install_fixture()
        marker = self.root / 'shim-was-invoked'
        self.executable('mise', f'''if [ "${{0##*/}}" != mise ]; then
    touch '{marker}'
    exit 99
fi
''')
        for name in ('starship', 'fzf', 'direnv', 'zoxide', 'eza', 'bat', 'nvim'):
            (self.bin / name).symlink_to('mise')
        p = self.fish('''for name in vim cat ls
    functions $name | string match -q '*alias*'; and exit 17
end
true
''', interactive=True, term='xterm-256color')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertFalse(marker.exists())

    def test_mug_without_runtime_or_optional_tools(self):
        p = self.chezmoi('apply', '--force', machine='mug')
        self.assertEqual(p.returncode, 0, p.stderr)
        config = self.home / '.config/fish/config.fish'
        for interactive in (False, True):
            with self.subTest(interactive=interactive):
                # Bypass vendor startup so this exercises genuinely absent tools.
                p = self.run_command([TOOLS['fish'], '--no-config',
                                      *(['--interactive'] if interactive else []), '-c',
                                      f'source "{config}"; ' + '''functions vim | string match -q '*nvim*'; and exit 21
functions cat | string match -q '*bat*'; and exit 22
functions ls | string match -q '*eza*'; and exit 23
set -q BASH_ENV; and exit 24
true
'''])
                self.assertEqual(p.returncode, 0, p.stderr)

    def test_installed_optional_tools_and_missing_audio_dependency(self):
        self.install_fixture()
        for name in ('direnv', 'zoxide', 'starship'):
            self.executable(name, f'echo "set -gx INIT_{name} yes"\n')
        fzf_marker = self.root / 'fzf-was-invoked'
        self.executable('fzf', f'touch "{fzf_marker}"\nexit 99\n')
        for name in ('eza', 'bat', 'nvim'):
            self.executable(name, 'exit 0\n')
        p = self.fish('''for name in direnv zoxide starship
    set -l variable INIT_$name
    test "$$variable" = yes; or exit 18
end
functions ls | string match -q '*eza*'; or exit 19
functions cat | string match -q '*bat*'; or exit 20
''', interactive=True, term='xterm-256color')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertFalse(fzf_marker.exists())
        p = self.fish('ytdl-audio')
        self.assertEqual(p.returncode, 127)
        self.assertIn('requires uvx', p.stderr)

    def test_git_writes_survive_reapply_and_preserve_helpers(self):
        self.install_fixture()
        original = '''[user]
    name = Fixture User
    email = before@example.invalid
[credential "https://github.com"]
    helper =
    helper = !fixture-gh auth git-credential
[core]
    pager = delta
    hooksPath = ~/work/hooks
[gpg]
    program = /host/specific/gpg
[filter "lfs"]
    required = true
'''
        path = self.home / '.gitconfig'
        path.write_text(original)
        for args in [('--global', 'user.email', 'after@example.invalid'),
                     ('--global', '--add', 'credential.https://gist.github.com.helper', '!new-helper'),
                     ('--global', 'core.pager', 'cat')]:
            p = self.run_command([TOOLS['git'], 'config', *args])
            self.assertEqual(p.returncode, 0, p.stderr)
        before = path.read_bytes()
        p = self.chezmoi('apply', '--force')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(path.read_bytes(), before)
        for key, expected in [('user.email', 'after@example.invalid'), ('core.pager', 'cat'),
                              ('fetch.prune', 'true'),
                              ('user.name', 'Fixture User'),
                              ('core.hooksPath', '~/work/hooks'),
                              ('gpg.program', '/host/specific/gpg'),
                              ('filter.lfs.required', 'true')]:
            p = self.run_command([TOOLS['git'], 'config', '--includes', '--get', key])
            self.assertEqual(p.stdout.strip(), expected)
        p = self.run_command([TOOLS['git'], 'config', '--global', '--get-all',
                              'credential.https://github.com.helper'])
        self.assertEqual(p.stdout.splitlines(), ['', '!fixture-gh auth git-credential'])

    def test_git_credentials_are_scoped_to_github(self):
        self.install_fixture()
        (self.home / '.gitconfig').write_text('# Host-local overrides and credential setup go here.\n')
        for host in ['github.com', 'gist.github.com']:
            p = self.run_command([TOOLS['git'], 'config', '--get-all', f'credential.https://{host}.helper'])
            self.assertEqual(p.returncode, 0, p.stderr)
            self.assertEqual(p.stdout.splitlines(), ['', '!gh auth git-credential'])
        for key in ['credential.helper', 'core.hooksPath', 'gpg.program']:
            p = self.run_command([TOOLS['git'], 'config', '--includes', '--get', key])
            self.assertEqual(p.returncode, 1, p.stderr)

    def test_work_hooks_are_scoped_to_drill_work_repositories(self):
        p = self.chezmoi('apply', '--force', machine='drill', os_name='darwin')
        self.assertEqual(p.returncode, 0, p.stderr)
        work_config = self.home / '.config/git/gndctl.gitconfig'
        self.assertTrue(work_config.exists())
        (self.home / '.gitconfig').write_text(
            '[includeIf "gitdir:~/repos/gndctl/"]\n'
            '    path = ~/.config/git/gndctl.gitconfig\n')
        work = self.home / 'repos/gndctl/project'
        personal = self.home / 'repos/personal/project'
        for repo in [work, personal]:
            repo.mkdir(parents=True)
            p = self.run_command([TOOLS['git'], 'init', '--quiet', str(repo)])
            self.assertEqual(p.returncode, 0, p.stderr)
        p = self.run_command([TOOLS['git'], '-C', str(work), '-c', 'user.name=Fixture',
                              '-c', 'user.email=fixture@example.invalid', 'commit',
                              '--allow-empty', '--quiet', '-m', 'fixture'])
        self.assertEqual(p.returncode, 0, p.stderr)
        worktree = self.home / 'repos/gndctl/linked-worktree'
        p = self.run_command([TOOLS['git'], '-C', str(work), 'worktree', 'add',
                              '--detach', '--quiet', str(worktree), 'HEAD'])
        self.assertEqual(p.returncode, 0, p.stderr)
        for repo, expected in [(work, True), (worktree, True), (personal, False), (self.home, False)]:
            p = self.run_command([TOOLS['git'], '-C', str(repo), 'config', '--get', 'core.hooksPath'])
            self.assertEqual(p.returncode, 0 if expected else 1, p.stderr)
            if expected:
                self.assertEqual(p.stdout.strip(), '~/repos/gndctl/git-hooks/hooks')
        work_config.unlink()
        for machine, os_name in [('blue', 'darwin'), ('newport', 'linux'), ('mug', 'linux')]:
            p = self.chezmoi('apply', '--force', machine=machine, os_name=os_name)
            self.assertEqual(p.returncode, 0, p.stderr)
            self.assertFalse(work_config.exists())
            p = self.run_command([TOOLS['git'], '-C', str(work), 'config', '--get', 'core.hooksPath'])
            self.assertEqual(p.returncode, 1, p.stderr)

    def test_private_permissions_unmanaged_files_and_idempotence(self):
        (self.home / '.gitconfig').write_text('[user]\nname = untouched\n')
        self.install_fixture()
        for name in ('.config', '.config/fish', '.config/git'):
            self.assertEqual((self.home / name).stat().st_mode & 0o777, 0o700)
        for name in ('.config/fish/config.fish', '.config/mise/config.toml',
                     '.config/git/config', '.ssh/config.d/fleet.conf', 'skills-lock.json'):
            self.assertEqual((self.home / name).stat().st_mode & 0o777, 0o600)
        self.assertEqual((self.home / '.gitconfig').read_text(), '[user]\nname = untouched\n')
        managed = self.chezmoi('managed').stdout
        self.assertNotIn('Brewfile', managed)
        self.assertNotIn('.tool-versions', managed)
        self.assertNotIn('.gitconfig', managed.splitlines())
        self.assertNotIn('local.fish', managed)
        p = self.chezmoi('verify')
        self.assertEqual(p.returncode, 0, p.stderr)
        p = self.chezmoi('apply', '--dry-run', '--force', '--verbose')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertFalse(p.stdout.strip(), p.stdout)


if __name__ == '__main__':
    missing = [name for name, path in TOOLS.items() if not path]
    if missing:
        raise SystemExit('Missing test tools: ' + ', '.join(missing))
    unittest.main()
