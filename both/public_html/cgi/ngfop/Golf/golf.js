document.addEventListener("DOMContentLoaded", function () {
  const header = document.getElementById("golfheader");
  if (header) {
    header.innerHTML = `
                  <h1 class="header-title" onclick="loadPage('./indexgv22.html')" style="cursor: pointer;">
                LinK
            </h1>
    `;

    header.onclick = function () {
      loadPage("./indexgv22.html");
    };
  }

  const titleElement = document.getElementById("linktitle");
  if (titleElement) {
    titleElement.textContent = "Link";
  }

  // Populate the footer
  const footer = document.getElementById("golffooter");
  if (footer) {
    footer.innerHTML = `
            <p class="footer-text">&copy; Golfy Jones Inc. 2025</p>
          `;
  }
});

function loadPage(url) {
  window.location.href = url;
}
