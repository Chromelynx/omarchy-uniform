# Uniform

An Omarchy bar plugin that pastes website and AI clipboard text into a window that uses one font.

Copied pages often arrive as HTML, and chat answers often arrive with mixed styling. Uniform turns that clipboard into plain text and shows it in the bar font.

## Install

```sh
omarchy plugin add https://github.com/Chromelynx/omarchy-uniform.git --enable
```

The widget lands in the right side of the bar. Move it with:

```sh
omarchy bar move clynx.uniform --section center
```

## Usage

Click the bar icon to open the window. Opening it pastes the clipboard.

- Paste reads the clipboard again.
- Copy puts the window text back on the clipboard as plain text.
- Clear empties the window.
- Escape closes the window.

Plain text is kept and cleaned up. HTML is converted to text first: tags are removed, list items become lines, and common entities are decoded.

Open or close it from a terminal:

```sh
omarchy-shell shell summon clynx.uniform '{}'
omarchy-shell shell hide clynx.uniform
```

## Remove

```sh
omarchy plugin remove clynx.uniform
```

Removal disables the plugin and deletes the local copy. It does not change other plugins.

## Dependencies

Omarchy with shell plugins. Reading and writing the clipboard uses `wl-paste` and `wl-copy` from wl-clipboard, which a normal Omarchy install already provides. The plugin does not download code, install packages, or start another process of its own.

## License

MIT. See [LICENSE](LICENSE).
