// JavaScript for step-by-step UI and logic
let currentStep = 0;
const steps = ['boot', 'login', 'connected', 'command1', 'command2'];

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "startBoot") startBoot();
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
    }, 300);
}

document.getElementById('login-btn').addEventListener('click', () => {
    const user = document.getElementById('username').value;
    const pass = document.getElementById('password').value;
    if (user === 'Admin' && pass === 'Root') {
        showScreen('connected-screen');
        setTimeout(() => {
            showScreen('command-screen');
            currentStep = 1;
        }, 2000);
    }
});

document.getElementById('submit-btn').addEventListener('click', () => {
    const cmd = document.getElementById('command-input').value;
    if (currentStep === 1 && cmd === 'Bruteforce.exe') {
        showResult('Success! Enter next command.');
        currentStep = 2;
    } else if (currentStep === 2 && cmd === 'Hack-atm.exe') {
        showResult('Hack initiated...');
        fetch(`https://${GetParentResourceName()}/startHack`, { method: 'POST' });
    } else {
        showResult('Command failed. Restarting.');
        setTimeout(() => location.reload(), 3000);
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