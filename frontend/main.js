const loaderTexts = [
    'Still loading...',
    'Loading is too long...',
    'Nearly finished...',
    'One last check...',
    'Get ready!'
];

let loaderInterval;
let currentIndex = 0;
let lock = false;
let formToggled = false;

async function loadData() {
    if (!lock) {
        lock = true;

        const loaderContainer = document.getElementById('loader-container');
        const loaderText = document.getElementById('loader-text');
        const apiUrl = document.getElementById('api-url').value;
    
        // Disable buttons
        const button_one = document.getElementById('my-button-1');
        const button_two = document.getElementById('my-button-2');
        button_one.classList.add('disabled');
        button_two.classList.add('disabled');

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
            }
        }, 15000);

        //API call
        try {
            const response = await fetch(apiUrl, {
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
}

function showApiResult(response) {
    clearInterval(loaderInterval);

    // Hide form if toggled
    if (formToggled) {
        toggleForm();
    }

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
    if (response.message) {
        loaderText.innerHTML = "<div>" + response.message + "</div>";
    } else {
        loaderText.innerHTML = "<div>Here is your instance: <a href='http://" + response.Ip + "'>" + response.Ip + "</a>!</div>";
        triggerConfetti();
    }
}

function triggerConfetti() {
    confetti({
        particleCount: 500,
        spread: 100,
        origin: { y: 0.6 },
    });
}

function toggleForm() {
    if (!lock) {
        formToggled = !formToggled;
        const formContainer = document.getElementById('form-container');
        if (formContainer.style.display === 'flex') {
            formContainer.style.display = 'none';
        } else {
            formContainer.style.display = 'flex';
        }
    }
}