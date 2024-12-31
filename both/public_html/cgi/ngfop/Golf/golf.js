document.addEventListener("DOMContentLoaded", function () {
    const header = document.getElementById("golfheader");
    if (header) {
      header.onclick = function () {
        loadPage('./indexgv22.html');
      };
    }
  });
  
  function loadPage(url) {
    window.location.href = url;
  }
  