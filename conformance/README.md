# Conformance probes

This folder will hold NWScript probe windows with the expected result on
each client: small windows, each built to show one rule (a margin, a
default size, a frame, an unsolvable layout, an image's lookup order),
and, per client (desktop, iOS, Android) and build, what the client did:
whether the window opened, and the rectangles, text breaks or pictures
measured on it.

No probes are published yet. The plan:

- **probes**: one `.nss` per probe (CC0), building its window with
  `nw_inc_nui.nss` only, and the same window as a `.jui`, so a checker or
  renderer can read it without running a script;
- **expected results**: per probe, per client and build, as JSON (CC0):
  `opened` (true, or the error the client showed), and where measured the
  rectangles of named elements in window pixels at GUI scale 1.0;
- **a manifest** saying which rules each probe covers, and how each result
  was taken (in game, a screenshot measured, the client's log).

Probes use only the base game's resources or images the probe writes
itself; no game assets are committed.
