const Buffer = window.buffer.Buffer;

async function init() {
    ipfs = await window.Ipfs.create();
}
async function addFile() {
    let file = document.getElementById('file').files;

    for await (const result of ipfs.add(file)) {
        log(`Added file:, ${result.path}`);
    }
}

async function search() {
    const hash = document.getElementById('ipfsHash').value;
    const chunks = [];
    for await (const chunk of ipfs.cat(hash)) {
        chunks.push(chunk)
    }
    log(Buffer.concat(chunks).toString());
}


function log(str) {
    document.getElementById("log").innerHTML += '<p>' + str + '</p>';
}

init();
