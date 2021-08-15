import jedi
import traceback
import vim

curfile = vim.current.buffer.name
row = vim.current.window.cursor[0]
col = vim.current.window.cursor[1]

script = jedi.Script(
    code=None,
    path=curfile)

try:
    definitions = script.help(line=row, column=col)
    # definitions = script.goto_definitions()
except Exception:
    # print to stdout, will be in :messages
    definitions = []
    print("Exception, this shouldn't happen.")
    print(traceback.format_exc())

    if not definitions:
        echo_highlight("No documentation found for that.")
        vim.command("return")

try:
    docs = []
    for d in definitions:
        doc = d.docstring()
        if doc:
            title = "Docstring for %s" % d.full_name
            underline = "=" * len(title)
            docs.append("%s\n%s\n%s" % (title, underline, doc))
        else:
            docs.append("|No Docstring for %s|" % d)
        text = ("\n" + "-" * 79 + "\n").join(docs)
except Exception:
    print(traceback.format_exc())
    vim.command("return")

vim.command("let docWidth = %s" % len(title))
vim.command("let doc_lines = %s" % len(text.split("\n")))
