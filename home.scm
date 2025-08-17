;; home.scm
(use-modules (gnu home)
	     (gnu home services)
	     (gnu home services shells)
	     (gnu packages)
             (gnu packages compression)  ; unzip
             (guix gexp)
             (guix packages)
             (guix download)
             (guix build-system font)
             ((guix licenses) #:prefix license:))

;; --- Nerd Font (Noto) ---
(define-public font-nerd-noto
  (package
    (name "font-nerd-noto")
    (version "3.4.0") ; Match the Nerd Fonts release tag (e.g., v3.4.0)
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/ryanoasis/nerd-fonts/releases/download/v"
                    version "/Noto.zip"))
              ;; Replace with the actual base32 hash for the ZIP you fetch.
              (sha256 (base32 "1fa4nn8ghprfnv3hq6r43lq1qjlmfwi5nkrj6kpa78w8nyhki47b"))))
    (build-system font-build-system)
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Noto font patched with Nerd Fonts glyphs")
    (description "Noto font patched with Nerd Fonts glyphs.")
    (license license:silofl1.1)
    ;; Ensure ZIP extraction works
    (native-inputs (list unzip))
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (use-modules (guix build utils))
              (let* ((out (assoc-ref outputs "out"))
                     (dest (string-append out "/share/fonts/truetype")))
                (mkdir-p dest)
                (for-each
                 (lambda (f) (install-file f dest))
                 (find-files "." "\\.ttf$"))
                #t))))))))

(home-environment
  ;; Packages to install in the profile
  (packages
    (append
      (list font-nerd-noto)
      (specifications->packages
        '("font-google-noto-emoji"
          "font-google-noto"
          "font-google-noto-sans-cjk"
          "emacs-nerd-icons"

	  "nss-certs"
	  "git"
	  "openssh"
	  "emacs"
	  "gcc-toolchain"
	  "tree-sitter"
	  "tree-sitter-cli"
	  ))))

  (services
    (list
     (service home-bash-service-type
	      (home-bash-configuration
               (aliases '(("ll" . "ls -l")))
               (bashrc
		(list
		 (plain-file "guix-bashrc"
			     "export EDITOR=emacs
GUIX_PROFILE=\"$(echo ~root)/.config/guix/current\"
if [ -r \"$GUIX_PROFILE/etc/profile\" ]; then
  . \"$GUIX_PROFILE/etc/profile\"
fi
guix-daemon --build-users-group=guixbuild &
")))))))
  )
