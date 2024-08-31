const { CancellationTokenSource, workspace, languages } = require("coc.nvim");

exports.activate = (_context) => {
  const nvim = workspace.nvim;
  const updateDocumentSymbols = async () => {
    const symbols = await getFullDocumentSymbols();
    await nvim.setVar("FullDocumentSymbols", JSON.stringify(symbols));
  };
  const requestHandler = new RequestHandler(100);
  workspace.onDidOpenTextDocument(async () => {
    await updateDocumentSymbols();
  });
  workspace.onDidChangeTextDocument(async () => {
    requestHandler.debounceRequest(async () => {
      await updateDocumentSymbols();
    });
  });
  workspace.onDidCloseTextDocument(async () => {
    await updateDocumentSymbols();
  });
  // TODO: Improve this interval-based approach
  setInterval(async () => {
    try {
      await updateDocumentSymbols();
    } catch (error) {
      console.error("Failed to update document symbols:", error);
    }
  }, 100);
};

class RequestHandler {
  timeoutId = null;
  delay;

  constructor(delay) {
    this.delay = delay;
  }

  debounceRequest(callback) {
    if (this.timeoutId !== null) {
      clearTimeout(this.timeoutId);
    }

    this.timeoutId = setTimeout(() => {
      callback();
      this.timeoutId = null;
    }, this.delay);
  }
}
async function getFullDocumentSymbols() {
  const document = await workspace.document;
  const source = new CancellationTokenSource();
  const token = source.token;
  //@ts-ignore
  return languages.getDocumentSymbol(document.textDocument, token);
}
