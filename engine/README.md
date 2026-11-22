# Engine

What the game client does with NUI windows, finding by finding, written
without reference to any one tool. The spec's rules cite these.

- **Build:** NWN:EE 89.8193.37-17, Linux, git commit 26c6e573 (the
  install's `bin/linux-x86/build.txt`: `26c6e57364a45246e3b58e4f2c49366df72d15db`,
  built Mon Oct 6 2025).
- **Binaries** (both unstripped x86-64 PIE, from the Steam install's
  `bin/linux-x86/`):

  | Binary | sha256 | Used for |
  |---|---|---|
  | `nwmain-linux` | `6d19c39bc646af5ddbc333ff31797a4acd9019506bcb45ef1b93b1bd5925e700` | the client: everything in this repository unless marked |
  | `nwserver-linux` | `d6d952826b671fc62c376dca912e87f1aa45d4aa81c620e912ceb4d8e051111d` | the server: what `NuiCreate` and `NuiCreateFromResRef` send (T2) |

  These are the files nwn-mdl-spec and nwn-tileset-spec were read on.
- **Addresses** are objdump/nm addresses (file virtual addresses) in
  `nwmain-linux` unless marked. Ghidra loads these PIEs at 0x100000, so its
  addresses are 0x100000 higher (`Nui__ReloadSkin` is 0x1205460 here,
  0x1305460 in Ghidra). Every function address here was checked against
  `nm -C`.
- **Status:** **confirmed** (read in code and checked against the
  disassembly, or shown in game, or measured on an in-game screenshot),
  **inferred** (follows from code, data or a renderer's agreement with
  the client, not shown directly), **untested**.
- **Numbering:** T1 onwards, this repository's own: T1-T53 the desktop
  client, T54-T73 the mobile clients.

| File | What |
|---|---|
| [behaviour.md](behaviour.md) | The desktop findings |
| [mobile.md](mobile.md) | The mobile findings (T54-T73), measured on an iPhone and an Android tablet, with their method |
| [method.md](method.md) | How the code was read, the windows tried and the screenshots measured, so others can repeat it |

Some findings cite sources that are not in this repository: the
`nuilayout.cpp` gist linked from the nwn.wiki NUI page, the game's own
scripts (`nw_inc_nui.nss`, `nwscript.nss`) and skin, by name, and
decompiles that are cited by function and address (see method.md).
Decompiles and game files are never copied here.
