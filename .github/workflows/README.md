# DO NOT EDIT THESE FILES!

The GitHub Actions workflow YAML files in this directory are defined, validated,
and generated using the [CUE][] (Configure, Unify, Execute) data constraint
language. Editing the YAML directly will cause your changes to be rejected by
CI, as the CUE and YAML files must be in sync.

To generate these workflow YAML files, edit the CUE files under the sibling
directory, and then run the following command:

    $ cargo xtask gen-ci

[CUE]: https://cuelang.org/
