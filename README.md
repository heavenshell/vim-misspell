# vim-misspell

[![Build Status](https://travis-ci.org/heavenshell/vim-misspell.svg?branch=master)](https://travis-ci.org/heavenshell/vim-misspell)

misspell for Vim.

![Realtime spell check](./assets/vim-misspell.gif)

`vim-misspell` is a wrapper of [misspell](https://github.com/client9/misspell/).

## Dependencies

Install [misspell](https://github.com/client9/misspell/#install).

## Usage

### Invoke manually

Open file and just execute `:Misspell`.

That's it.

### Automatically format on save

```viml
autocmd BufWritePost * call misspell#run()
```

## License

New BSD License
