;; Batch export org-mode files to RST for Sphinx.
;; Usage (cwd = docs/): emacs --batch --load export.el
;; Org under orgmode/ is the source. RST under ./source/ is generated
;; and committed so CI stays `sphinx-build docs/source`.
(require 'package)
(package-initialize)

(defconst yoda-ox-rst-version '(20250428 534))
(defconst yoda-ox-rst-revision
  "b73eff187eebac24b457688bfd27f09eff434860")

(let ((installed (cadr (assq 'ox-rst package-alist))))
  (unless (and installed
               (equal (package-desc-version installed)
                      yoda-ox-rst-version))
    (when installed
      (package-delete installed t))
    (require 'package-vc)
    (package-vc-install
     `(ox-rst
       :url "https://github.com/msnoigrs/ox-rst"
       :rev ,yoda-ox-rst-revision))))

(require 'ox-rst)
(require 'ox-publish)

;; ox-rst 2025-04 needs org-element-type-p (Org 9.7+). Ubuntu emacs-nox is 29/9.6.
(require 'org-element)
(unless (fboundp 'org-element-type-p)
  (defun org-element-type-p (node types)
    (memq (org-element-type node)
          (if (listp types) types (list types)))))

(unless (fboundp 'org-element-parent)
  (defun org-element-parent (node)
    (org-element-property :parent node)))

(unless (fboundp 'org-element-parent-element)
  (defun org-element-parent-element (node)
    (org-element-property :parent node)))

(unless (fboundp 'org-element-extract)
  (defun org-element-extract (node)
    (let ((parent (org-element-parent node))
          (secondary (org-element-secondary-p node)))
      (if secondary
          (org-element-put-property
           parent secondary
           (delq node (org-element-property secondary parent)))
        (apply #'org-element-set-contents
               parent
               (delq node (org-element-contents parent))))
      (org-element-put-property node :parent nil))))

(unless (fboundp 'org-element-begin)
  (defun org-element-begin (node)
    (org-element-property :begin node)))

(when (version< (org-version) "9.7")
  (advice-add
   'org-element-lineage :around
   (lambda (function node &optional types with-self)
     (funcall function node (if (symbolp types) (list types) types) with-self))))

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
