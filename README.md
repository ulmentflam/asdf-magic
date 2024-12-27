<div align="center">

# asdf-magic [![Build](https://github.com/ulmentflam/asdf-magic/actions/workflows/build.yml/badge.svg)](https://github.com/ulmentflam/asdf-magic/actions/workflows/build.yml) [![Lint](https://github.com/ulmentflam/asdf-magic/actions/workflows/lint.yml/badge.svg)](https://github.com/ulmentflam/asdf-magic/actions/workflows/lint.yml)

[magic](https://github.com/modular) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add magic
# or
asdf plugin add magic https://github.com/ulmentflam/asdf-magic.git
```

magic:

```shell
# Show all installable versions
asdf list-all magic

# Install specific version
asdf install magic latest

# Set a version globally (on your ~/.tool-versions file)
asdf global magic latest

# Now magic commands are available
magic --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/ulmentflam/asdf-magic/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Evan Owen](https://github.com/ulmentflam/)
