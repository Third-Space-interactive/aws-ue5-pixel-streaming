const loaderTexts = [
    'Still loading...',
    'Loading is too long...',
    'Nearly finished...',
    'One last check...',
    'Get ready!'
];

let loaderInterval;
let currentIndex = 0;

function loadData() {
    const loaderContainer = document.getElementById('loader-container');
    const loaderText = document.getElementById('loader-text');

    // Show loader
    loaderContainer.style.display = 'flex';
    setTimeout(() => {
        loaderContainer.classList.add('show');
    }, 10);

    // Change loader text each 30 seconds
    loaderInterval = setInterval(() => {
        loaderText.textContent = loaderTexts[currentIndex];
        currentIndex = (currentIndex + 1) % loaderTexts.length;
    }, 10000);

    // API Simulation
    setTimeout(() => {
        const fakeApiResponse = {
            message: '<div>Here is your instance: <a href="https://google.com">google.com</a></div>'
        };
        showApiResult(fakeApiResponse);
    }, 30000);
}

function showApiResult(response) {
    clearInterval(loaderInterval);

    // Hide loader
    const loader = document.getElementById('loader');
    loader.style.display = 'none';

    // Hide button
    const button = document.getElementById('button-container')
    button.style.display = 'none';

    // Remove margin
    const loaderContainer = document.getElementById('loader-container');
    loaderContainer.style.marginTop = 0;

    // Display result
    const loaderText = document.getElementById('loader-text');
    loaderText.innerHTML = response.message;
    triggerConfetti();
}

function triggerConfetti() {
    confetti({
        particleCount: 500,
        spread: 100,
        origin: { y: 0.6 },
    });
}