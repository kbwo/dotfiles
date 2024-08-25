require('possession').setup {
    commands = {
        save_cwd = 'SSave',
        load_cwd = 'SLoad',
        delete = 'SDelete',
        list = 'SList',
    },
    autosave = {
      current = false,
      cwd = true,
      tmp = false,
      on_load = false,
      on_quit = true,
    }
}
