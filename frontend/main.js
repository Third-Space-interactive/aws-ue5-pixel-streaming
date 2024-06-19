const loaderTexts = [
    'Still loading...',
    'Loading is too long...',
    'Nearly finished...',
    'One last check...',
    'Get ready!'
];

let loaderInterval;
let currentIndex = 0;

async function loadData() {
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
        if (currentIndex == loaderTexts.length - 1) {
            currentIndex = 0
        } else {
            currentIndex = Math.round(Math.random() * (loaderTexts.length - 1));
            console.log(currentIndex);
        }
    }, 15000);

    //API call
    try {
        const response = await fetch('https://i4tiulnqm7.execute-api.eu-central-1.amazonaws.com/api/create-instance', {
            method: 'GET',
            origin: 'frontend'
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const apiResponse = await response.json();

        showApiResult(apiResponse);
    } catch (error) {
        showApiResult({ message: `Error : ${error.message}` });
    }
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
    loaderText.innerHTML = "<div>Here is your instance: <a href='http://" + response.Ip + "'>" + response.Ip + "</a>!</div>";

    triggerConfetti();
}

function triggerConfetti() {
    confetti({
        particleCount: 500,
        spread: 100,
        origin: { y: 0.6 },
    });
}