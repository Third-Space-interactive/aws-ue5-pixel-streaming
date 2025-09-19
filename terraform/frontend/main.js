const loaderTexts = [
  "Still loading...",
  "Loading is too long...",
  "Nearly finished...",
  "One last check...",
  "Get ready!",
];

let loaderInterval;
let currentIndex = 0;
let lock = false;
let formToggled = false;

async function loadData() {
  if (!lock) {
    lock = true;

    const loaderContainer = document.getElementById("loader-container");
    const loaderText = document.getElementById("loader-text");
    const apiUrl = document.getElementById("api-url").value;

    // Disable buttons
    const button_one = document.getElementById("my-button-1");
    const button_two = document.getElementById("my-button-2");
    button_one.classList.add("disabled");
    button_two.classList.add("disabled");

    // Show loader
    loaderContainer.style.display = "flex";
    setTimeout(() => {
      loaderContainer.classList.add("show");
    }, 10);

    // Change loader text each 30 seconds
    loaderInterval = setInterval(() => {
      loaderText.textContent = loaderTexts[currentIndex];
      if (currentIndex == loaderTexts.length - 1) {
        currentIndex = 0;
      } else {
        currentIndex = Math.round(Math.random() * (loaderTexts.length - 1));
      }
    }, 15000);

    //API call
    try {
      const response = await fetch(apiUrl, {
        method: "GET",
        origin: "frontend",
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
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

  if (response.message) {
    // Hide loader
    const loader = document.getElementById("loader");
    loader.style.display = "none";

    // Hide button
    const button = document.getElementById("button-container");
    button.style.display = "none";

    // Remove margin
    const loaderContainer = document.getElementById("loader-container");
    loaderContainer.style.marginTop = 0;

    // Display error result
    const loaderText = document.getElementById("loader-text");
    loaderText.innerHTML = "<div>" + response.message + "</div>";
  } else {
    // Launch iframe with streaming application
    launchStreamingApp(response.Ip);
  }
}

function launchStreamingApp(ip) {
  // Hide the main interface
  const container = document.querySelector(".container");
  container.style.display = "none";

  // Show iframe container
  const iframeContainer = document.getElementById("iframe-container");
  const loadingOverlay = document.getElementById("loading-overlay");

  iframeContainer.classList.add("show");

  // Wait a moment for the iframe container to be visible, then set the source
  // This follows the best practice of not setting src directly in HTML
  setTimeout(() => {
    const streamingUrl = `http://${ip}:80/?HoverMouse=True&AutoConnect=True`;
    document.getElementById("pixelStreamingFrame").src = streamingUrl;
  }, 100);

  // Handle iframe load event
  const pixelStreamingFrame = document.getElementById("pixelStreamingFrame");
  pixelStreamingFrame.onload = function () {
    // Hide loading overlay after iframe loads
    setTimeout(() => {
      loadingOverlay.style.display = "none";
    }, 2000); // Give a 2-second delay for the streaming to establish

    triggerConfetti();
  };

  // Handle iframe error
  pixelStreamingFrame.onerror = function () {
    loadingOverlay.innerHTML = `
            <div style="text-align: center;">
                <div style="font-size: 1.5rem; margin-bottom: 1rem;">Connection Failed</div>
                <div>Unable to connect to streaming application</div>
                <button onclick="closeStreaming()" style="margin-top: 1rem; padding: 10px 20px; background: #ff7b00; color: white; border: none; border-radius: 5px; cursor: pointer;">Try Again</button>
            </div>
        `;
  };
}

function closeStreaming() {
  // Hide iframe container
  const iframeContainer = document.getElementById("iframe-container");
  iframeContainer.classList.remove("show");

  // Reset iframe back to blank:auto (following best practices)
  document.getElementById("pixelStreamingFrame").src = "blank:auto";

  // Show loading overlay again for next time
  const loadingOverlay = document.getElementById("loading-overlay");
  loadingOverlay.style.display = "flex";
  loadingOverlay.innerHTML = `
        <div class="loader"></div>
        <div>Connecting to streaming application...</div>
    `;

  // Show main interface again
  const container = document.querySelector(".container");
  container.style.display = "flex";

  // Reset buttons
  const button_one = document.getElementById("my-button-1");
  const button_two = document.getElementById("my-button-2");
  button_one.classList.remove("disabled");
  button_two.classList.remove("disabled");

  // Reset loader container
  const loaderContainer = document.getElementById("loader-container");
  loaderContainer.style.display = "none";
  loaderContainer.classList.remove("show");

  // Reset button container
  const buttonContainer = document.getElementById("button-container");
  buttonContainer.style.display = "flex";

  // Reset lock
  lock = false;
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
    const formContainer = document.getElementById("form-container");
    if (formContainer.style.display === "flex") {
      formContainer.style.display = "none";
    } else {
      formContainer.style.display = "flex";
    }
  }
}

// Optional: Handle escape key to close streaming
document.addEventListener("keydown", function (event) {
  if (event.key === "Escape") {
    const iframeContainer = document.getElementById("iframe-container");
    if (iframeContainer.classList.contains("show")) {
      closeStreaming();
    }
  }
});
