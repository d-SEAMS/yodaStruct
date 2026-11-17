;; Batch export org-mode files to RST for Sphinx.
;; Usage (cwd = docs/): emacs --batch --load export.el
;; Org under orgmode/ is the source. RST under ./source/ is generated
;; and committed so CI stays `sphinx-build docs/source`.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; ox-rst 2025-04 uses the Org 9.7 element API; Emacs 29 bundles Org 9.6.
(unless (package-installed-p 'org '(9 7))
  (package-refresh-contents)
  (package-install (cadr (assq 'org package-archive-contents))))
(unless (package-installed-p 'ox-rst)
  (unless package-archive-contents (package-refresh-contents))
  (package-install 'ox-rst))

(require 'ox-rst)
(require 'ox-publish)
(unless (version<= "9.7" org-version)
  (error "ox-rst needs Org 9.7 or newer; loaded Org %s" org-version))

(setq org-export-with-section-numbers nil)
(setq org-export-with-toc nil)
(setq org-export-with-author nil)
(setq org-export-with-timestamps nil)
(setq org-rst-headline-underline ?-)

(setq org-publish-project-alist
      '(("yodaStruct-rst"
         :base-directory "./orgmode/"
         :base-extension "org"
         :publishing-directory "./source/"
         :publishing-function org-rst-publish-to-rst
         :recursive t
         :headline-levels 4
         :with-toc nil
         :section-numbers nil
         :with-author nil)))

(org-publish "yodaStruct-rst" t)
