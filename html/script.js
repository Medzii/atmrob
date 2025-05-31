js
let currentStep = 0;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "startBoot") startBoot();
    if (data.action === "showConnected") {
        showScreen('connected-screen');
        setTimeout(() => {
            showScreen('command-screen');
            currentStep = 1;
        }, 2000);
    }
    if (data.action === "command2") {
        showScreen('command-screen');
        currentStep = 2;
    }
    if (data.action === "success") showScreen('success-screen');
    if (data.action === "fail") showScreen('fail-screen');
    if (data.action === "close") {
        document.getElementById('ui').style.display = 'none';
    }
});

function showScreen(id) {
    document.querySelectorAll('.screen-content').forEach(el => el.classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
}

function startBoot() {
    document.getElementById('ui').style.display = 'block';
    showScreen('boot-screen');
    let progress = 0;
    const interval = setInterval(() => {
        progress += 5;
        document.getElementById('progress-bar').style.width = `${progress}%`;
        if (progress >= 100) {
            clearInterval(interval);
            showScreen('login-screen');
        }
    }, 200);
}

document.getElementById('login-btn').addEventListener('click', () => {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    fetch(`https://${GetParentResourceName()}/submitLogin`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ username, password })
    });
});

document.getElementById('submit-btn').addEventListener('click', () => {
    const command = document.getElementById('command-input').value;
    fetch(`https://${GetParentResourceName()}/submitCommand`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ command })
    });
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST'
    });
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
    }
});
