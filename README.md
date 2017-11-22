# CSC453_Assignment3

## Install
```
gem install bundler
bundle install
```

## Run Tests
```
cd tests
rake test
```

## Description
Run our program using the provided ```hg``` interface. This is a simple distributed version control system.

## Design Decisions and Notes
When merging, the result will be committed regardless of whether there are conflicts or not. If there are conflicts, they will be recorded in the conflicting file(s) according to the output of ```diff3 -E -m```; conflicts should be resolved manually and then committed.

Merging with a repository will first fetch ALL commits not contained in the current repository. However, the only revision used to determine which file versions to merge is the revision currently checked out in that repository.

```hg commit <files>``` is equivalent to ```hg add <files>``` immediately followed by ```hg commit```.

Commits do not have commit messages, nor authors, nor timestamps. They have a revision number and either one parent or two (in the case of a merge).
