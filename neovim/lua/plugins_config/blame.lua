return {
    date_format = "%d.%m.%Y",
    virtual_style = "right",
    views = {
        window = window_view,
        virtual = virtual_view,
        default = window_view,
    },
    merge_consecutive = false,
    max_summary_width = 30,
    colors = nil,
    commit_detail_view = "vsplit",
    mappings = {
        commit_info = "i",
        stack_push = "<TAB>",
        stack_pop = "<BS>",
        show_commit = "<CR>",
        close = { "<esc>", "q" },
    }
}
