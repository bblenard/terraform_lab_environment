Update system:
    pkg.uptodate:
        - refresh: True

Install base packages:
    pkg.installed:
        - pkgs:
            - vim-enhanced
            - tree
            - tmux

