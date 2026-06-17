const targetUrl = process.argv[2] || 'http://127.0.0.1:4173';
const debuggerBaseUrl = process.argv[3] || 'http://127.0.0.1:9222';
const waitMs = Number(process.argv[4] || 10000);

const sleep = (ms) => new Promise((resolve) => {
  setTimeout(resolve, ms);
});

async function waitForJsonEndpoint(url) {
  let lastError;

  for (let attempt = 0; attempt < 40; attempt += 1) {
    try {
      const response = await fetch(url);

      if (response.ok) {
        return response.json();
      }
    } catch (error) {
      lastError = error;
    }

    await sleep(250);
  }

  throw lastError || new Error(`Could not reach ${url}`);
}

function send(socket, id, method, params = {}, sessionId) {
  const payload = {
    id,
    method,
    params,
  };

  if (sessionId) {
    payload.sessionId = sessionId;
  }

  socket.send(JSON.stringify(payload));
}

const version = await waitForJsonEndpoint(`${debuggerBaseUrl}/json/version`);
const socket = new WebSocket(version.webSocketDebuggerUrl);
let nextId = 1;

socket.addEventListener('open', () => {
  send(socket, nextId++, 'Target.createTarget', { url: 'about:blank' });
});

socket.addEventListener('message', async (event) => {
  const message = JSON.parse(event.data);

  if (message.id === 1) {
    const { targetId } = message.result;
    send(socket, nextId++, 'Target.attachToTarget', {
      targetId,
      flatten: true,
    });
    return;
  }

  if (message.method === 'Target.attachedToTarget') {
    const { sessionId } = message.params;
    send(socket, nextId++, 'Runtime.enable', {}, sessionId);
    send(socket, nextId++, 'Log.enable', {}, sessionId);
    send(socket, nextId++, 'Page.enable', {}, sessionId);
    send(socket, nextId++, 'Page.navigate', { url: targetUrl }, sessionId);

    await sleep(waitMs);
    send(socket, nextId++, 'Runtime.evaluate', {
      expression:
        'document.body.innerText || document.documentElement.outerHTML.slice(0, 500)',
      returnByValue: true,
    }, sessionId);
    await sleep(1000);
    socket.close();
    return;
  }

  if (message.method === 'Runtime.consoleAPICalled') {
    const args = message.params.args
      .map((arg) => arg.value || arg.description || '')
      .join(' ');
    console.log(`[console.${message.params.type}] ${args}`);
  }

  if (message.method === 'Runtime.exceptionThrown') {
    console.log('[exception]', message.params.exceptionDetails.text);
    if (message.params.exceptionDetails.exception?.description) {
      console.log(message.params.exceptionDetails.exception.description);
    }
  }

  if (message.method === 'Log.entryAdded') {
    const entry = message.params.entry;
    console.log(`[${entry.level}] ${entry.text}`);
  }

  if (message.result?.result?.value) {
    console.log('[body]', message.result.result.value);
  }
});
