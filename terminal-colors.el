;;; terminal-colors.el --- Unified color schemes for vterm, Eat, and term -*- lexical-binding: t -*-

;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; URL: https://github.com/jamescherti/terminal-colors.el
;; Package-Requires: ((emacs "29.1"))
;; Keywords: faces terminals
;; Version: 0.0.9
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; The `terminal-colors' package applies terminal themes (color schemes) to
;; Emacs terminal emulators, including `vterm', `eat', and `term' (`ansi-term').
;;
;; By default, Emacs terminal emulators inherit their ANSI colors and background
;; from the active Emacs theme, which can result in low contrast or unreadable
;; text in terminal applications. The `terminal-colors' package decouples
;; terminal colors from the global Emacs theme, applying dedicated palettes and
;; buffer-local foreground and background colors modeled after standalone
;; terminal emulators.
;;
;; The `terminal-colors' theme shown in the screenshot is:
;; 'gnome-terminal-tango-dark'.
;;
;; Features
;; --------
;;
;; - Unified 16-color ANSI palettes and buffer-local foreground/background
;;   colors across vterm, eat, and term.
;; - Built-in palettes from popular terminal emulators, including GNOME
;;   Terminal, Konsole, and Terminator.
;; - Buffer-local face remapping for the default and fringe faces in terminal
;;   buffers without affecting standard editing buffers.
;; - Automatic reapplication of the active terminal palette when switching Emacs
;;   color themes via `load-theme'.
;; - Interactive palette switching with live redrawing of open terminal buffers
;;   via M-x terminal-colors-load.

;;; Code:

;;; Require

(require 'ansi-color)
(require 'cl-lib)
(require 'face-remap)

(defvar ansi-term-color-vector)
(defvar vterm-color-palette)
(defvar vterm--term)
(declare-function vterm--redraw "vterm" (term))
(declare-function vterm--get-color "vterm" (index &rest args))

;;; Variables

(defgroup terminal-colors nil
  "Unified color schemes for terminal emulators."
  :group 'faces)

(defgroup terminal-colors-eat nil
  "Terminal color schemes for Eat."
  :group 'terminal-colors)

(defgroup terminal-colors-term nil
  "Terminal color schemes for `term' and `ansi-term'."
  :group 'terminal-colors)

(defgroup terminal-colors-vterm nil
  "Terminal color schemes for `vterm'."
  :group 'terminal-colors)

(defcustom terminal-colors-default-theme "gnome-terminal-tango-dark"
  "The default theme."
  :type 'string
  :group 'terminal-colors)

(defvar terminal-colors--before-load-hook nil
  "Hook run before a terminal theme is loaded.")

(defvar terminal-colors--after-load-hook nil
  "Hook run after a terminal theme is loaded.")

(defvar terminal-colors--reset-hook nil
  "Hook run after a terminal theme is unloaded.")

(defvar terminal-colors--current-theme-name nil
  "The name of the currently loaded terminal theme.")

(defvar terminal-colors--background nil)
(defvar terminal-colors--foreground nil)
(defvar terminal-colors--cursor nil)

(defvar-local terminal-colors--remap-cookies nil
  "Buffer-local list of face remapping cookies.")

(defvar terminal-colors--color-black nil)
(defvar terminal-colors--color-red nil)
(defvar terminal-colors--color-green nil)
(defvar terminal-colors--color-yellow nil)
(defvar terminal-colors--color-blue nil)
(defvar terminal-colors--color-magenta nil)
(defvar terminal-colors--color-cyan nil)
(defvar terminal-colors--color-white nil)
(defvar terminal-colors--color-bright-black nil)
(defvar terminal-colors--color-bright-red nil)
(defvar terminal-colors--color-bright-green nil)
(defvar terminal-colors--color-bright-yellow nil)
(defvar terminal-colors--color-bright-blue nil)
(defvar terminal-colors--color-bright-magenta nil)
(defvar terminal-colors--color-bright-cyan nil)
(defvar terminal-colors--color-bright-white nil)
(defvar terminal-colors-default-foreground-background
  '(("white-on-black" . (("foreground" . "#ffffff")
                         ("background" . "#000000")
                         ("cursor" . "#ffffff")))
    ("black-on-white" . (("foreground" . "#000000")
                         ("background" . "#ffffff")
                         ("cursor" . "#000000")))
    ("terminator-orange-on-black" . (("foreground" . "#e53c00")
                                     ("background" . "#000000")
                                     ("cursor" . "#e53c00")))
    ("terminator-ambience" . (("foreground" . "#ffffff")
                              ("background" . "#300a24")
                              ("cursor" . "#ffffff")))
    ("terminator-solarized-dark" . (("foreground" . "#839496")
                                    ("background" . "#002b36")
                                    ("cursor" . "#839496")))
    ("terminator-solarized-light" . (("foreground" . "#657b83")
                                     ("background" . "#fdf6e3")
                                     ("cursor" . "#657b83")))
    ("terminator-gruvbox-light" . (("foreground" . "#3c3836")
                                   ("background" . "#fbf1c7")
                                   ("cursor" . "#3c3836")))
    ("terminator-gruvbox-dark" . (("foreground" . "#ebdbb2")
                                  ("background" . "#282828")
                                  ("cursor" . "#ebdbb2"))))
  "Default foreground, background, and cursor colors for terminal themes.")

(defvar terminal-colors-colors
  '(("gnome-terminal-tango-dark" .
     (("default-colors" . "white-on-black")
      ("colors" . (("black" . "#2e3436")
                   ("red" . "#cc0000")
                   ("green" . "#4e9a06")
                   ("yellow" . "#c4a000")
                   ("blue" . "#3465a4")
                   ("magenta" . "#75507b")
                   ("cyan" . "#06989a")
                   ("white" . "#d3d7cf")
                   ("bright-black" . "#555753")
                   ("bright-red" . "#ef2929")
                   ("bright-green" . "#8ae234")
                   ("bright-yellow" . "#fce94f")
                   ("bright-blue" . "#729fcf")
                   ("bright-magenta" . "#ad7fa8")
                   ("bright-cyan" . "#34e2e2")
                   ("bright-white" . "#eeeeec")))))

    ("gnome-terminal-tango-light" . (("default-colors" . "black-on-white")
                                     ("colors" . (("black" . "#2E3436")
                                                  ("red" . "#CC0000")
                                                  ("green" . "#4E9A06")
                                                  ("yellow" . "#C4A000")
                                                  ("blue" . "#3465A4")
                                                  ("magenta" . "#75507B")
                                                  ("cyan" . "#06989A")
                                                  ("white" . "#D3D7CF")
                                                  ("bright-black" . "#555753")
                                                  ("bright-red" . "#EF2929")
                                                  ("bright-green" . "#8AE234")
                                                  ("bright-yellow" . "#FCE94F")
                                                  ("bright-blue" . "#729FCF")
                                                  ("bright-magenta" . "#AD7FA8")
                                                  ("bright-cyan" . "#34E2E2")
                                                  ("bright-white" . "#EEEEEC")))))

    ("konsole-white-on-black" . (("default-colors" . "white-on-black")
                                 ("colors" . (("black" . "#000000")
                                              ("red" . "#b21818")
                                              ("green" . "#18b218")
                                              ("yellow" . "#b26818")
                                              ("blue" . "#1818b2")
                                              ("magenta" . "#b218b2")
                                              ("cyan" . "#18b2b2")
                                              ("white" . "#b2b2b2")
                                              ("bright-black" . "#686868")
                                              ("bright-red" . "#ff5454")
                                              ("bright-green" . "#54ff54")
                                              ("bright-yellow" . "#ffff54")
                                              ("bright-blue" . "#5454ff")
                                              ("bright-magenta" . "#ff54ff")
                                              ("bright-cyan" . "#54ffff")
                                              ("bright-white" . "#ffffff")))))
    ("terminator-tango" . (("default-colors" . "white-on-black")
                           ("colors" . (("black" . "#000000")
                                        ("red" . "#cc0000")
                                        ("green" . "#4e9a06")
                                        ("yellow" . "#c4a000")
                                        ("blue" . "#3465a4")
                                        ("magenta" . "#75507b")
                                        ("cyan" . "#06989a")
                                        ("white" . "#d3d7cf")
                                        ("bright-black" . "#555753")
                                        ("bright-red" . "#ef2929")
                                        ("bright-green" . "#8ae234")
                                        ("bright-yellow" . "#fce94f")
                                        ("bright-blue" . "#729fcf")
                                        ("bright-magenta" . "#ad7fa8")
                                        ("bright-cyan" . "#34e2e2")
                                        ("bright-white" . "#eeeeec")))))
    ("terminator-rxvt" . (("default-colors" . "white-on-black")
                          ("colors" . (("black" . "#000000")
                                       ("red" . "#cd0000")
                                       ("green" . "#00cd00")
                                       ("yellow" . "#cdcd00")
                                       ("blue" . "#0000cd")
                                       ("magenta" . "#cd00cd")
                                       ("cyan" . "#00cdcd")
                                       ("white" . "#faebd7")
                                       ("bright-black" . "#404040")
                                       ("bright-red" . "#ff0000")
                                       ("bright-green" . "#00ff00")
                                       ("bright-yellow" . "#ffff00")
                                       ("bright-blue" . "#0000ff")
                                       ("bright-magenta" . "#ff00ff")
                                       ("bright-cyan" . "#00ffff")
                                       ("bright-white" . "#ffffff")))))
    ("terminator-ambience" . (("default-colors" . "terminator-ambience")
                              ("colors" . (("black" . "#2e3436")
                                           ("red" . "#cc0000")
                                           ("green" . "#4e9a06")
                                           ("yellow" . "#c4a000")
                                           ("blue" . "#3465a4")
                                           ("magenta" . "#75507b")
                                           ("cyan" . "#06989a")
                                           ("white" . "#d3d7cf")
                                           ("bright-black" . "#555753")
                                           ("bright-red" . "#ef2929")
                                           ("bright-green" . "#8ae234")
                                           ("bright-yellow" . "#fce94f")
                                           ("bright-blue" . "#729fcf")
                                           ("bright-magenta" . "#ad7fa8")
                                           ("bright-cyan" . "#34e2e2")
                                           ("bright-white" . "#eeeeec")))))
    ("terminator-solarized" . (("default-colors" . "terminator-solarized-dark")
                               ("colors" . (("black" . "#073642")
                                            ("red" . "#dc322f")
                                            ("green" . "#859900")
                                            ("yellow" . "#b58900")
                                            ("blue" . "#268bd2")
                                            ("magenta" . "#d33682")
                                            ("cyan" . "#2aa198")
                                            ("white" . "#eee8d5")
                                            ("bright-black" . "#002b36")
                                            ("bright-red" . "#cb4b16")
                                            ("bright-green" . "#586e75")
                                            ("bright-yellow" . "#657b83")
                                            ("bright-blue" . "#839496")
                                            ("bright-magenta" . "#6c71c4")
                                            ("bright-cyan" . "#93a1a1")
                                            ("bright-white" . "#fdf6e3")))))
    ("terminator-gruvbox-light" . (("default-colors" . "terminator-gruvbox-light")
                                   ("colors" . (("black" . "#fbf1c7")
                                                ("red" . "#cc241d")
                                                ("green" . "#98971a")
                                                ("yellow" . "#d79921")
                                                ("blue" . "#458588")
                                                ("magenta" . "#b16286")
                                                ("cyan" . "#689d6a")
                                                ("white" . "#7c6f64")
                                                ("bright-black" . "#928374")
                                                ("bright-red" . "#9d0006")
                                                ("bright-green" . "#79740e")
                                                ("bright-yellow" . "#b57614")
                                                ("bright-blue" . "#076678")
                                                ("bright-magenta" . "#8f3f71")
                                                ("bright-cyan" . "#427b58")
                                                ("bright-white" . "#3c3836")))))
    ("terminator-gruvbox-dark" . (("default-colors" . "terminator-gruvbox-dark")
                                  ("colors" . (("black" . "#282828")
                                               ("red" . "#cc241d")
                                               ("green" . "#98971a")
                                               ("yellow" . "#d79921")
                                               ("blue" . "#458588")
                                               ("magenta" . "#b16286")
                                               ("cyan" . "#689d6a")
                                               ("white" . "#a89984")
                                               ("bright-black" . "#928374")
                                               ("bright-red" . "#fb4934")
                                               ("bright-green" . "#b8bb26")
                                               ("bright-yellow" . "#fabd2f")
                                               ("bright-blue" . "#83a598")
                                               ("bright-magenta" . "#d3869b")
                                               ("bright-cyan" . "#8ec07c")
                                               ("bright-white" . "#ebdbb2"))))))
  "Colors for different terminal themes.")

;;; Faces

(defface terminal-colors-term-color-black
  '((t :inherit ansi-color-black))
  "Face used to render black color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-red
  '((t :inherit ansi-color-red))
  "Face used to render red color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-green
  '((t :inherit ansi-color-green))
  "Face used to render green color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-yellow
  '((t :inherit ansi-color-yellow))
  "Face used to render yellow color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-blue
  '((t :inherit ansi-color-blue))
  "Face used to render blue color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-magenta
  '((t :inherit ansi-color-magenta))
  "Face used to render magenta color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-cyan
  '((t :inherit ansi-color-cyan))
  "Face used to render cyan color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-white
  '((t :inherit ansi-color-white))
  "Face used to render white color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-black
  '((t :inherit ansi-color-bright-black))
  "Face used to render bright black color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-red
  '((t :inherit ansi-color-bright-red))
  "Face used to render bright red color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-green
  '((t :inherit ansi-color-bright-green))
  "Face used to render bright green color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-yellow
  '((t :inherit ansi-color-bright-yellow))
  "Face used to render bright yellow color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-blue
  '((t :inherit ansi-color-bright-blue))
  "Face used to render bright blue color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-magenta
  '((t :inherit ansi-color-bright-magenta))
  "Face used to render bright magenta color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-cyan
  '((t :inherit ansi-color-bright-cyan))
  "Face used to render bright cyan color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-white
  '((t :inherit ansi-color-bright-white))
  "Face used to render bright white color code."
  :group 'terminal-colors
  :version "28.1")

;;; Frame color

(defvar terminal-colors-frame-color--theme-background nil
  "The background color of the currently loaded Emacs theme.")

(defvar terminal-colors-frame-color--theme-foreground nil
  "The foreground color of the currently loaded Emacs theme.")

(defcustom terminal-colors-frame-color-vterm-update-frame-color nil
  "Update the frame background and foreground color."
  :type 'boolean
  :group 'terminal-colors-vterm)

(defun terminal-colors-frame-color--save-theme-fg-bg (&rest _)
  "Save the foreground and background color of the current theme."
  (setq terminal-colors-frame-color--theme-background
        (face-background 'default))
  (setq terminal-colors-frame-color--theme-foreground
        (face-foreground 'default)))

(defun terminal-colors-frame-color--auto-change (&rest _)
  "Update the frame's bg and fg colors based on the buffer's major mode."
  ;; TODO standardize detecting the major mode using a list
  (when terminal-colors-frame-color-vterm-update-frame-color
    (unless (and terminal-colors-frame-color--theme-background
                 terminal-colors-frame-color--theme-foreground)
      (terminal-colors-frame-color--save-theme-fg-bg))
    (let ((buf (window-buffer (selected-window))))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (let* ((term-p (or (and (derived-mode-p 'vterm-mode)
                                  (bound-and-true-p terminal-colors-vterm-mode))
                             (and (derived-mode-p 'term-mode)
                                  (bound-and-true-p terminal-colors-term-mode))
                             (and (derived-mode-p 'eat-mode)
                                  (bound-and-true-p terminal-colors-eat-mode))))
                 (fg-color (if (and term-p
                                    (bound-and-true-p terminal-colors--foreground))
                               terminal-colors--foreground
                             terminal-colors-frame-color--theme-foreground))
                 (bg-color (if (and term-p
                                    (bound-and-true-p terminal-colors--background))
                               terminal-colors--background
                             terminal-colors-frame-color--theme-background)))
            (when (and fg-color (not (member fg-color
                                             '(unspecified-fg "unspecified-fg"))))
              (set-frame-parameter nil 'foreground-color fg-color))
            (when (and bg-color (not (member bg-color
                                             '(unspecified-bg "unspecified-bg"))))
              (set-frame-parameter nil 'background-color bg-color))))))))

;;; Functions

(defun terminal-colors--save-faces (faces)
  "Return the override specs and frame attributes of FACES."
  (mapcar
   (lambda (face)
     (list face (copy-tree (get face 'face-override-spec))
           (mapcar (lambda (frame)
                     (cons frame (face-all-attributes face frame)))
                   (cons t (frame-list)))))
   (delete-dups
    (mapcar (lambda (face) (or (get face 'face-alias) face)) faces))))

(defun terminal-colors--restore-faces (saved)
  "Restore face specs and frame attributes from SAVED."
  (dolist (entry saved)
    (let ((face (car entry))
          (default-attributes (cdr (assq t (nth 2 entry)))))
      (face-spec-set face (cadr entry) 'face-override-spec)
      (dolist (attribute default-attributes)
        (set-face-attribute face t (car attribute) (cdr attribute)))
      (dolist (frame (frame-list))
        (when (frame-live-p frame)
          (let ((attributes (or (cdr (assq frame (nth 2 entry)))
                                default-attributes)))
            (dolist (attribute attributes)
              (set-face-attribute face frame
                                  (car attribute) (cdr attribute)))))))))

(defun terminal-colors--apply ()
  "Update the Terminal Themes faces."
  (set-face-attribute 'terminal-colors-term-color-black nil
                      :foreground terminal-colors--color-black
                      :background terminal-colors--color-black)

  (set-face-attribute 'terminal-colors-term-color-red nil
                      :foreground terminal-colors--color-red
                      :background terminal-colors--color-red)

  (set-face-attribute 'terminal-colors-term-color-green nil
                      :foreground terminal-colors--color-green
                      :background terminal-colors--color-green)

  (set-face-attribute 'terminal-colors-term-color-yellow nil
                      :foreground terminal-colors--color-yellow
                      :background terminal-colors--color-yellow)

  (set-face-attribute 'terminal-colors-term-color-blue nil
                      :foreground terminal-colors--color-blue
                      :background terminal-colors--color-blue)

  (set-face-attribute 'terminal-colors-term-color-magenta nil
                      :foreground terminal-colors--color-magenta
                      :background terminal-colors--color-magenta)

  (set-face-attribute 'terminal-colors-term-color-cyan nil
                      :foreground terminal-colors--color-cyan
                      :background terminal-colors--color-cyan)

  (set-face-attribute 'terminal-colors-term-color-white nil
                      :foreground terminal-colors--color-white
                      :background terminal-colors--color-white)

  (set-face-attribute 'terminal-colors-term-color-bright-black nil
                      :foreground terminal-colors--color-bright-black
                      :background terminal-colors--color-bright-black)

  (set-face-attribute 'terminal-colors-term-color-bright-red nil
                      :foreground terminal-colors--color-bright-red
                      :background terminal-colors--color-bright-red)

  (set-face-attribute 'terminal-colors-term-color-bright-green nil
                      :foreground terminal-colors--color-bright-green
                      :background terminal-colors--color-bright-green)

  (set-face-attribute 'terminal-colors-term-color-bright-yellow nil
                      :foreground terminal-colors--color-bright-yellow
                      :background terminal-colors--color-bright-yellow)

  (set-face-attribute 'terminal-colors-term-color-bright-blue nil
                      :foreground terminal-colors--color-bright-blue
                      :background terminal-colors--color-bright-blue)

  (set-face-attribute 'terminal-colors-term-color-bright-magenta nil
                      :foreground terminal-colors--color-bright-magenta
                      :background terminal-colors--color-bright-magenta)

  (set-face-attribute 'terminal-colors-term-color-bright-cyan nil
                      :foreground terminal-colors--color-bright-cyan
                      :background terminal-colors--color-bright-cyan)

  (set-face-attribute 'terminal-colors-term-color-bright-white nil
                      :foreground terminal-colors--color-bright-white
                      :background terminal-colors--color-bright-white))

(defun terminal-colors--reset ()
  "Reset colors to their default values."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when terminal-colors--remap-cookies
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (when terminal-colors-frame-color-vterm-update-frame-color
    (when (and terminal-colors-frame-color--theme-foreground
               (not (member terminal-colors-frame-color--theme-foreground
                            '(unspecified-fg "unspecified-fg"))))
      (set-frame-parameter nil 'foreground-color
                           terminal-colors-frame-color--theme-foreground))
    (when (and terminal-colors-frame-color--theme-background
               (not (member terminal-colors-frame-color--theme-background
                            '(unspecified-bg "unspecified-bg"))))
      (set-frame-parameter nil 'background-color
                           terminal-colors-frame-color--theme-background)))
  (run-hooks 'terminal-colors--reset-hook))

(defun terminal-colors--load-default-default-fg-bg (default-fg-bg)
  "Load default terminal background, foreground, and cursor color.
DEFAULT-FG-BG is the name of an item in
`terminal-colors-default-foreground-background'."
  (let ((colors (cdr (assoc default-fg-bg
                            terminal-colors-default-foreground-background))))
    (unless colors
      (error "No colors found for %s" default-fg-bg))
    (let ((fg (cdr (assoc "foreground" colors)))
          (bg (cdr (assoc "background" colors)))
          (cursor (cdr (assoc "cursor" colors))))
      (unless fg
        (error "Foreground color not defined for %s" default-fg-bg))
      (unless bg
        (error "Background color not defined for %s" default-fg-bg))
      (setq terminal-colors--foreground fg)
      (setq terminal-colors--background bg)
      (setq terminal-colors--cursor (or cursor fg)))))

(defun terminal-colors--set-foreground-background (&rest _)
  "Update the buffer's background, foreground, and fringe colors."
  (when terminal-colors--remap-cookies
    (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
    (setq terminal-colors--remap-cookies nil))
  (push (face-remap-add-relative 'default
                                 :foreground terminal-colors--foreground
                                 :background terminal-colors--background)
        terminal-colors--remap-cookies)
  (push (face-remap-add-relative 'fringe
                                 :foreground terminal-colors--foreground
                                 :background terminal-colors--background)
        terminal-colors--remap-cookies)
  ;; TODO Fix this. It doesn't work.
  ;; (push (face-remap-add-relative 'cursor
  ;;                                :background terminal-colors--cursor
  ;;                                :foreground terminal-colors--background)
  ;;       terminal-colors--remap-cookies)
  )

(defun terminal-colors--update-all-buffers ()
  "Apply the buffer-local face remappings to all existing terminal buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (or (and (derived-mode-p 'vterm-mode)
                     (bound-and-true-p terminal-colors-vterm-mode))
                (and (derived-mode-p 'term-mode)
                     (bound-and-true-p terminal-colors-term-mode))
                (and (derived-mode-p 'eat-mode)
                     (bound-and-true-p terminal-colors-eat-mode)))
        (terminal-colors--set-foreground-background)))))

(defvar terminal-colors--init-p nil
  "Non-nil when init is done.")

(defun terminal-colors--reload-theme (&rest _)
  "Reload the terminal theme."
  (terminal-colors-load (or terminal-colors--current-theme-name
                            terminal-colors-default-theme)))

(defun terminal-colors--load-theme-around (function &rest args)
  "Call FUNCTION with ARGS while preserving terminal theme cleanup state."
  (terminal-colors--reset)
  (unwind-protect
      (apply function args)
    (terminal-colors-frame-color--save-theme-fg-bg)
    (terminal-colors--reload-theme)))

(defun terminal-colors--maybe-uninit ()
  "Remove theme advice when all terminal integrations are disabled."
  (unless (or (bound-and-true-p terminal-colors-eat-mode)
              (bound-and-true-p terminal-colors-term-mode)
              (bound-and-true-p terminal-colors-vterm-mode))
    (remove-hook 'window-buffer-change-functions
                 #'terminal-colors-frame-color--auto-change)
    (remove-hook 'window-selection-change-functions
                 #'terminal-colors-frame-color--auto-change)
    (advice-remove 'load-theme #'terminal-colors--load-theme-around)
    (setq terminal-colors--init-p nil)))

(defun terminal-colors--init ()
  "Init terminal themes."
  (if terminal-colors--init-p
      (run-hooks 'terminal-colors--after-load-hook)
    (terminal-colors-frame-color--save-theme-fg-bg)
    (terminal-colors--reload-theme)
    (add-hook 'window-buffer-change-functions
              #'terminal-colors-frame-color--auto-change)
    (add-hook 'window-selection-change-functions
              #'terminal-colors-frame-color--auto-change)
    (advice-add 'load-theme :around #'terminal-colors--load-theme-around)
    (setq terminal-colors--init-p t)))

(defun terminal-colors-get-all-theme-names ()
  "Return a list of all available theme names."
  (mapcar #'car terminal-colors-colors))

;;;###autoload
(defun terminal-colors-load (&optional theme)
  "Load terminal theme by THEME, applying color and default settings."
  (interactive (list (completing-read "Select theme: "
                                      (mapcar #'car terminal-colors-colors)
                                      nil t)))
  (unless theme
    (setq theme terminal-colors-default-theme))
  (let* ((theme-data (cdr (assoc theme terminal-colors-colors)))
         (default-colors (cdr (assoc "default-colors" theme-data)))
         (color-alist (cdr (assoc "colors" theme-data))))
    (unless color-alist
      (error "The terminal theme %s was not found" theme))
    (unless default-colors
      (error "The terminal theme default fg and bg %s was not found"
             theme))
    (when default-colors
      (terminal-colors--load-default-default-fg-bg default-colors))
    (mapc (lambda (color-pair)
            (let ((color-name (car color-pair))
                  (color-value (cdr color-pair)))
              (set (intern (format "terminal-colors--color-%s" color-name))
                   color-value)))  ; Set the dynamic color variable
          color-alist)
    (run-hooks 'terminal-colors--before-load-hook)
    (terminal-colors--apply)
    (terminal-colors--update-all-buffers)
    (setq terminal-colors--current-theme-name theme)
    (when (called-interactively-p 'interactive)
      (message "Theme '%s' loaded with default colors %s."
               theme default-colors))
    (run-hooks 'terminal-colors--after-load-hook)
    (terminal-colors-frame-color--auto-change)))

;;; Eat

(defvar terminal-colors-eat--saved-faces nil
  "Face state saved before applying terminal colors.")

(defun terminal-colors-eat--process-output (orig-fun &rest args)
  "Intercept `face-attribute' lookups during Eat output processing.

Buffer-local face remappings (which this package uses to apply the terminal
theme) only affect the Emacs display engine. Standard Lisp queries like
`face-attribute' ignore these remappings and will return the global Emacs theme
colors.

When `eat' processes terminal output (ORIG-FUN), it frequently queries the
`default' face to handle features like SGR inverse video or OSC color reporting.

This advice dynamically overrides `face-attribute' during execution to ensure
that `eat' receives the isolated, buffer-local terminal
colors (`terminal-colors--foreground' and `terminal-colors--background') rather
than the global Emacs theme colors.

ARGS are the arguments passed to ORIG-FUN."
  (let ((original-face-attribute (symbol-function 'face-attribute)))
    (cl-letf (((symbol-function 'face-attribute)
               (lambda (face attribute &optional frame inherit)
                 (let ((color
                        (and (eq face 'default)
                             (null frame)
                             terminal-colors-eat--saved-faces
                             (derived-mode-p 'eat-mode)
                             (pcase attribute
                               (:foreground terminal-colors--foreground)
                               (:background terminal-colors--background)))))
                   (or color
                       (funcall original-face-attribute
                                face attribute frame inherit))))))
      (apply orig-fun args))))

(defun terminal-colors-eat--set-foreground-background ()
  "Set the terminal theme foreground and background color."
  (when (derived-mode-p 'eat-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-eat--reset ()
  "Reset eat terminal theme."
  (terminal-colors--restore-faces terminal-colors-eat--saved-faces)
  (setq terminal-colors-eat--saved-faces nil)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'eat-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil)))))

(defun terminal-colors-eat--apply ()
  "Apply eat terminal theme."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-eat--set-foreground-background)))

  (when (featurep 'eat)
    (unless terminal-colors-eat--saved-faces
      (setq terminal-colors-eat--saved-faces
            (terminal-colors--save-faces
             '(eat-term-color-0 eat-term-color-1 eat-term-color-2
                                eat-term-color-3 eat-term-color-4 eat-term-color-5
                                eat-term-color-6 eat-term-color-7 eat-term-color-8
                                eat-term-color-9 eat-term-color-10 eat-term-color-11
                                eat-term-color-12 eat-term-color-13 eat-term-color-14
                                eat-term-color-15))))
    (face-spec-set 'eat-term-color-0
                   `((t (:foreground ,terminal-colors--color-black
                                     :background ,terminal-colors--color-black))))

    (face-spec-set 'eat-term-color-1
                   `((t (:foreground ,terminal-colors--color-red
                                     :background ,terminal-colors--color-red))))

    (face-spec-set 'eat-term-color-2
                   `((t (:foreground ,terminal-colors--color-green
                                     :background ,terminal-colors--color-green))))

    (face-spec-set 'eat-term-color-3
                   `((t (:foreground ,terminal-colors--color-yellow
                                     :background ,terminal-colors--color-yellow))))

    (face-spec-set 'eat-term-color-4
                   `((t (:foreground ,terminal-colors--color-blue
                                     :background ,terminal-colors--color-blue))))

    (face-spec-set 'eat-term-color-5
                   `((t (:foreground ,terminal-colors--color-magenta
                                     :background ,terminal-colors--color-magenta))))

    (face-spec-set 'eat-term-color-6
                   `((t (:foreground ,terminal-colors--color-cyan
                                     :background ,terminal-colors--color-cyan))))

    (face-spec-set 'eat-term-color-7
                   `((t (:foreground ,terminal-colors--color-white
                                     :background ,terminal-colors--color-white))))

    (face-spec-set 'eat-term-color-8
                   `((t (:foreground ,terminal-colors--color-bright-black
                                     :background ,terminal-colors--color-bright-black))))

    (face-spec-set 'eat-term-color-9
                   `((t (:foreground ,terminal-colors--color-bright-red
                                     :background ,terminal-colors--color-bright-red))))

    (face-spec-set 'eat-term-color-10
                   `((t (:foreground ,terminal-colors--color-bright-green
                                     :background ,terminal-colors--color-bright-green))))

    (face-spec-set 'eat-term-color-11
                   `((t (:foreground ,terminal-colors--color-bright-yellow
                                     :background ,terminal-colors--color-bright-yellow))))

    (face-spec-set 'eat-term-color-12
                   `((t (:foreground ,terminal-colors--color-bright-blue
                                     :background ,terminal-colors--color-bright-blue))))

    (face-spec-set 'eat-term-color-13
                   `((t (:foreground ,terminal-colors--color-bright-magenta
                                     :background ,terminal-colors--color-bright-magenta))))

    (face-spec-set 'eat-term-color-14
                   `((t (:foreground ,terminal-colors--color-bright-cyan
                                     :background ,terminal-colors--color-bright-cyan))))

    (face-spec-set 'eat-term-color-15
                   `((t (:foreground ,terminal-colors--color-bright-white
                                     :background ,terminal-colors--color-bright-white))))))

;;;###autoload
(define-minor-mode terminal-colors-eat-mode
  "Toggle `terminal-colors-eat-mode'."
  :global t
  :lighter " TThemesEat"
  :group 'terminal-colors-eat
  (if terminal-colors-eat-mode
      (condition-case err
          (progn
            (require 'eat)
            (if (fboundp 'terminal-colors-eat--process-output)
                (advice-add 'eat-term-process-output :around
                            #'terminal-colors-eat--process-output)
              (message "[terminal-colors] Warning: terminal-colors-eat--process-output"))
            (add-hook 'terminal-colors--after-load-hook
                      #'terminal-colors-eat--apply)
            (add-hook 'terminal-colors--reset-hook #'terminal-colors-eat--reset)
            (add-hook 'eat-mode-hook
                      #'terminal-colors-eat--set-foreground-background)
            (terminal-colors--init))
        (error
         (terminal-colors-eat-mode -1)
         (signal (car err) (cdr err))))
    (advice-remove 'eat-term-process-output
                   #'terminal-colors-eat--process-output)
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-eat--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-eat--reset)
    (remove-hook 'eat-mode-hook
                 #'terminal-colors-eat--set-foreground-background)
    (terminal-colors-eat--reset)
    (terminal-colors--maybe-uninit)))

;;; term

(defvar terminal-colors-term--backup-color-vector 'unset
  "A backup of the `ansi-term' color vector.")

(defvar terminal-colors-term--saved-faces nil
  "Face state saved before applying terminal colors.")

(defun terminal-colors-term--set-foreground-background ()
  "Set the `term' foreground and background color."
  (when (derived-mode-p 'term-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-term--reset ()
  "Reset the `term' terminal theme."
  (terminal-colors--restore-faces terminal-colors-term--saved-faces)
  (setq terminal-colors-term--saved-faces nil)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'term-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (unless (eq terminal-colors-term--backup-color-vector 'unset)
    (set-default 'ansi-term-color-vector terminal-colors-term--backup-color-vector)
    (setq terminal-colors-term--backup-color-vector 'unset)))

(defun terminal-colors-term--apply ()
  "Apply the `term' theme."
  (when (featurep 'term)
    (unless terminal-colors-term--saved-faces
      (setq terminal-colors-term--saved-faces
            (terminal-colors--save-faces
             '(term term-color-black term-color-red term-color-green
                    term-color-yellow term-color-blue term-color-magenta
                    term-color-cyan term-color-white term-color-bright-black
                    term-color-bright-red term-color-bright-green
                    term-color-bright-yellow term-color-bright-blue
                    term-color-bright-magenta term-color-bright-cyan
                    term-color-bright-white))))
    (when (eq terminal-colors-term--backup-color-vector 'unset)
      (setq terminal-colors-term--backup-color-vector (default-value 'ansi-term-color-vector)))

    (set-default 'ansi-term-color-vector [term terminal-colors-term-color-black
                                               terminal-colors-term-color-red
                                               terminal-colors-term-color-green
                                               terminal-colors-term-color-yellow
                                               terminal-colors-term-color-blue
                                               terminal-colors-term-color-magenta
                                               terminal-colors-term-color-cyan
                                               terminal-colors-term-color-white
                                               terminal-colors-term-color-bright-black
                                               terminal-colors-term-color-bright-red
                                               terminal-colors-term-color-bright-green
                                               terminal-colors-term-color-bright-yellow
                                               terminal-colors-term-color-bright-blue
                                               terminal-colors-term-color-bright-magenta
                                               terminal-colors-term-color-bright-cyan
                                               terminal-colors-term-color-bright-white])

    ;; term
    (set-face-attribute 'term nil
                        :foreground terminal-colors--foreground
                        :background terminal-colors--background)

    (set-face-attribute 'term-color-black nil
                        :foreground terminal-colors--color-black
                        :background terminal-colors--color-black)

    (set-face-attribute 'term-color-red nil
                        :foreground terminal-colors--color-red
                        :background terminal-colors--color-red)

    (set-face-attribute 'term-color-green nil
                        :foreground terminal-colors--color-green
                        :background terminal-colors--color-green)

    (set-face-attribute 'term-color-yellow nil
                        :foreground terminal-colors--color-yellow
                        :background terminal-colors--color-yellow)

    (set-face-attribute 'term-color-blue nil
                        :foreground terminal-colors--color-blue
                        :background terminal-colors--color-blue)

    (set-face-attribute 'term-color-magenta nil
                        :foreground terminal-colors--color-magenta
                        :background terminal-colors--color-magenta)

    (set-face-attribute 'term-color-cyan nil
                        :foreground terminal-colors--color-cyan
                        :background terminal-colors--color-cyan)

    (set-face-attribute 'term-color-white nil
                        :foreground terminal-colors--color-white
                        :background terminal-colors--color-white)

    (set-face-attribute 'term-color-bright-black nil
                        :foreground terminal-colors--color-bright-black
                        :background terminal-colors--color-bright-black)

    (set-face-attribute 'term-color-bright-red nil
                        :foreground terminal-colors--color-bright-red
                        :background terminal-colors--color-bright-red)

    (set-face-attribute 'term-color-bright-green nil
                        :foreground terminal-colors--color-bright-green
                        :background terminal-colors--color-bright-green)

    (set-face-attribute 'term-color-bright-yellow nil
                        :foreground terminal-colors--color-bright-yellow
                        :background terminal-colors--color-bright-yellow)

    (set-face-attribute 'term-color-bright-blue nil
                        :foreground terminal-colors--color-bright-blue
                        :background terminal-colors--color-bright-blue)

    (set-face-attribute 'term-color-bright-magenta nil
                        :foreground terminal-colors--color-bright-magenta
                        :background terminal-colors--color-bright-magenta)

    (set-face-attribute 'term-color-bright-cyan nil
                        :foreground terminal-colors--color-bright-cyan
                        :background terminal-colors--color-bright-cyan)

    (set-face-attribute 'term-color-bright-white nil
                        :foreground terminal-colors--color-bright-white
                        :background terminal-colors--color-bright-white))

  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-term--set-foreground-background))))

;;;###autoload
(define-minor-mode terminal-colors-term-mode
  "Toggle `terminal-colors-term-mode'."
  :global t
  :lighter " TThemesAnsi-Color"
  :group 'terminal-colors-term
  (if terminal-colors-term-mode
      (condition-case err
          (progn
            (require 'term)
            (add-hook 'terminal-colors--after-load-hook
                      #'terminal-colors-term--apply)
            (add-hook 'terminal-colors--reset-hook
                      #'terminal-colors-term--reset)
            (add-hook 'term-mode-hook
                      #'terminal-colors-term--set-foreground-background)
            (terminal-colors--init))
        (error
         (terminal-colors-term-mode -1)
         (signal (car err) (cdr err))))
    ;; Remove
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-term--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-term--reset)
    (remove-hook 'term-mode-hook
                 #'terminal-colors-term--set-foreground-background)
    (terminal-colors-term--reset)
    (terminal-colors--maybe-uninit)))

;;; vterm

(defvar terminal-colors-vterm--backup-color-palette 'unset
  "A backup of the vterm color palette.")

(defvar terminal-colors-vterm--saved-faces nil
  "Face state saved before applying terminal colors.")

(defun terminal-colors-vterm--set-foreground-background ()
  "Set the `vterm' foreground and background color."
  (when (derived-mode-p 'vterm-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-vterm--set-face-attribute ()
  "Set the face attributes of `vterm'."
  (when (featurep 'vterm)
    (unless terminal-colors-vterm--saved-faces
      (setq terminal-colors-vterm--saved-faces
            (terminal-colors--save-faces
             '(vterm-color-black vterm-color-red vterm-color-green
                                 vterm-color-yellow vterm-color-blue vterm-color-magenta
                                 vterm-color-cyan vterm-color-white vterm-color-bright-black
                                 vterm-color-bright-red vterm-color-bright-green
                                 vterm-color-bright-yellow vterm-color-bright-blue
                                 vterm-color-bright-magenta vterm-color-bright-cyan
                                 vterm-color-bright-white))))
    (set-face-attribute 'vterm-color-black nil
                        :foreground terminal-colors--color-black
                        :background terminal-colors--color-black)
    (set-face-attribute 'vterm-color-red nil
                        :foreground terminal-colors--color-red
                        :background terminal-colors--color-red)
    (set-face-attribute 'vterm-color-green nil
                        :foreground terminal-colors--color-green
                        :background terminal-colors--color-green)
    (set-face-attribute 'vterm-color-yellow nil
                        :foreground terminal-colors--color-yellow
                        :background terminal-colors--color-yellow)
    (set-face-attribute 'vterm-color-blue nil
                        :foreground terminal-colors--color-blue
                        :background terminal-colors--color-blue)
    (set-face-attribute 'vterm-color-magenta nil
                        :foreground terminal-colors--color-magenta
                        :background terminal-colors--color-magenta)
    (set-face-attribute 'vterm-color-cyan nil
                        :foreground terminal-colors--color-cyan
                        :background terminal-colors--color-cyan)
    (set-face-attribute 'vterm-color-white nil
                        :foreground terminal-colors--color-white
                        :background terminal-colors--color-white)
    (set-face-attribute 'vterm-color-bright-black nil
                        :foreground terminal-colors--color-bright-black
                        :background terminal-colors--color-bright-black)
    (set-face-attribute 'vterm-color-bright-red nil
                        :foreground terminal-colors--color-bright-red
                        :background terminal-colors--color-bright-red)
    (set-face-attribute 'vterm-color-bright-green nil
                        :foreground terminal-colors--color-bright-green
                        :background terminal-colors--color-bright-green)
    (set-face-attribute 'vterm-color-bright-yellow nil
                        :foreground terminal-colors--color-bright-yellow
                        :background terminal-colors--color-bright-yellow)
    (set-face-attribute 'vterm-color-bright-blue nil
                        :foreground terminal-colors--color-bright-blue
                        :background terminal-colors--color-bright-blue)
    (set-face-attribute 'vterm-color-bright-magenta nil
                        :foreground terminal-colors--color-bright-magenta
                        :background terminal-colors--color-bright-magenta)
    (set-face-attribute 'vterm-color-bright-cyan nil
                        :foreground terminal-colors--color-bright-cyan
                        :background terminal-colors--color-bright-cyan)
    (set-face-attribute 'vterm-color-bright-white nil
                        :foreground terminal-colors--color-bright-white
                        :background terminal-colors--color-bright-white)))

(defun terminal-colors-vterm--get-color-override (orig-fun index &rest args)
  "Return the terminal default color or call ORIG-FUN with INDEX and ARGS.
Preserve indexed colors and explicit underline and `inverse-video' colors."
  (if (and (bound-and-true-p terminal-colors-vterm-mode)
           (not (eq terminal-colors-vterm--backup-color-palette 'unset))
           (derived-mode-p 'vterm-mode)
           (= index -1))
      (let* ((foreground (memq :foreground args))
             (attribute (if foreground :foreground :background))
             (face (cond
                    ((and foreground (memq :underline args))
                     'vterm-color-underline)
                    ((and (not foreground) (memq :inverse-video args))
                     'vterm-color-inverse-video)))
             (color (and face (face-attribute face attribute nil nil)))
             (inherit (and face (face-attribute face :inherit nil nil)))
             (default-color (if foreground
                                terminal-colors--foreground
                              terminal-colors--background)))
        (if (and default-color
                 (or (null color) (eq color 'unspecified))
                 (member inherit '(nil unspecified default (default))))
            default-color
          (apply orig-fun index args)))
    (apply orig-fun index args)))

(defun terminal-colors-vterm--redraw ()
  "Redraw the current vterm buffer unless copy mode is active."
  (when (and (derived-mode-p 'vterm-mode)
             (not (bound-and-true-p vterm-copy-mode))
             (bound-and-true-p vterm--term))
    (let ((inhibit-read-only t)
          (inhibit-redisplay t))
      (vterm--redraw vterm--term))))

(defun terminal-colors-vterm--reset ()
  "Reset the Terminal Theme."
  (terminal-colors--restore-faces terminal-colors-vterm--saved-faces)
  (setq terminal-colors-vterm--saved-faces nil)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'vterm-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (unless (eq terminal-colors-vterm--backup-color-palette 'unset)
    (set-default 'vterm-color-palette terminal-colors-vterm--backup-color-palette)
    (setq terminal-colors-vterm--backup-color-palette 'unset))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (terminal-colors-vterm--redraw))))

(defun terminal-colors-vterm--apply ()
  "Apply the Terminal Theme and refresh visible vterm buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-vterm--set-foreground-background)))
  (when (and (featurep 'vterm)
             (eq terminal-colors-vterm--backup-color-palette 'unset))
    (setq terminal-colors-vterm--backup-color-palette (default-value 'vterm-color-palette))
    (set-default 'vterm-color-palette [terminal-colors-term-color-black
                                       terminal-colors-term-color-red
                                       terminal-colors-term-color-green
                                       terminal-colors-term-color-yellow
                                       terminal-colors-term-color-blue
                                       terminal-colors-term-color-magenta
                                       terminal-colors-term-color-cyan
                                       terminal-colors-term-color-white
                                       terminal-colors-term-color-bright-black
                                       terminal-colors-term-color-bright-red
                                       terminal-colors-term-color-bright-green
                                       terminal-colors-term-color-bright-yellow
                                       terminal-colors-term-color-bright-blue
                                       terminal-colors-term-color-bright-magenta
                                       terminal-colors-term-color-bright-cyan
                                       terminal-colors-term-color-bright-white]))
  (terminal-colors-vterm--set-face-attribute)
  ;; Force active vterm buffers to redraw to display the new theme immediately
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (terminal-colors-vterm--redraw))))

;;;###autoload
(define-minor-mode terminal-colors-vterm-mode
  "Toggle `terminal-colors-vterm-mode'."
  :global t
  :lighter " TVTerm"
  :group 'terminal-colors-vterm
  (if terminal-colors-vterm-mode
      (condition-case err
          (progn
            (require 'vterm)
            (if (fboundp 'terminal-colors-vterm--get-color-override)
                (advice-add 'vterm--get-color :around #'terminal-colors-vterm--get-color-override)
              (message "[terminal-colors] Warning: terminal-colors-vterm--get-color-override"))
            (add-hook 'terminal-colors--after-load-hook
                      #'terminal-colors-vterm--apply)
            (add-hook 'terminal-colors--reset-hook
                      #'terminal-colors-vterm--reset)
            (add-hook 'vterm-mode-hook
                      #'terminal-colors-vterm--set-foreground-background)
            (terminal-colors--init))
        (error
         (terminal-colors-vterm-mode -1)
         (signal (car err) (cdr err))))
    ;; Disable
    (advice-remove 'vterm--get-color #'terminal-colors-vterm--get-color-override)
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-vterm--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-vterm--reset)
    (remove-hook 'vterm-mode-hook
                 #'terminal-colors-vterm--set-foreground-background)
    (terminal-colors-vterm--reset)
    (terminal-colors--maybe-uninit)))

(provide 'terminal-colors)

;;; terminal-colors.el ends here
