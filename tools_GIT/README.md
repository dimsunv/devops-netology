# Домашнее задание к занятию «2.4. Инструменты Git»

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
```
$ git show -q aefea
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

Update CHANGELOG.md
```

2. Какому тегу соответствует коммит `85024d3`?
```
$ git show -q 85024d3
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
Author: tf-release-bot <terraform@hashicorp.com>
Date:   Thu Mar 5 20:56:10 2020 +0000
```

3. Сколько родителей у коммита `b8d720`? Напишите их хеши.
```
$ git log --pretty=%P -n 1 b8d720
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
```

4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами `v0.12.23` и `v0.12.24`.
```
$ git log --oneline v0.12.23...v0.12.24
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
```

5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).
```
$ git grep -n 'func providerSource('
provider_source.go:23:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {

$ git blame -L 23,23 provider_source.go
5af1e6234a (Martin Atkins 2020-04-21 16:28:59 -0700 23) func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {

$ git show -q 5af1e6234a
commit 5af1e6234ab6da412fb8637393c5a17a1b293663
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Tue Apr 21 16:28:59 2020 -0700

    main: Honor explicit provider_installation CLI config when present

    If the CLI configuration contains a provider_installation block then we'll
    use the source configuration it describes instead of the implied one we'd
    build otherwise.
```

6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
```
$ git grep -n 'func globalPluginDirs('
plugins.go:18:func globalPluginDirs() []string {

$ git blame -L 18 plugins.go
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 18) func globalPluginDirs() []string {
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 19)         var ret []string
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 20)         // Look in ~/.terraform.d/plugins/ , or its equivalent on non-UNIX
78b1220558 (Pam Selle     2020-01-13 16:50:05 -0500 21)         dir, err := cliconfig.ConfigDir()
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 22)         if err != nil {
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 23)                 log.Printf("[ERROR] Error finding global config directory: %s", err)
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 24)         } else {
41ab0aef7a (James Bardin  2017-08-09 10:34:11 -0400 25)                 machineDir := fmt.Sprintf("%s_%s", runtime.GOOS, runtime.GOARCH)
52dbf94834 (James Bardin  2017-08-09 17:46:49 -0400 26)                 ret = append(ret, filepath.Join(dir, "plugins"))
41ab0aef7a (James Bardin  2017-08-09 10:34:11 -0400 27)                 ret = append(ret, filepath.Join(dir, "plugins", machineDir))
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 28)         }
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 29)
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 30)         return ret
8364383c35 (Martin Atkins 2017-04-13 18:05:58 -0700 31) }

$ git show -q 78b1220558
commit 78b12205587fe839f10d946ea3fdc06719decb05
Author: Pam Selle <204372+pselle@users.noreply.github.com>
Date:   Mon Jan 13 16:50:05 2020 -0500

    Remove config.go and update things using its aliases

$ git show -q 52dbf94834
commit 52dbf94834cb970b510f2fba853a5b49ad9b1a46
Author: James Bardin <j.bardin@gmail.com>
Date:   Wed Aug 9 17:46:49 2017 -0400

    keep .terraform.d/plugins for discovery
	
$ git show -q 41ab0aef7a
commit 41ab0aef7a0fe030e84018973a64135b11abcd70
Author: James Bardin <j.bardin@gmail.com>
Date:   Wed Aug 9 10:34:11 2017 -0400

    Add missing OS_ARCH dir to global plugin paths

    When the global directory was added, the discovery system still
    attempted to search for OS_ARCH subdirectories. It has since been
    changed only search explicit paths.
```

7. Кто автор функции `synchronizedWriters`?
```
$ git log -S "func synchronizedWriters("
commit bdfea50cc85161dea41be0fe3381fd98731ff786
Author: James Bardin <j.bardin@gmail.com>
Date:   Mon Nov 30 18:02:04 2020 -0500

    remove unused

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Wed May 3 16:25:41 2017 -0700

    main: synchronize writes to VT100-faker on Windows

    We use a third-party library "colorable" to translate VT100 color
    sequences into Windows console attribute-setting calls when Terraform is
    running on Windows.

    colorable is not concurrency-safe for multiple writes to the same console,
    because it writes to the console one character at a time and so two
    concurrent writers get their characters interleaved, creating unreadable
    garble.

    Here we wrap around it a synchronization mechanism to ensure that there
    can be only one Write call outstanding across both stderr and stdout,
    mimicking the usual behavior we expect (when stderr/stdout are a normal
    file handle) of each Write being completed atomically.
```