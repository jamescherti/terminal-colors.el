# terminal-colors.el
![Build Status](https://github.com/jamescherti/terminal-colors.el/actions/workflows/melpazoid.yml/badge.svg)
![License](https://img.shields.io/github/license/jamescherti/terminal-colors.el)
![](https://jamescherti.com/misc/made-for-gnu-emacs.svg)

- Author: James Cherti <[https://www.jamescherti.com/](https://www.jamescherti.com/)>
- License: GPL 3.0 or later

The **[terminal-colors](https://github.com/jamescherti/terminal-colors.el)** package applies terminal themes (color schemes) to Emacs terminal emulators, including `vterm`, `eat`, and `term` (`ansi-term`).

By default, Emacs terminal emulators inherit their ANSI colors and background from the active Emacs theme, which can result in low contrast or unreadable text in terminal applications. The **terminal-colors** package decouples terminal colors from the global Emacs theme, applying dedicated palettes and buffer-local foreground and background colors modeled after standalone terminal emulators.

## Why?

You spend hours picking an Emacs color theme that makes your source code and Org buffers look great. Then you open `vterm` or `eat` to run `htop`, `git diff`, or a test runner, and the output is nearly illegible: dark blue directory names vanish into a dark background, bright yellow warnings wash out against a light theme, and TUI applications render harsh black blocks right over your carefully chosen background color.

Meanwhile, if you open a standalone terminal emulator like GNOME Terminal, Konsole, or Terminator, everything is crisp and readable right out of the box.

Because Emacs terminal emulators inherit their ANSI colors and default background directly from your active Emacs theme, switching to a new theme for your code often breaks the contrast in your terminal buffers.

The **terminal-colors** package solves this by decoupling your terminal buffers from your global Emacs theme. It brings battle-tested color palettes from standalone terminals (such as GNOME Terminal Tango, Konsole, Solarized, and Gruvbox) directly into `vterm`, `eat`, and `term` (`ansi-term`). Your editing buffers keep your favorite Emacs theme, while your terminal buffers get a dedicated, high-contrast color scheme with buffer-local foreground and background colors.

## Features

- Unified 16-color ANSI palettes and buffer-local foreground/background colors across `vterm`, `eat`, and `term`.
- Built-in palettes from popular terminal emulators (GNOME Terminal, Konsole, and Terminator).
- Buffer-local face remapping for `default` and `fringe` faces in terminal buffers without affecting standard editing buffers.
- Automatic reapplication of the active terminal palette when switching Emacs color themes via `load-theme`.
- Interactive palette switching with live redrawing of open terminal buffers via `M-x terminal-colors-load`.

## Installation

### use-package and :vc (Built-in feature in Emacs version >= 30)

To install *terminal-colors* with `use-package` and `:vc` (Emacs >= 30):

```emacs-lisp
(use-package terminal-colors
  :vc (:url "https://github.com/jamescherti/terminal-colors.el"
       :rev :newest)
  :custom
  ;; Builtin themes:
  ;;   gnome-terminal-tango-dark (default)
  ;;   gnome-terminal-tango-light
  ;;   konsole-white-on-black
  ;;   terminator-tango
  ;;   terminator-rxvt
  ;;   terminator-ambience
  ;;   terminator-solarized
  ;;   terminator-gruvbox-dark
  ;;   terminator-gruvbox-light
  (terminal-colors-default-theme "gnome-terminal-tango-dark")
  :config
  (with-eval-after-load 'vterm
    (require 'terminal-colors-vterm)
    (terminal-colors-vterm-mode 1))

  (with-eval-after-load 'eat
    (require 'terminal-colors-eat)
    (terminal-colors-eat-mode 1))

  (with-eval-after-load 'term
    (require 'terminal-colors-term)
    (terminal-colors-term-mode 1)))
```

### Alternative: use-package and straight (Emacs version < 30)

To install *terminal-colors* with `straight.el`:

Step 1: If it has not already been done, [add the straight.el bootstrap code](https://github.com/radian-software/straight.el?tab=readme-ov-file#getting-started) to your init file.

Step 2: Add the following code to the Emacs init file:
```emacs-lisp
(use-package terminal-colors
  :straight (terminal-colors
             :type git
             :host github
             :repo "jamescherti/terminal-colors.el")
  :custom
  ;; Builtin themes:
  ;;   gnome-terminal-tango-dark (default)
  ;;   gnome-terminal-tango-light
  ;;   konsole-white-on-black
  ;;   terminator-tango
  ;;   terminator-rxvt
  ;;   terminator-ambience
  ;;   terminator-solarized
  ;;   terminator-gruvbox-dark
  ;;   terminator-gruvbox-light
  (terminal-colors-default-theme "gnome-terminal-tango-dark")
  :config
  (with-eval-after-load 'vterm
    (require 'terminal-colors-vterm)
    (terminal-colors-vterm-mode 1))

  (with-eval-after-load 'eat
    (require 'terminal-colors-eat)
    (terminal-colors-eat-mode 1))

  (with-eval-after-load 'term
    (require 'terminal-colors-term)
    (terminal-colors-term-mode 1)))
```

### Alternative: Doom Emacs

To install *terminal-colors* on Doom Emacs:

1. Add to the `~/.doom.d/packages.el` file:

```elisp
(package! terminal-colors
  :recipe
  (:host github :repo "jamescherti/terminal-colors.el"))
```

2. Add to `~/.doom.d/config.el`:
```elisp
(after! terminal-colors
  ;; Builtin themes:
  ;;   gnome-terminal-tango-dark (default)
  ;;   gnome-terminal-tango-light
  ;;   konsole-white-on-black
  ;;   terminator-tango
  ;;   terminator-rxvt
  ;;   terminator-ambience
  ;;   terminator-solarized
  ;;   terminator-gruvbox-dark
  ;;   terminator-gruvbox-light
  (setq terminal-colors-default-theme "gnome-terminal-tango-dark")

  (with-eval-after-load 'vterm
    (require 'terminal-colors-vterm)
    (terminal-colors-vterm-mode 1))

  (with-eval-after-load 'eat
    (require 'terminal-colors-eat)
    (terminal-colors-eat-mode 1))

  (with-eval-after-load 'term
    (require 'terminal-colors-term)
    (terminal-colors-term-mode 1)))
```

3. Run the `doom sync` command:
```
doom sync
```

## Usage and Configuration

### Enabling Terminal Modes

Enable the global minor mode corresponding to each terminal emulator you use:

```emacs-lisp
;; For vterm
(require 'terminal-colors-vterm)
(terminal-colors-vterm-mode 1)

;; For Eat
(require 'terminal-colors-eat)
(terminal-colors-eat-mode 1)

;; For built-in term / ansi-term
(require 'terminal-colors-term)
(terminal-colors-term-mode 1)
```

### Changing the terminal color scheme

Set `terminal-colors-default-theme` to choose the default palette loaded on initialization:

```emacs-lisp
(setq terminal-colors-default-theme "terminator-gruvbox-dark")
```

To switch terminal themes interactively during an Emacs session, run:

```
M-x terminal-colors-load
```

Or load a theme programmatically in Elisp:

```emacs-lisp
(terminal-colors-load "terminator-solarized")
```

### Built-in terminal-colors themes

The following terminal themes are included out of the box:

- `gnome-terminal-tango-dark` (default)
- `gnome-terminal-tango-light`
- `konsole-white-on-black`
- `terminator-tango`
- `terminator-rxvt`
- `terminator-ambience`
- `terminator-solarized`
- `terminator-gruvbox-dark`
- `terminator-gruvbox-light`

## Author and License

The *terminal-colors* Emacs package has been written by [James Cherti](https://www.jamescherti.com/) and is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version.

Copyright (C) 2024-2026 James Cherti

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [terminal-colors.el @GitHub](https://github.com/jamescherti/terminal-colors.el)

Other Emacs packages by the same author:

- [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d): This repository hosts a minimal Emacs configuration designed to serve as a foundation for your vanilla Emacs setup and provide a solid base for an enhanced Emacs experience.
- [compile-angel.el](https://github.com/jamescherti/compile-angel.el): **Speed up Emacs!** This package guarantees that all .el files are both byte-compiled and native-compiled, which significantly speeds up Emacs.
- [outline-indent.el](https://github.com/jamescherti/outline-indent.el): An Emacs package that provides a minor mode that enables code folding and outlining based on indentation levels for various indentation-based text files, such as YAML, Python, and other indented text files.
- [vim-tab-bar.el](https://github.com/jamescherti/vim-tab-bar.el): Make the Emacs tab-bar Look Like Vim's Tab Bar.
- [elispcomp](https://github.com/jamescherti/elispcomp): A command line tool that allows compiling Elisp code directly from the terminal or from a shell script. It facilitates the generation of optimized .elc (byte-compiled) and .eln (native-compiled) files.
- [tomorrow-night-deepblue-theme.el](https://github.com/jamescherti/tomorrow-night-deepblue-theme.el): The Tomorrow Night Deepblue Emacs theme is a beautiful deep blue variant of the Tomorrow Night theme, which is renowned for its elegant color palette that is pleasing to the eyes. It features a deep blue background color that creates a calming atmosphere. The theme is also a great choice for those who miss the blue themes that were trendy a few years ago.
- [Ultyas](https://github.com/jamescherti/ultyas/): A command-line tool designed to simplify the process of converting code snippets from UltiSnips to YASnippet format.
- [dir-config.el](https://github.com/jamescherti/dir-config.el): Automatically find and evaluate .dir-config.el Elisp files to configure directory-specific settings.
- [flymake-bashate.el](https://github.com/jamescherti/flymake-bashate.el): A package that provides a Flymake backend for the bashate Bash script style checker.
- [flymake-ansible-lint.el](https://github.com/jamescherti/flymake-ansible-lint.el): An Emacs package that offers a Flymake backend for ansible-lint.
- [inhibit-mouse.el](https://github.com/jamescherti/inhibit-mouse.el): A package that disables mouse input in Emacs, offering a simpler and faster alternative to the disable-mouse package.
- [quick-sdcv.el](https://github.com/jamescherti/quick-sdcv.el): This package enables Emacs to function as an offline dictionary by using the sdcv command-line tool directly within Emacs.
- [enhanced-evil-paredit.el](https://github.com/jamescherti/enhanced-evil-paredit.el): An Emacs package that prevents parenthesis imbalance when using *evil-mode* with *paredit*. It intercepts *evil-mode* commands such as delete, change, and paste, blocking their execution if they would break the parenthetical structure.
- [stripspace.el](https://github.com/jamescherti/stripspace.el): Ensure Emacs Automatically removes trailing whitespace before saving a buffer, with an option to preserve the cursor column.
- [persist-text-scale.el](https://github.com/jamescherti/persist-text-scale.el): Ensure that all adjustments made with text-scale-increase and text-scale-decrease are persisted and restored across sessions.
- [pathaction.el](https://github.com/jamescherti/pathaction.el): Execute the pathaction command-line tool from Emacs. The pathaction command-line tool enables the execution of specific commands on targeted files or directories. Its key advantage lies in its flexibility, allowing users to handle various types of files simply by passing the file or directory as an argument to the pathaction tool. The tool uses a .pathaction.yaml rule-set file to determine which command to execute. Additionally, Jinja2 templating can be employed in the rule-set file to further customize the commands.
- [kirigami.el](https://github.com/jamescherti/kirigami.el): The *kirigami* Emacs package offers a unified interface for opening and closing folds across a diverse set of major and minor modes in Emacs, including `outline-mode`, `outline-minor-mode`, `outline-indent-minor-mode`, `org-mode`, `markdown-mode`, `vdiff-mode`, `vdiff-3way-mode`, `hs-minor-mode`, `hide-ifdef-mode`, `origami-mode`, `yafolding-mode`, `folding-mode`, and `treesit-fold-mode`. With Kirigami, folding key bindings only need to be configured **once**. After that, the same keys work consistently across all supported major and minor modes, providing a unified and predictable folding experience.
- [buffer-guardian.el](https://github.com/jamescherti/buffer-guardian.el): Automatically saves Emacs buffers without requiring manual intervention. By default, it triggers a save when the user switches to another buffer, switches to another window or frame, Emacs loses focus, or the minibuffer is opened. Beyond standard file buffers, *buffer-guardian* also manages specialized editing buffers such as *org-src* and *edit-indirect*. Additional features, disabled by default, include periodic or idle-time saving of all buffers, automatic exclusion of remote, nonexistent, or large files, and support for custom exclusion rules via regular expressions or predicate functions.
