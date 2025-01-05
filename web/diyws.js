// add before end of head:
// <script src="diyws.js"></script>

function diyws(url) {
    'use strict';
    
    const LOG = false;

    const socket = new WebSocket(url);
    const pendingMessages = [];
    
    LOG && console.warn(`url: ${url}`);

    socket.addEventListener('message', (ev) => {
        LOG && console.warn(`<= ${ev.data}`);
        pendingMessages.push(ev.data);
    });

    socket.addEventListener('open', () => {
        LOG && console.warn('open');
    });

    socket.addEventListener('close', () => {
        LOG && console.warn('close');
    });

    socket.addEventListener('error', (err) => {
        console.warn(`error: ${err.message}`);
    });

    function send(op, payload) {
        if (payload == 'null') payload = '""';
        const message = JSON.stringify({ op, payload });
        LOG && console.warn(`=> ${message}`);
        socket.send(message);
    }

    function hasMessages() {
        return pendingMessages.length > 0;
    }

    function getNextMessage() {
        return pendingMessages.shift();
    }

    window.diySend = send;
    window.diyHasMessages = hasMessages;
    window.diyGetNextMessage = getNextMessage;
}
