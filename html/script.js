let currentStep = 0;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "startBoot") startBoot();
    else if (data.action === "showConnected") {
        showScreen('connected-screen');
        setTimeout(() => {
            showScreen('command-screen');
            currentStep = 1;
        }, 2000);
    }
    else if (data.action === "command2") {
        currentStep = 2;
        showResult('Success! Enter next command.');
        setTimeout(() => {
            showScreen('command-screen');
        }, 2000);
    }
    else if (data.action === "success") {
        showResult('Hack succeeded!');
        setTimeout(() => closeUI(), 3000);
    }
    else if (data.action === "fail") {
        showResult('Hack failed.');
        setTimeout(() => closeUI(), 3000);
    }
    else if (data.action === "close") {
        closeUI();
    }
});

function startBoot() {
    showScreen('boot-screen');
    let progress = 0;
    const interval = setInterval(() => {
        progress += 2;
        document.getElementById('progress-bar').style.width = `${progress}%`;
        if (progress >= 100) {
            clearInterval(interval);
            showScreen('login-screen');
        }
    }, 100);
}

document.getElementById('login-btn').addEventListener('click', () => {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    fetch(`https://${GetParentResourceName()}/submitLogin`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
    });
});

document.getElementById('submit-btn').addEventListener('click', () => {
    const command = document.getElementById('command-input').value;
    fetch(`https://${GetParentResourceName()}/submitCommand`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ command })
    });
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

function showResult(text) {
    document.getElementById('result-text').textContent = text;
    showScreen('result-screen');
}

function showScreen(id) {
    document.querySelectorAll('.screen-content').forEach(el => el.classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
}

function closeUI() {
    document.querySelectorAll('.screen-content').forEach(el => el.classList.add('hidden'));
}
