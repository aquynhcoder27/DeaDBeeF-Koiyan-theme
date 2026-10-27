# DeaDBeeF Koiyan Theme

A DeaDBeeF GTK UI layout and visualizer configuration for Linux, curated from DeaDBeeF 1.10.2.

![Illustrative DeaDBeeF Koiyan Theme preview with sample metadata](preview.png)

The preview uses fictional playlist metadata and original placeholder artwork.

The six tabs are Main, Spectrogram, Oscilloscope, VU Meter, Spectrum, and Lyrics. On the main tab, playback controls, a waveform seekbar, cover art, and selected-track details sit alongside the playlist. The configuration also defines playlist and search-result columns.

This configuration changes DeaDBeeF's GTK UI layout and visualizer settings. It does not change the host desktop's GTK theme, and it is an independent community project, not an official DeaDBeeF theme.

## Requirements

- DeaDBeeF with the GTK UI. The configuration was captured from version 1.10.2; widget names and settings may vary across releases.
- The Linux builds of these visualizer plugins:
  - Musical Spectrum
  - Spectrogram
  - VU Meter
  - Waveform Seekbar

Download the plugins from the [official DeaDBeeF plugin page](https://deadbeef.sourceforge.io/plugins.html). Choose builds matching your architecture and GTK UI, then extract them into `~/.local/lib/deadbeef/`. The plugins are separate projects and retain their own licensing and copyright terms.

## Install

This repository provides the DeaDBeeF layout and visualizer configuration; it does not install DeaDBeeF or its plugins. Install DeaDBeeF with the GTK UI and the required plugins first.

Clone this repository:

```sh
git clone https://github.com/aquynhcoder27/DeaDBeeF-Koiyan-theme.git
cd DeaDBeeF-Koiyan-theme
```

Then close DeaDBeeF, apply the configuration, and start DeaDBeeF again:

```sh
sh ./apply.sh
```

By default, the script uses `$XDG_CONFIG_HOME/deadbeef/config` when `XDG_CONFIG_HOME` is set, or `~/.config/deadbeef/config` otherwise. It merges the theme keys while keeping unrelated settings, then creates a timestamped backup beside the configuration before replacing it. The script refuses to replace a symlink or a non-regular file.

For a configuration at another location, pass its path explicitly:

```sh
sh ./apply.sh /path/to/deadbeef/config
```

To revert, close DeaDBeeF and copy the backup path printed by the script over the active `config` file.

## Source and scope

This configuration was curated from a Linux system running DeaDBeeF 1.10.2. It includes the six-tab layout, playlist and search columns, title-bar formatting, and waveform, spectrogram, oscilloscope, spectrum, and VU meter settings. It does not contain playlists, music paths, playback history, credentials, or machine-specific window geometry.

## License and attribution

Unless otherwise noted, original content in this repository is licensed under the [MIT License](LICENSE). You may use, modify, and redistribute that content, including commercially, provided the copyright and permission notice is retained.

The license does not grant rights to DeaDBeeF, third-party plugins, their names or logos, or other third-party content shown or referenced here. Those remain subject to their respective rights and licenses.
