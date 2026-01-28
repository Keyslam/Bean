# Bean
A component oriented framework for LÖVE

[![Build status](https://github.com/Keyslam/Bean/actions/workflows/run-tests.yaml/badge.svg)](https://github.com/Keyslam/Bean/actions/workflows/run-tests.yaml)
[![Coverage](https://codecov.io/github/Keyslam/Bean/branch/main/graph/badge.svg?token=4D71ZA5CXD)](https://codecov.io/github/Keyslam/Bean)

![GitHub release](https://img.shields.io/github/v/release/Keyslam/Bean)
![License](https://img.shields.io/badge/license-MIT-green)
![LuaJIT](https://img.shields.io/badge/LuaJIT-blue)

> [!WARNING]
> **Work in progress**: Bean is still under active development. Documentation may be incomplete, inaccurate, or cover unimplemented features.

## Installation

1. Download the latest version from the  [release](https://github.com/Keyslam/Bean/releases/latest) page
2. Include the `bean` folder in your project.
3. Require it in your code:
   ```lua
   local bean = require("bean")
   ```

## Tests
Tests are located in the spec folder and are built using [Busted](https://lunarmodules.github.io/busted/).\
Run `busted spec` to run the tests.

## Versioning

Bean uses [Semantic Versioning (SemVer)](https://semver.org/), powered by [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)\
Versions and changelogs are automatically managed by [Commitizen](https://commitizen-tools.github.io/commitizen/).

## License

This project is licensed under the [MIT License](LICENSE).
